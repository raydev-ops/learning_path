# Docker Auto Scaling with sendmail

##Use-case 

I had a PHP application running inside my Docker container (CentOS 7 based), being served by httpd (Apache2). This was single container running on a host machine. A use-case arose when I thought of what would happen when the traffic to my website increased or the CPU utilization went high etc. . I would have to scale my containers i.e. launch a new server and run a container inside that. Also, what I needed to do is keep the containers isolated & check whether the container has come up in auto-scaling or not. So, that is what the blog is about. So, I have made a script which you can add to user data in Launch Configuration.
Prerequisites 

What I will assume is that  you already have a Docker container running (CentOS 7 based), and it is serving some PHP application through httpd.
Also, what more you need is :-

    An Auto-scaling group & Launch Configuration in your AWS account.
    Your host machine’s AMI added to the Launch Configuration.
    Latest image of your running container committed to Docker Hub or you may locally commit the container image & create an AMI from that and add to Launch Configuration group.
    Host machine may be Amazon Linux or CentOS/RedHat. ( Even Ubuntu, but commands may slightly differ)
    sendmail service installed & running on host machine. (This will be used to send an email when Docker container comes up)

## How to implement it

Explanation : Lets talk about the scripts. As we know every time a new container starts the entry in /etc/hosts changes to default with the new container ID. As sendmail requires a domain name to work, we will be using 2 scripts for sendmail about which we talked about in the previous blog, first being dockerscriptetchosts.sh and the other being startsendmail.sh. Let us go through them one by one before we come to our main script autodeploy.sh

So, the first script for sendmail is dockerscriptetchosts.sh

```
#!/bin/bash

line=$(head -n 1 /etc/hosts) 
line2=$(echo $line | awk '{print $2}')

echo "$line $line2.localdomain" >> /etc/hosts

```

The above script has already been added to the image using ADD in Dockerfile. It makes the necessary entry to /etc/hosts of the Docker container which are as follows :-

container_IP container_id container_id.localdomain

Next script is startsendmail.sh.

```
#!/bin/bash
sudo docker exec -itd $1 bash /home/dockerscriptetchosts.sh
sudo docker exec -itd $1 /etc/init.d/sendmail start
sudo docker exec -itd $1 /usr/sbin/httpd -k restart

```
This script is present on the host machine & takes one parameter input (container_id) to execute which we will pass in the main script. It firstly runs docker exec command which in turn runs the command bash /home/dockerscriptetchosts.sh inside the Docker container and in turn the next commands. The last command restarts httpd.

The main script autodeploy.sh is below. Just go through it and I will explain the script just after that. You will need to put this bash script in the user-data.

```	
#!/bin/bash
sudo docker pull ranvijayj/prod:latest #this is if you want to pull from Docker Hub
container_id=$(docker run -idt -p 80:80 --restart="always" -v /mnt/code:/opt/code prod:latest)
#check whether container is running or not
sleep 5
if [ `docker inspect -f {{.State.Running}} $container_id` == "true" ]; then
 echo "Container has restarted .. Volume mounted" | sendmail -s " Container has come up in autoscaling" ranvijay.jamwal@tothenew.com
 sleep 20
 http_status=$(curl -Is localhost:80 | head -n 1 | awk '{ print $2}')
 if [ $http_status == 200 ]; then
 echo "Container is SERVING the website" | sendmail -s " Container is serving the website" ranvijay.jamwal@tothenew.com
 #once the container has started we need to start the sendmail service
 #startsendmail can be present in any directory of AMI
 bash /home/ec2-user/startsendmail.sh
 else
 echo "Container has FAILED to serve the website.. http_status= $http_status" | sendmail -s " Container is NOT SERVING at port 80" ranvijay.jamwal@tothenew.com
 fi
else
 echo "Container has not restarted/started" | sendmail -s " Container has failed to come up in autoscaling &amp; is NOT serving the website" ranvijay.jamwal@tothenew.com
fi

```
