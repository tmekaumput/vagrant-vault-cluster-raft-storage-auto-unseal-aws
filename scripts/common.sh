#!/usr/bin/env bash
set -x

echo "Downloading jq executable"
sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

echo "Setting timezone to UTC"
sudo timedatectl set-timezone UTC

echo "Enable RHEL repositories"
sudo yum-config-manager --enable rhui-REGION-rhel-server-releases-optional
sudo yum-config-manager --enable rhui-REGION-rhel-server-supplementary
sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
sudo yum -y check-update

echo "Performing updates and installing prerequisites"
sudo yum install -q -y wget unzip bind-utils ruby rubygems ntp
sudo systemctl start ntpd.service
sudo systemctl enable ntpd.service

