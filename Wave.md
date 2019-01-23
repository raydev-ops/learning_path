# Docker Networking  Connect Containers Across Hosts Using Weave

Weave connects containers across hosts by creating a virtual network. It also has a DNS service which helps in automatic discovery. In this post, we looked into Docker ambassador pattern to connect containers across hosts. In this Docker Networking tutorial, you will learn how  to install and configure weave for connecting containers across hosts.
Installing and Configuring Weave

Follow the steps given below to install and configure Docker weave on both Docker hosts.

Note: TCP/UDP port 6783 should be open for weave to communicate. So make sure that in you firewall rules you have allowed TCP, UDP communication on port 6783 for both.

1. Run the following command as root to download all the necessary files for weave.

`  sudo wget -O /usr/local/bin/weave \ https://github.com/weaveworks/weave/releases/download/latest_release/weave

2. Execute the following command on two hosts to change the mode of the weave folder.

` sudo chmod a+x /usr/local/bin/weave `

On Host 1:

Follow the steps given below on host 1.

` weave launch `

The above container will launch a weave container which will act as a router.

2. Verify weave installation using the following command.

`  weave status `

The output looks like below.

```
weave router 0.11.2
Our name is be:06:84:24:34:17(ip-172-0-0-56)
Sniffing traffic on &amp;{13 65535 ethwe ae:f0:ad:18:83:48 up|broadcast|multicast}

MACs:
ae:f0:ad:18:83:48 -&gt; be:06:84:24:34:17(ip-172-0-0-56) (2015-06-10 10:57:49.682493592 +0000 UTC)

Routes:

unicast:
be:06:84:24:34:17 -&gt; 00:00:00:00:00:00

broadcast:
be:06:84:24:34:17 -&gt; []

Reconnects:
```

On Host2:

Follow the instructions below for setting up host2.
READ  Running Custom Scripts In Docker With Arguments - ENTRYPOINT Vs CMD

1. Launch weave by passing host1 IP address or hostname (if reachable) as an argument as shown below.

` weave launch 172.0.0.56 `

2. Verify the weave installation using the following command.
	
` weave status `

3. Now we have our two hosts with weave network set up. Let’s launch one container on both hosts using weave and check if there is a connectivity between two containers.
On host 1:

Launch an Ubuntu container on host1 using the weave run the command with 10.2.1.1 IP address as shown below. We will save the container id in a variable.
	
` C=$(weave run 10.2.1.1/24 -t -i ubuntu)   `

On host 2:

Launch another container on host 2 with 10.2.1.2 IP address as shown below.
	
` C=$(weave run 10.2.1.2/24 -t -i ubuntu)   `

To test the connectivity, on host1, attach to the running container using the following command. $C holds the value of container id.
	
` docker attach $C  `

Ping the container on host2(10.2.1.2) from the attached container. If the ping is successful, you weave network has been successfully configured. You can test the connection from host2 in the same manner we did from host1.
