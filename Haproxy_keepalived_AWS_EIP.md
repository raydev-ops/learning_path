
# Keepalived and HAProxy in AWS  with Elastic IP

In My hosting Scnenario I launch 3 ec2 instances  1 Elastic IP

    Instance1:  i-019fcc345845ce55c (WEB)         172.31.54.168
    Instance2:  i-0acb4718f932f0902 (HA1-Master)  172.31.58.51
    Instance3:  i-07b8844fcad523701 (HA2-Backup)  172.31.50.239

    ElasticIp: 35.174.24.241

To install apache server Instance1:
  
```
yum install httpd -y
echo "This IS MY Sample Web pages" > /var/www/html/index.html
service httpd start 
  
```

Install both  keepalived and haproxy  both Instances 2 and 3:

On Ubuntu systems:

     sudo apt-get install keepalived wget haproxy  -y 

On CentOS systems:

     sudo yum install keepalived wget haproxy  -y 

update haproxy config file like below: 

```
vi /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  main *:80
    default_backend             app

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend app
    balance     roundrobin
    server  app  172.31.54.168:80 check
 
```


To update below configurations in Instance2 (Master)  keepalived config file   "/etc/keepalived/keepalived.conf "
```
vi /etc/keepalived/keepalived.conf
vrrp_script chk_haproxy { 
    script "pidof haproxy" 
    interval 2 
} 
vrrp_instance VI_1 { 
    debug 2 
    interface eth0 # interface to monitor 
    state MASTER 
    virtual_router_id 51 # Assign one ID for this route 
    priority 101 # 101 on master, 100 on backup 
    unicast_src_ip 172.31.58.51 # My IP 
    unicast_peer {
        172.31.50.239 # peer IP 
    } 
    track_script { 
        chk_haproxy 
    } 
    notify_master /etc/keepalived/master.sh 
}

```
Create a script notify_master "/etc/keepalived/master.sh"
```
vi /etc/keepalived/master.sh

#!/bin/bash
#EIP=35.174.24.241
INSTANCE_ID=i-0acb4718f932f0902
ALLOCATION_ID=eipalloc-063d7ccc791de41e5
aws configure set default.region us-east-1
aws ec2 disassociate-address --allocation-id  $ALLOCATION_ID
aws ec2 associate-address --instance-id $INSTANCE_ID  --allocation-id  $ALLOCATION_ID
```


To update below configurations in Instance3  keepalived config file   "/etc/keepalived/keepalived.conf "

Instance3 (backup) (/etc/keepalived/keepalived.conf)
```
vrrp_script chk_haproxy { 
script "pidof haproxy" 
    interval 2 
} 
vrrp_instance VI_1 { 
    debug 2 
    interface eth0 # interface to monitor 
    state BACKUP 
    virtual_router_id 51 # Assign one ID for this route 
    priority 100 # 101 on master, 100 on backup 
    unicast_src_ip 172.31.50.239 # My IP 
    unicast_peer {
        172.31.58.51 # Peer IP 
    } 
    track_script { 
        chk_haproxy 
    } 
    notify_master /etc/keepalived/master.sh 
}
```

create a script notify_master "/etc/keepalived/master.sh"
```
vi /etc/keepalived/master.sh

#!/bin/bash
#EIP=35.174.24.241
INSTANCE_ID=i-07b8844fcad523701
ALLOCATION_ID=eipalloc-063d7ccc791de41e5
aws configure set default.region us-east-1
aws ec2 disassociate-address --allocation-id  $ALLOCATION_ID
aws ec2 associate-address --instance-id $INSTANCE_ID  --allocation-id  $ALLOCATION_ID

```
## Attach Elastic Ip instance2(Master) 

Starting Keepalived Both servers 
```
sudo service keepalived restart
sudo service keepalived status
```

Instance2 (Master) server check status in logs:
```
[ec2-user@ip-172-31-58-51 ~]$ sudo service keepalived restart
Redirecting to /bin/systemctl restart keepalived.service
[ec2-user@ip-172-31-58-51 ~]$ sudo service keepalived status
Redirecting to /bin/systemctl status keepalived.service
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-01-26 04:28:12 UTC; 1s ago
  Process: 9660 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 9662 (keepalived)
   CGroup: /system.slice/keepalived.service
           ├─9662 /usr/sbin/keepalived -D
           ├─9664 /usr/sbin/keepalived -D
           └─9665 /usr/sbin/keepalived -D

Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: WARNING - default user 'keepalived_script' for script execution does not exist - please create.
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal systemd[1]: Started LVS and VRRP High Availability Monitor.
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: WARNING - script `pidof` resolved by path search to `/usr/sbin/pidof`. Please specify full path.
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: SECURITY VIOLATION - scripts are being executed but script_security not enabled.
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: Using LinkWatch kernel netlink reflector...
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: VRRP sockpool: [ifindex(2), proto(112), unicast(1), fd(10,11)]
Jan 26 04:28:12 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: VRRP_Script(chk_haproxy) succeeded
Jan 26 04:28:13 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: VRRP_Instance(VI_1) Transition to MASTER STATE
Jan 26 04:28:14 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: VRRP_Instance(VI_1) Entering MASTER STATE
Jan 26 04:28:14 ip-172-31-58-51.ec2.internal Keepalived_vrrp[9665]: Opening script file /etc/keepalived/master.sh
```

Instance3 (BACKUP) server check status in logs:
```
[ec2-user@ip-172-31-50-239 opt]$ sudo service keepalived status
Redirecting to /bin/systemctl status keepalived.service
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-01-26 04:27:30 UTC; 1min 42s ago
  Process: 6218 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 6220 (keepalived)
   CGroup: /system.slice/keepalived.service
           ├─6220 /usr/sbin/keepalived -D
           ├─6222 /usr/sbin/keepalived -D
           └─6223 /usr/sbin/keepalived -D

Jan 26 04:27:30 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: Using LinkWatch kernel netlink reflector...
Jan 26 04:27:30 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering BACKUP STATE
Jan 26 04:27:30 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP sockpool: [ifindex(2), proto(112), unicast(1), fd(10,11)]
Jan 26 04:27:30 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Script(chk_haproxy) succeeded
Jan 26 04:27:31 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) forcing a new MASTER election
Jan 26 04:27:32 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Transition to MASTER STATE
Jan 26 04:27:33 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering MASTER STATE
Jan 26 04:27:33 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: Opening script file /etc/keepalived/master.sh
Jan 26 04:28:13 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Received advert with higher priority 101, ours 100
Jan 26 04:28:13 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering BACKUP STATE
```


Verify switching working or not :
instance2 (Master):
```
sudo service keepalived stop	
```
instance3 (Backup):
```
ec2-user@ip-172-31-50-239 opt]$ sudo service keepalived status
Redirecting to /bin/systemctl status keepalived.service
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-01-26 04:27:30 UTC; 35min ago
  Process: 6218 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 6220 (keepalived)
   CGroup: /system.slice/keepalived.service
           ├─6220 /usr/sbin/keepalived -D
           ├─6222 /usr/sbin/keepalived -D
           └─6223 /usr/sbin/keepalived -D

Jan 26 04:27:30 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Script(chk_haproxy) succeeded
Jan 26 04:27:31 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) forcing a new MASTER election
Jan 26 04:27:32 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Transition to MASTER STATE
Jan 26 04:27:33 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering MASTER STATE
Jan 26 04:27:33 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: Opening script file /etc/keepalived/master.sh
Jan 26 04:28:13 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Received advert with higher priority 101, ours 100
Jan 26 04:28:13 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering BACKUP STATE
Jan 26 05:02:38 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Transition to MASTER STATE
Jan 26 05:02:39 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: VRRP_Instance(VI_1) Entering MASTER STATE
Jan 26 05:02:39 ip-172-31-50-239.ec2.internal Keepalived_vrrp[6223]: Opening script file /etc/keepalived/master.sh
```
