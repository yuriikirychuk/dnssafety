#!/bin/bash

# all packages are installed as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# allow root login for ssh
sed -i "s/#\{0,1\}PermitRootLogin *.*$/PermitRootLogin yes/g" /etc/ssh/sshd_config

# install vm tools (only if vmware is detected)
dmidecode -s system-product-name | grep -i "vmware" > /dev/null
if [ $? -eq 0 ]; then
    echo "Detected VMware, installing open-vm-tools..."
    apt update > /dev/null
    apt install -y open-vm-tools
fi

# copy the /etc/issue creation script to installation folder
cp va_issue.sh /opt/dnssafety/bin/

# make script executable
chmod +x /opt/dnssafety/bin/va_issue.sh

#  create systemd service that runs everytime network is restarted to update the /etc/issue login banner
cp dsissue.service /etc/systemd/system/dsissue.service

# enable it
systemctl enable dsissue.service

echo "Success, run next step please."
