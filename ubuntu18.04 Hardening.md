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

## OpenSSL  Update for preventing attacks
```
sudo apt-get update
sudo apt-get upgrade openssl libssl-dev
```


## Language / Region settings

I sometimes have problems with language and region settings after installation. To fix this, I set the locales to **en_US.UTF-8**.

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

To disable the root account, simply use the **-l** option:

` sudo passwd -l root `

Note: If for some valid reason you need to re-enable the account, simply use the **-u** option:

` sudo passwd -u root `

## Create superadmin user
```
adduser samsuperadmin
usermod -aG sudo samsuperadmin
```

## Restrict su in  specific group

To allow only users in a given admin group to switch users - **su -**  execute the following steps in which you create a admin group, add a user dennis to this group and restrict the access to /bin/su to the admin group.

```
sudo groupadd devteam
sudo usermod -a -G devteam  dennis
sudo dpkg-statoverride --update --add root devteam 4750 /bin/su
```

## Set hostname in hosts file

` sudo sed -i /etc/hosts -e "s/^127.0.0.1 localhost$/127.0.0.1 localhost $(hostname)/"  `



## Secure /tmp and /var/tmp
Temporary storage directories such as /tmp, /var/tmp and /dev/shm gives the ability to hackers to provide storage space for malicious executables.

```
# Let's create a 1GB (or what is best for you) filesystem file for the /tmp parition.
sudo fallocate -l 1G /tmpdisk
sudo mkfs.ext4 /tmpdisk
sudo chmod 0600 /tmpdisk

# Mount the new /tmp partition and set the right permissions.
sudo mount -o loop,noexec,nosuid,rw /tmpdisk /tmp
sudo chmod 1777 /tmp

# Set the /tmp in the fstab.
sudo nano /etc/fstab
: /tmpdisk	/tmp	ext4	loop,nosuid,noexec,rw	0 0
sudo mount -o remount /tmp

# Secure /var/tmp.
sudo mv /var/tmp /var/tmpold
sudo ln -s /tmp /var/tmp
sudo cp -prf /var/tmpold/* /tmp/
sudo rm -rf /var/tmpold/

```

## Secure Shared Memory
Shared memory can be used in an attack against a running service, apache2 or httpd for example.
```
sudo nano /etc/fstab
tmpfs	/run/shm	tmpfs	ro,noexec,nosuid	0 0
```

## Consider running ARP monitoring software (arpwatch,arpon) 

` sudo apt-get install arpwatch  arpon -y `

## Run pwck manually and correct any errors in the password file 
```
sudo apt-get install pwck -y 
sudo apt-get  install  passwordsafe -y
```

## Install a PAM module for password strength testing like pam_cracklib or pam_passwdqc   PAM password strength tools 
` sudo apt-get install PAM `

## Install package apt-show-versions for patch management purposes
` sudo apt-get install apt-show-versions -y  `

## Install a package audit tool to determine vulnerable packages Enable auditd to check for read/write events

```
sudo apt-get install auditd -y
sudo systemctl restart auditd
```
If someone is modifying your passwords file — or using a compromised user account to do that 
you want to identify the breach so you can stop it at the source. 
By watching files with an audit tool, you can easily do that.

` sudo auditctl -w /etc/passwd -p war -k password-file `

## Install debsums utility for the verification of packages with known good database

`sudo apt-get install debsums -y `


## Purge old/removed packages (2 found) with aptitude purge or dpkg --purge command. This will cleanup old configuration files
```
sudo apt install aptitude -y
sudo aptitude purge
```

## check list of services enabled
```
sudo systemctl list-unit-files --type=service
sudo chkconfig --list
sudo  systemctl daemon-reload
```
Note: Now, you can disable a service by typing: systemctl disable <service>


## Set password rules PAM password strength tools
The password rules config file is located at etc/pam.d/common-password. Edit that file to include, for example, the following line:

`  sudo apt-get install libpam-cracklib  `
 You need to edit the file /etc/pam.d/common-password, enter

` sudo vi  /etc/pam.d/common-password `
 Modify Below line 
 `  password        requisite                       pam_cracklib.so retry=3 minlen=16 difok=3 ucredit=-1 lcredit=-2 dcredit=-2 ocredit=-2 `


    retry=3 : Prompt user at most 3 times before returning with error. The default is 1.
    minlen=16 : The minimum acceptable size for the new password.
    difok=3 : This argument will change the default of 5 for the number of character changes in the new password that differentiate it from the old password.
    ucredit=-1 : The new password must contain at least 1 uppercase characters.
    lcredit=-2 : The new password must contain at least 2 lowercase characters.
    dcredit=-2 : The new password must contain at least 2 digits.
    ocredit=-2 : The new password must contain at least 2 symbols.
	
## Set password expiration in login.defs
The login.defs file — /etc/login.defs — is where a big chunk of the password configuration rules live.
 Open it in a text editor, and look for the password aging control line. You’ll see three parameters:	
` sudo vi /etc/login.defs ` 
change below lines 

```
PASS_MAX_DAYS: 10
PASS_MIN_DAYS: 0
PASS_WARN_AGE: 7
```

    PASS_MAX_DAYS: Maximum number of days a password may be used. If the password is older than this, a password change will be forced.
    PASS_MIN_DAYS: Minimum number of days allowed between password changes. Any password changes attempted sooner than this will be rejected
    PASS_WARN_AGE: Number of days warning given before a password expires. A zero means warning is given only upon the day of expiration, a negative value means no warning is given. If not specified, no warning will be provided.
 
 
## Disable USB devices (for headless servers) 
You want to avoid someone wandering up to your server and loading malicious files or transferring data, especially if you don’t actually use the USB ports on your server. To do this, open up /etc/modprobe.d/block_usb.conf and add the following line:

` sudo vi /etc/modprobe.d/block_usb.conf `

add below line 

` install usb-storage /bin/true  `

### in some case it is use full but aws already disabled USBgaurd
```
sudo usbguard generate-policy > rules.conf
vi rules.conf
(review/modify the rule set)
sudo install -m 0600 -o root -g root rules.conf /etc/usbguard/rules.conf
sudo systemctl restart usbguard
````

## Disable IRQ Balance

You should turn off IRQ Balance to make sure you do not get hardware interrupts in your threads. Turning off IRQ Balance, will optimize the balance between power savings and performance through distribution of hardware interrupts across multiple processors.

To disable IRQ Balance, edit **/etc/default/irqbalance**  And Change the **ENABLED** value to 0::

```bash
sudo vi /etc/default/irqbalance  
ENABLED=0 
```


## IP hardening *Sysctl Conf*

**/etc/sysctl.conf** file is used to configure kernel parameters at runtime. Linux reads and applies settings from this file.

These settings can:

    Limit network-transmitted configuration for IPv4
    Limit network-transmitted configuration for IPv6
    Turn on execshield protection
    Prevent against the common 'syn flood attack'
    Turn on source IP address verification
    Prevents a cracker from using a spoofing attack against the IP address of the server.
    Logs several types of suspicious packets, such as spoofed packets, source-routed packets, and redirects.

You can configure various Linux networking and system settings such as Find and edit each settings:

```bash
sudo vi /etc/sysctl.conf


# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable send IPv4 redirect packets
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Set Reverse Path Forwarding to strict mode as defined in RFC 3704
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1


# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0


# Log suspicious martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Log Martians
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
kernel.exec-shield = 1
kernel.randomize_va_space = 1

# disable IPv6 if required (IPv6 might caus issues with the Internet connection being slow)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Accept Redirects? No, this is not router
net.ipv4.conf.all.secure_redirects = 0

# Log packets with impossible addresses to kernel log? yes
net.ipv4.conf.default.secure_redirects = 0

# [IPv6] Number of Router Solicitations to send until assuming no routers are present.
# This is host and not router.
net.ipv6.conf.default.router_solicitations = 0

# Accept Router Preference in RA?
net.ipv6.conf.default.accept_ra_rtr_pref = 0

# Learn prefix information in router advertisement.
net.ipv6.conf.default.accept_ra_pinfo = 0

# Setting controls whether the system will accept Hop Limit settings from a router advertisement.
net.ipv6.conf.default.accept_ra_defrtr = 0

# Router advertisements can cause the system to assign a global unicast address to an interface.
net.ipv6.conf.default.autoconf = 0

# How many neighbor solicitations to send out per address?
net.ipv6.conf.default.dad_transmits = 0

# How many global unicast IPv6 addresses can be assigned to each interface?
net.ipv6.conf.default.max_addresses = 1


# Disable IPv6 auto config
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.default.autoconf=0
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.all.autoconf=0
net.ipv6.conf.eth0.accept_ra=0
net.ipv6.conf.eth0.autoconf=0


net.ipv6.conf.default.accept_ra_pinfo = 0
fs.suid_dumpable = 0
kernel.core_uses_pid = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.randomize_va_space = 2
kernel.sysrq = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1


# In rare occasions, it may be beneficial to reboot your server reboot if it runs out of memory.
# This simple solution can avoid you hours of down time. The vm.panic_on_oom=1 line enables panic
# on OOM; the kernel.panic=10 line tells the kernel to reboot ten seconds after panicking.
vm.panic_on_oom = 1
kernel.panic = 10
```

apply the settings:

```
sudo sysctl --system
or 
sudo sysctl -p
```

## Set Security Limits
You might need to protect your system against fork bomb attacks. A simple way to prevent this is by setitng up processes limit for your users. All the limits can be configured in the "/etc/security/limits.conf" file.

` sudo vi /etc/security/limits.conf `

This file comes with all the help you need. Here's an example:
```
user1 hard nproc 100
@group1 hard nproc 20
```
This will prevent users from a specific group from having a maximum of 20 processs and maximize the number of processes to 100 to user1.

## Install and Configure Firewall:

After setting up the SSH server a firewall should be activated to secure the system. We’ll use the uncomplicated firewall (UFW). UFW should be installed by default, if not install it now. afterwards enable the SSH port, which you’ve set in your sshd_config. In the example above this would be port 22. Afterwards you need to enable the firewall.

```
sudo apt install ufw
sudo ufw allow 22/tcp
sudo ufw enable
```
in case if are able to login using jump server white list that jump server  like below in this example my jumpserver ip is 

` sudo ufw allow from 10.0.22.10/24  to any port 22 `


## SSH server configuration

The OpenSSH configuration is located at /etc/ssh/sshd_config.

` sudo vim /etc/ssh/sshd_config `

Modify Below perameters
```
Port 1234 # Security by obscurity doesn't work, but it leads to smaller fail2ban logs etc.
AllowUsers dennis

Protocol 2

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication:
LoginGraceTime 120
PermitRootLogin no
UsePrivilegeSeparation yes
StrictModes yes
MaxAuthTries 3
MaxSessions 10

PubkeyAuthentication yes
RSAAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys

IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no

PasswordAuthentication no
PermitEmptyPasswords no

ChallengeResponseAuthentication no

UsePAM yes

# Additional settings
X11Forwarding no
PrintMotd no
Banner none
DebianBanner no

AcceptEnv LANG LC_*

Subsystem       sftp    /usr/lib/openssh/sftp-server

```

Restart ssh server 

` sudo systemctl restart sshd `


## Install and Configuring fail2ban

Fail2ban is an intrusion prevention system that basically monitors log files and searches for certain patterns corresponding to a failed login. If a certain number of failed login attempts are detected from an IP address within a certain time, fail2ban blocks access for this IP address by creating a corresponding firewall rule. First of all install fail2ban:

` sudo apt install fail2ban `

Fail2Ban can be configured via configuration files in **/etc/fail2ban/jail.d**. Further filters can be created in "/etc/fail2ban/filter.d". Currently our system is only accessible via SSH, so we should fail2ban watch the SSH access. To do so create a new configuration file like follows:

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
It is a relatively simple configuration that specifies that we monitor SSH access (default port is 22 better to change other ports like 1250 )to port  1250, whose log files are located at **/var/log/auth.log**. To check the log file for failed logins, the filter sshd, which is included in the installation, is used. After three failed login attempts the corresponding IP address will be banned. It is also possible to notify the administrator by e-mail if IP addresses have been banned, etc. There are several sources on the Internet, such as the official fail2ban documentation.

After a new configuration has been added, the fail2ban service must be restarted. After the restart, the new configuration should appear in the status query from the fail2ban client, which can then also be viewed in detail.

```
sudo systemctl restart fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```


## Install and configure *OSSEC* host-based intrusion detection system
install required packages

```
sudo apt-get update 
sudo apt-get install build-essential -y
sudo apt-get install gcc -y 
wget https://github.com/ossec/ossec-hids/archive/3.1.0.tar.gz -P /tmp
cd /tmp
tar xzf 3.1.0.tar.gz 
cd ossec-hids-3.1.0
./install.sh
```
The installer will first prompts you to select the installation language, English by default, 

      abbreviated as [en]. Press Enter to accept the default
      The next prompt asks you verify the type of installation **agent**
      Once you chose the type of installation, press enter to continue. For the next prompt, press Enter chose **/var/ossec**  as the default install location
      Next, enter the IP address of the Sensor on which the agent should forward the logs for analysis. In this case, it can be you OSSEC server
      Enable system integrity check.
      Enable rootkit detection Engine
      Disable Active response by typing n unless you have a good understanding of the alerts you can see in your server.
      Press Enter to finalize the installation. If the installation is successful

**Connect the Agent to the Server**

Now that the agent is installed, run the following command to add the server-agent connection key. You can extract the Key for the specific host from the server. Enter option **I**, paste the key and confirm adding the key. Then type **Q** and press enter to exit.
```
/var/ossec/bin/manage_agents

/var/ossec/bin/ossec-control start
```
You can verify that the agent is communicating with the server by checking the ossec agent logs as shown below.

`tail /var/ossec/logs/ossec.log`

## Install Antivirus (clamav)
```
sudo apt-get install clamav
sudo freshclam
sudo apt-get install clamav-daemon
sudo crontab -e
00 00 * * * clamscan -r / | grep FOUND >> /var/log/report/myfile.txt
```

## Lynis is a security auditing for system

Clone or download the project files (no compilation nor installation is required) ;

`  git clone https://github.com/CISOfy/lynis  `

Execute:

` cd lynis; ./lynis audit system  `

If you want to run the software as root, we suggest changing the ownership of the files. Use chown -R 0:0 to recursively alter the owner and group and set it to user ID 0 (root).
