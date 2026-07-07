#!/bin/bash
set -e

# NOTE: This is Peoplesoft server boot script - all the updates add here

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
dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils tmux expect -y

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
if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

# swap | 20g
fallocate -l 20G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make it persistent by adding it to /etc/fstab (if not already there)
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi