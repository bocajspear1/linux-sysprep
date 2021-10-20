# Sources:
# * https://github.com/jonatasbaldin/shell-script/blob/master/centos-sysprep.sh
# * https://lonesysadmin.net/2013/03/26/preparing-linux-template-vms/

# Remove machine ID
sudo bash -c 'echo -n > /etc/machine-id'

# Stop logging and auditd
sudo service rsyslog stop
sudo service auditd stop

# Cleanup Yum
sudo yum clean -q all

# Cleanup logs
sudo logrotate -f /etc/logrotate.conf
if [ -f /var/log/wtmp ]; then
      sudo truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
      sudo truncate -s0 /var/log/lastlog
fi
if [ -f /var/log/audit/audit.log ]; then
      sudo truncate -s0 /var/log/audit/audit.log
fi
sudo rm /var/log/*.gz
sudo rm /var/log/*-????????
sudo truncate -s0 /var/log/*.old
sudo truncate -s0 /var/log/*.log
sudo rm -rf /var/log/anaconda

# Clean udev rules
sudo rm -f /etc/udev/rules.d/70*

# Cleanup net iface config
sudo sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-*

# Clean tmp
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clean SSH host and user keys
sudo rm -f /etc/ssh/ssh_host_*
sudo rm /root/.ssh/*
sudo rm /home/*/.ssh/*


# Clean root and user histories
sudo rm -f ~root/.bash_history
sudo rm -f /home/*/.bash_history
history -c
unset HISTFILE