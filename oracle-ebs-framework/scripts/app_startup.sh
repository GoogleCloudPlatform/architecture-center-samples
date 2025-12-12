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

# disable SE LINUx
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# disable IPV6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -p

# dnf oracle packages
dnf config-manager --set-enabled ol8_addons
dnf install oracle-ebs-server-R12-preinstall -y
dnf install oracle-database-preinstall-19c -y
dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

# dnf cleanup
dnf clean all

# disable firewall
systemctl stop firewalld
systemctl disable firewalld

# swap | 20g
fallocate -l 20G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# dir precreate and owberships
mkdir -v -p /u01 /u02
chown oracle:oinstall /u01
chown applmgr:oinstall /u02

# OEL8 FIX
# separate tasks for vision vs non-vision
# vision requires hostname change
# customer env requires tmux install to have long runnings sessions to attach
if [ "$(hostname)" = "oracle-vision" ]; then
    hostnamectl set-hostname apps
else
    dnf install tmux -y
fi

# remove profiles
mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

# link libs
ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

# unset witch for oracle (Preinstall RPM install oracle)
if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi