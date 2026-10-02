#!/bin/bash

# NOTE: This is JD Edwards EnterpriseOne on Linux startup script on GCP
# this script is intended for customer data setup

# note: startup script is time consuming and may take 25-30 minutes to complete 

function install_gcloud() 
{
    echo " > Installing Google Cloud SDK"
    # Enable Google Cloud repo
    echo "
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
" > /etc/yum.repos.d/google-cloud-sdk.repo

    # Install Cloud SDK
    dnf install -y google-cloud-cli

    # Verify installation
    echo " > Verifying Google Cloud SDK installation"   
    gcloud --version
    gcloud storage ls
}

function install_yum_updates() 
{
    
    echo " > Installing JDE required packages and dependencies"
    dnf install -y oracle-database-preinstall-19c zip.x86_64 unzip.x86_64 bind-utils ksh.x86_64 gcc-c++.x86_64 gcc.x86_64 \
    zlib-devel.x86_64 openssl-devel bind-utils glibc.x86_64 glibc-devel.x86_64 ksh.x86_64 net-tools unzip.x86_64 \
    zip.x86_64 zlib-devel.x86_64 pcp pcp-doc pcp-pmda-dm pcp-pmda-nfsclient pcp-pmda-openmetrics pcp-selinux \
    pcp-system-tools pcp-zeroconf gdb gdb-headless glibc glibc-all-langpacks glibc-devel glibc-gconv-extra \
    libaio.i686 libaio-devel.i686  libgcc.i686 libipt libstdc++.i686 libstdc++-devel.i686 libxcrypt.i686 \
    libxcrypt-devel.i686 libnsl libnsl.i686 librdmacm  bc binutils compat-openssl11 elfutils-libelf fontconfig \
    glibc glibc-devel ksh libaio libasan liblsan libX11 libXau libXi libXrender libXtst libxcrypt-compat libgcc \
    libibverbs libnsl librdmacm libstdc++ libxcb libvirt-libs make policycoreutils \
    policycoreutils-python-utils smartmontools sysstat unixODBC.x86_64 samba samba-client samba-common libaio-devel.x86_64
    dnf install --enablerepo=ol9_codeready_builder libyaml-devel -y

    # one off RPM
    curl -o /tmp/compat-libcap1-1.10-7.el7.x86_64.rpm https://linuxsoft.cern.ch/cern/centos/7/updates/x86_64/Packages/compat-libcap1-1.10-7.el7.x86_64.rpm
    dnf localinstall -y /tmp/compat-libcap1-1.10-7.el7.x86_64.rpm

    dnf clean all
}

function setup_swap() {
    echo " > Setting up swap space"
    # swap | 20g
    if swapon --show=NAME --noheadings | grep -q .; then
        echo "Swap is already enabled"
    else
        if [[ ! -f /swapfile ]]; then
            fallocate -l 20G /swapfile
            chmod 600 /swapfile
            mkswap /swapfile
        fi
        swapon /swapfile
        echo "Swap 20G added as /swapfile"
    fi

    # Make it persistent by adding it to /etc/fstab (if not already there)
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo "Adding swap to /etc/fstab for persistence"
    fi
}

function update_kernel_params() 
{
# net.ipv6.conf.default.disable_ipv6=1
# net.ipv6.conf.all.disable_ipv6=1
# kernel.sem = 32000 1024000000 500 32000
    echo " > Updating kernel parameters"
    local_conf=/etc/sysctl.conf

    grep -q "net.ipv6.conf.default.disable_ipv6=1" $local_conf || echo "net.ipv6.conf.default.disable_ipv6=1" >> $local_conf
    grep -q "net.ipv6.conf.all.disable_ipv6=1" $local_conf || echo "net.ipv6.conf.all.disable_ipv6=1" >> $local_conf
    sed -i '/kernel.sem/d' $local_conf
    grep -q "kernel.sem" $local_conf || echo "kernel.sem = 32000 1024000000 500 32000" >> $local_conf
    # load kernel params
    sysctl --system > /dev/null 2>&1
    sysctl -p
}

function update_os_config()
{
    echo " > updating OS configuration"
    # Disable   SELinux
    echo "Disabling SELinux"
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    setenforce 0

    # Disable firewall
    echo "Disabling firewall"
    systemctl stop firewalld
    systemctl disable firewalld

    # start SMB
    systemctl enable smb nmb
    systemctl start smb nmb
    systemctl status nmb
    systemctl status smb

    # /etc/ssh/sshd_config update
    echo "Updating /etc/ssh/sshd_config"
    sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
    echo "# JDE required settings" >> /etc/ssh/sshd_config
    echo "ClientAliveInterval 3600" >> /etc/ssh/sshd_config

    sed -i '/AddressFamily/d' /etc/ssh/sshd_config
    echo "AddressFamily inet" >> /etc/ssh/sshd_config
}

function users_groups_create()
{
    echo " > creating required groups and users"
    ## remove existing oracle user and groups from preinstall rpm'
    userdel oracle
    rm -Rf /home/oracle/
    groupdel dba
    groupdel oinstall

    groupadd -g 1100 dba
    groupadd -g 1101 oracle
    groupadd -g 1103 oneworld
    groupadd -g 1104 oinstall
    groupadd -g 1105 jde920

    # users
    useradd -d /home/oracle -u 1001 -g dba -m -s /bin/bash oracle
    useradd -d /home/jde920 -u 1002 -g jde920 -m -s /bin/ksh jde920

    # users to groups
    usermod -a -G oracle oracle
    usermod -a -G dba oracle
    usermod -a -G oracle jde920
    usermod -a -G oneworld jde920
    usermod -a -G dba oracle

    mkdir -p /u01 /u02
    chmod 770 /u01 /u02
    chgrp oracle /u01 /u02
}

function ruby_install() 
{
    echo " > installing ruby"
    curl -LO https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.4.tar.gz
    tar -xzf ruby-3.3.4.tar.gz
    chmod 755 -R ruby-3.3.4
    cd ruby-3.3.4
    ./configure --prefix=/usr --disable-dtrace
    make
    make install

    # root install
    gem install -v 2.3.6 -r winrm
    cd ~ 
}

function user_profile_updates()
{   
    echo " > updating user profiles"
    # distribution id
    grep -q "CV_ASSUME_DISTID" /root/.bash_profile|| echo "export CV_ASSUME_DISTID=OL7" >>  /root/.bash_profile
    grep -q "CV_ASSUME_DISTID" /home/oracle/.bash_profile|| echo "export CV_ASSUME_DISTID=OL8" >>  /home/oracle/.bash_profile

    # umasks
    grep -q "umask" /root/.bash_profile|| echo "export umask=0022" >>  /root/.bash_profile
}



# MAIN / starting with users-groups
echo " >> Starting JD Edwards EnterpriseOne on Linux startup script"
users_groups_create
install_gcloud
install_yum_updates
setup_swap
update_kernel_params
update_os_config
ruby_install    
user_profile_updates