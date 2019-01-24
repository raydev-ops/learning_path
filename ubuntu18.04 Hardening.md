# Ubuntu-18.04  Hardening Guide

## System Updates uptodate
Keeping the system updated is vital before starting anything on your system. This will prevent people to use known vulnerabilities to enter in your system.
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get autoclean
```

### Enable automatic updates can be crucial for your server security. It is very important to stay up to date.

` sudo apt-get install unattended-upgrades `

To enable it, run:

` sudo dpkg-reconfigure -plow unattended-upgrades `

This will create the file "/etc/apt/apt.conf.d/20auto-upgrades" with the following contents:

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

### Customize automatic updates

you can customize the automatic updates if you prefer. For example, you can get notifications when a security update is completed.
To enable ONLY security updates, please change the code to look like this:

```
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

   // Automatically upgrade packages from these (origin:archive) pairs
  Unattended-Upgrade::Allowed-Origins {
      "${distro_id}:${distro_codename}-security";
  //  "${distro_id}:${distro_codename}-updates";
  //  "${distro_id}:${distro_codename}-proposed";
  //  "${distro_id}:${distro_codename}-backports";
  };

```

To get notification by email, update the following line with your email address:

```
//Unattended-Upgrade::Mail "my_user@my_domain.com";

```

## Language / Region settings

I sometimes have problems with language and region settings after installation. To fix this, I set the locales to "en_US.UTF-8".

```
sudo locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
```

## Disable root account access
For security reasons, it is safe to disable the root account. Removing the account might not be a good idea at first, instead we simply need to disable it.

  -l, --lock                    lock the password of the named account
  -u, --unlock                  unlock the password of the named account

To disable the root account, simply use the "-l" option:

` sudo passwd -l root `

Note: If for some valid reason you need to re-enable the account, simply use the "-u" option:

` sudo passwd -u root `



## Install and Configuring fail2ban

Fail2ban is an intrusion prevention system that basically monitors log files and searches for certain patterns corresponding to a failed login. If a certain number of failed login attempts are detected from an IP address within a certain time, fail2ban blocks access for this IP address by creating a corresponding firewall rule. First of all install fail2ban:

` sudo apt install fail2ban `

Fail2Ban can be configured via configuration files in /"etc/fail2ban/jail.d". Further filters can be created in "/etc/fail2ban/filter.d". Currently our system is only accessible via SSH, so we should fail2ban watch the SSH access. To do so create a new configuration file like follows:

` sudo vim /etc/fail2ban/jail.d/ssh.conf `

Here is a example configuration file.

```
[sshd]

enabled  = true
port     = 22
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
```
It is a relatively simple configuration that specifies that we monitor SSH access (default port is 22 better to change other ports like 1250 )to port  1250, whose log files are located at /var/log/auth.log. To check the log file for failed logins, the filter sshd, which is included in the installation, is used. After three failed login attempts the corresponding IP address will be banned. It is also possible to notify the administrator by e-mail if IP addresses have been banned, etc. There are several sources on the Internet, such as the official fail2ban documentation.

After a new configuration has been added, the fail2ban service must be restarted. After the restart, the new configuration should appear in the status query from the fail2ban client, which can then also be viewed in detail.

```
sudo systemctl restart fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

