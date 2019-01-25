# Public URLs for testing on mobile devices.

## Download Ngrok
```
cd /opt
mkdir ngrok
cd ngrox
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
unzip ngrok-stable-linux-arm.zip

```
## Creating Configuration File for Ngrok
We need to publish two tunnels (ssh, http). So we have to create a Ngrok configuration file to declare those services.

I create a file named *ngrok.yml* with content as below
```
web_addr: 0.0.0.0:4040
tunnels:
    ssh:
        proto: tcp
        addr: 0.0.0.0:22
    http:
        proto: http
        addr: 0.0.0.0:80
        auth: username:pass
```
Now, we open the browser and access http://PI_IP_ADDRESS:4040 to get the information of tunnels and I also declare two protocols and address for two tunnels – SSH and HTTP


Installing Supervisor

We need run Ngrok as a daemon (in background). So I use Supervisor – a third-party process manager. You can install Supervisor with command.
	
` apt-get install supervisor `

After finishing the installation, we create a Supervisor configuration file at /etc/supervisor/config.d/ngrok.conf with content as below
```	
[program:ngrok]
command=/opt/ngrok/ngrok start http ssh -log stdout --authtoken YOUR_NGROK_TOKEN_HERE -config=/opt/ngrok/ngrok.yml
stdout_logfile=/var/log/ngrok.out.log
stderr_logfile=/var/log/ngrok.err.log
```

Running the tunnels

In this step, we just need to run the program via Supervisor by command:
```	
supervisord reread
supervisor start ngrok        
```


Now, we open the browser and access http://PI_IP_ADDRESS:4040 to get the information of tunnels and 
