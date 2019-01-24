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



