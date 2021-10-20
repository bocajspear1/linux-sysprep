#!/bin/bash

sudo bash -c 'echo -n > /etc/machine-id'
#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
if [ -f /var/log/wtmp ]; then
      sudo truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
      sudo truncate -s0 /var/log/lastlog
fi

sudo truncate -s0 /var/log/syslog
sudo truncate -s0 /var/log/auth.log
sudo truncate -s0 /var/log/kern.log

#cleanup /tmp directories
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

#cleanup current ssh keys and configs
sudo rm -f /etc/ssh/ssh_host_*
sudo rm /root/.ssh/*
rm ~/.ssh/*

# Recreate SSH keys on next boot
# From https://www.digitalocean.com/blog/avoid-duplicate-ssh-host-keys/

text="
[Unit]
After=network.service
Before=sshd.service

[Service]
ExecStart=/usr/local/bin/ssh-keys.sh

[Install]
WantedBy=default.target
"
echo "$text" | sudo tee /etc/systemd/system/sshkeys.service
sudo chmod 664 /etc/systemd/system/sshkeys.service


sc="#!/bin/sh
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
"

echo "$sc" | sudo tee /usr/local/bin/ssh-keys.sh
sudo chmod +x /usr/local/bin/ssh-keys.sh
sudo systemctl daemon-reload
sudo systemctl enable sshkeys

sudo apt clean

sudo cloud-init clean --logs

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

sudo rm -rf /var/lib/dhcp/dhclient.leases
