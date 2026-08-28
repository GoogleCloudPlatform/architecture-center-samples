#!/bin/bash
set -e

# NOTE: This is EBS server boot script - all the updates add here

# Update packages - skipping due to this is time consuming
# dnf update -y

# Enable Google Cloud repo
tee /etc/yum.repos.d/google-cloud-sdk.repo << 'EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Cloud SDK
dnf install -y google-cloud-cli

# Verify installation
gcloud --version
gcloud storage ls

# disable IPV6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -p

# dnf oracle packages
dnf config-manager --set-enabled ol8_addons
dnf install oracle-ebs-server-R12-preinstall -y
dnf install oracle-database-preinstall-19c -y
dnf install jq tmux gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

# dnf cleanup
dnf clean all

# dir precreate and owberships
mkdir -v -p /u01 /u02
chown oracle:oinstall /u01
chown oracle:oinstall /u02

# for customer data
mkdir -p /opt/oracle
chown -Rf oracle:oinstall /opt/oracle

# Peoplesoft directories for PUM preinstall prerequisites
mkdir -pv  /u01/install/ /ds2 /srv/dpk/oracle /ds2/dpk/PT862P05B_2509240500-retail-orasrvlnx/oracleserver-2623528/oracle-server/product/19.3.0.0/bin/ /u02/db/oracle-server/admin/CDBCRM/adump
chown -Rf oracle:oinstall /u02 /u01 /ds2 /srv/
touch  /etc/oratab
chown  oracle:oinstall /etc/oratab

# remove profiles
mv -v /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
mv -v /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.back
mv -v /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

# link libs
ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

# unset witch for oracle (Preinstall RPM install oracle)
if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

# function to source env on 
# if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

# swap | 20g
fallocate -l 20G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make it persistent by adding it to /etc/fstab (if not already there)
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "Configuring Exascale Cluster Access for Oracle user..."

mkdir -p /home/oracle/.ssh
chown oracle:oinstall /home/oracle/.ssh
chmod 700 /home/oracle/.ssh

SECRET_ID=$(curl -s -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/exadb_private_key_secret_id" || true)

SECRET_NAME=""
if [ -n "$SECRET_ID" ]; then
    SECRET_NAME=$(basename "$SECRET_ID")
fi

EXA_KEY=""
if [ -n "$SECRET_NAME" ]; then
    for i in {1..6}; do
        EXA_KEY=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null || true)
        if [ -n "$EXA_KEY" ]; then
            break
        fi
        sleep 10
    done
fi

if [ -n "$EXA_KEY" ]; then
    SKEL_SSH="/etc/skel/.ssh"
    mkdir -p "$SKEL_SSH"
    echo "$EXA_KEY" > "$SKEL_SSH/exadb_private_key.pem"
    chmod 700 "$SKEL_SSH"
    chmod 400 "$SKEL_SSH/exadb_private_key.pem"

    USER_LIST=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
    USER_LIST="$USER_LIST oracle"

    for USERNAME in $USER_LIST; do
        USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
        if [ -d "$USER_HOME" ]; then
            USER_SSH="$USER_HOME/.ssh"
            mkdir -p "$USER_SSH"
            printf "%s" "$EXA_KEY" > "$USER_SSH/exadb_private_key.pem"
            chown -R "$USERNAME" "$USER_SSH"
            chmod 700 "$USER_SSH"
            chmod 400 "$USER_SSH/exadb_private_key.pem"
        fi
    done
fi

# change hostname
hostnamectl set-hostname apps.example.com
if ! grep -q "apps.example.com" /etc/hosts; then
    echo "$(hostname -i)     apps.example.com apps" >> /etc/hosts
fi

echo "Checking crontab for hostname on startup"
if ! crontab -l 2>/dev/null | grep -q 'hostnamectl'; then
    echo "Add crontab: startup hostname set"
    job='@reboot sleep 5 && hostnamectl set-hostname apps.example.com'
    (crontab -l 2>/dev/null; echo "$job") | crontab -
fi

echo "EBS Startup Script Complete!"