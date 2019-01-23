# Setup Consul Cluster Multi-Node

Consul is an open source key-value store. It is used for use cases such as service discovery, config management etc. This guide has detailed instructions to setup consul cluster with multiple nodes.
Prerequisites

    Three Linux servers
    Following ports opened between all three servers. If you on AWS, Azure or GCP make sure you have the security groups and firewall tags added properly to allow communications of the below-mentioned ports.
        8300  – TCP
        8301  – TCP & UDP
        8302  – TCP & UDP
        8400  – TCP
        8500  – TCP
        8600  – TCP & UDP


Setup Consul Cluster

This tutorial is based on a three-node consul cluster. The nodes are named as follows.

    consul-1
    consul-2
    consul-3

Follow the steps given below for a fully functional consul cluster.
READ  How To Get Six Months Pluralsight Free Subscription

Install and Configure Consul on All the Three Nodes

The following steps have to be performed on all the three nodes except step 4.

## Step 1: CD into bin directory and download Linux consul binary from here and Unzip the downloaded file and remove the zip file

```
cd /usr/local/bin
sudo wget https://releases.hashicorp.com/consul/1.2.0/consul_1.2.0_linux_amd64.zip

sudo unzip consul_1.2.0_linux_amd64.zip
sudo rm -f  consul_1.2.0_linux_amd64.zip

```

## Step 2: Create the following two directories.

```
sudo mkdir -p /etc/consul.d/scripts
sudo mkdir /var/consul

```

## Step 3: Create a consul secret using the following command from one of the three servers. Copy the secret to a text file.

` consul keygen `

## Step 4: Create a config file on all the three servers.

`sudo vi /etc/consul.d/config.json`

Copy the following config to the file. Replace encrypt value with the secret created in step 4 and start_join IP’s with your server IP’s.

```
{
    "bootstrap_expect": 3,
    "client_addr": "0.0.0.0",
    "datacenter": "Us-Central",
    "data_dir": "/var/consul",
    "domain": "consul",
    "enable_script_checks": true,
    "dns_config": {
        "enable_truncate": true,
        "only_passing": true
    },
    "enable_syslog": true,
    "encrypt": "Ae#qbaw12sdf345=ewew=",
    "leave_on_terminate": true,
    "log_level": "INFO",
    "rejoin_after_leave": true,
    "server": true,
    "start_join": [
        "10.11.0.2",
        "10.11.0.3",
        "10.11.0.4"
    ],
    "ui": true
}

```


## Step 5: Create a systemd file.

` sudo vi /etc/systemd/system/consul.service `

Copy the following contents to the file.

```
[Unit]
Description=Consul Startup process
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c '/usr/local/bin/consul agent -config-dir /etc/consul.d/'
TimeoutStartSec=0

[Install]
WantedBy=default.target

```
## Step 6: Reload the system daemons

` sudo systemctl daemon-reload `

Bootstrap and Start the Cluster

## Step 7: On consul-1,Consul-2 and consul-3  server, start the consul service

` sudo systemctl start consul `


## Step 8: Check the cluster status by executing the following command.
/usr/local/bin/consul members


Access Consul UI:

You can access the consul web UI using the following URL syntax.

` http://<consul-IP>:8500/ui `
