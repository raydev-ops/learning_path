# Install and Configuring Thumbor (it is for image croping)

```
#!/bin/bash
# Config Ref- https://www.dadoune.com/blog/best-thumbnailing-solution-set-up-thumbor-on-aws/

sudo yum update -y
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -ivh epel-release-latest-7.noarch.rpm
sudo yum update -y

sudo yum install make automake gcc gcc-c++ kernel-devel git-core  wget git  autoconf.noarch python-devel -y
sudo yum install fontconfig freetype freetype-devel fontconfig-devel libstdc++ -y

sudo yum install nginx.x86_64 -y
sudo systemctl  start nginx.service
sudo systemctl  status nginx.service
sudo systemctl  enable nginx.service


sudo yum install libjpeg-turbo-devel.x86_64 libjpeg-turbo-utils.x86_64 libtiff-devel.x86_64 libpng-devel.x86_64 pngcrush  \             jasper-devel.x86_64 libwebp-devel.x86_64 python-pip -y
sudo pip install pycurl
sudo pip install numpy


cd ~
git clone https://github.com/kohler/gifsicle.git
cd gifsicle
sudo ./bootstrap.sh
sudo ./configure
sudo make
sudo make install
cd ../
sudo rm -rf gifsicle/


#sudo pip install thumbor==4.12.2
sudo pip install thumbor
which thumbor

git clone https://github.com/willtrking/thumbor_aws.git
cd thumbor_aws/
sudo python setup.py install
cd ../
sudo rm -rf thumbor_aws/

sudo pip install tc_aws

```


We'll need to add two additional optimizer plugins as well. Thumbor already includes a script to support jpegtran but we'll need to add our own to support pngcrush and gifsicle.

For pngcrush, run the command:

[pngcrush.py](https://raw.githubusercontent.com/veeru538/learning_path/master/thumbor/pngcrush.py)

```
nano /usr/lib64/python2.7/site-packages/thumbor/optimizers/pngcrush.py
#--------------------------------------------------------------------------------------------------------------
#!/usr/bin/python
# -*- coding: utf-8 -*-

# thumbor imaging service
# https://github.com/thumbor/thumbor/wiki

# Licensed under the MIT license:
# http://www.opensource.org/licenses/mit-license


import os
import subprocess

from thumbor.optimizers import BaseOptimizer
from thumbor.utils import logger


class Optimizer(BaseOptimizer):
    def __init__(self, context):
        super(Optimizer, self).__init__(context)

        self.runnable = True
        self.pngcrush_path = self.context.config.PNGCRUSH_PATH
        if not (os.path.isfile(self.pngcrush_path) and os.access(self.pngcrush_path, os.X_OK)):
            logger.error("ERROR pngcrush path '{0}' is not accessible".format(self.pngcrush_path))
            self.runnable = False

    def should_run(self, image_extension, buffer):
        return 'png' in image_extension and self.runnable

    def optimize(self, buffer, input_file, output_file):
        command = '%s -reduce -q %s %s ' % (
            self.pngcrush_path,
            input_file,
            output_file,
        )
        with open(os.devnull) as null:
            subprocess.call(command, shell=True, stdin=null)

#--------------------------------------------------------------------------------------------------------------
```

For gifsicle, run the command:
[gifsicle.py](https://raw.githubusercontent.com/veeru538/learning_path/master/thumbor/gifsicle.py)

```
nano /usr/lib64/python2.7/site-packages/thumbor/optimizers/gifsicle.py

#--------------------------------------------------------------------------------------------------------------
#!/usr/bin/python
# -*- coding: utf-8 -*-

# thumbor imaging service
# https://github.com/globocom/thumbor/wiki

# Licensed under the MIT license:
# http://www.opensource.org/licenses/mit-license
# Copyright (c) 2011 globo.com timehome@corp.globo.com

import os

from thumbor.optimizers import BaseOptimizer

class Optimizer(BaseOptimizer):

    def should_run(self, image_extension, buffer):
        return 'gif' in image_extension

    def optimize(self, buffer, input_file, output_file):
        gifsicle_path = self.context.config.GIFSICLE_PATH
        command = '%s --optimize --output %s %s ' % (
            gifsicle_path,
            output_file,
            input_file,
        )
        os.system(command)
```

Install and configure Supervisord:
[supervisord](https://raw.githubusercontent.com/veeru538/learning_path/master/thumbor/supervisord)

```
sudo easy_install supervisor
sudo vi /etc/init.d/supervisord

#--------------------------------------------------------------------------------------------------------------
#! /bin/sh
### BEGIN INIT INFO
#Provides:          supervisord
#Required-Start:    $remote_fs
#Required-Stop:     $remote_fs
#Default-Start:     2 3 4 5
#Default-Stop:      0 1 6
#Short-Description: Supervisor init script
#Description:       Supervisor init script
### END INIT INFO

#Supervisord auto-start
#description: Auto-starts supervisord
#processname: supervisord
#pidfile: /var/run/supervisord.pid

SUPERVISORD=/usr/bin/supervisord
SUPERVISORCTL=/usr/bin/supervisorctl
ARGS="-c /etc/supervisord.conf"

case $1 in
start)
        echo -n "Starting supervisord: "
        $SUPERVISORD $ARGS
        echo
        ;;
stop)
        echo -n "Stopping supervisord: "
        $SUPERVISORCTL shutdown
        echo
        ;;
restart)
        echo -n "Stopping supervisord: "
        $SUPERVISORCTL shutdown
        echo
        echo -n "Starting supervisord: "
        $SUPERVISORD $ARGS
        echo
        ;;
esac
#--------------------------------------------------------------------------------------------------------------

```

Set executable permission  enable system start service
```
sudo chmod +x /etc/init.d/supervisord
sudo chkconfig --add supervisord
```

add th below content  supervisord config file [**/etc/supervisord.conf**](https://raw.githubusercontent.com/veeru538/learning_path/master/thumbor/supervisord.conf)

```
sudo vi /etc/supervisord.conf

#--------------------------------------------------------------------------------------------------------------
[unix_http_server]
file=/tmp/supervisor.sock   ; (the path to the socket file)

[supervisord]
logfile=/tmp/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB        ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10           ; (num of main logfile rotation backups;default 10)
loglevel=info                ; (log level;default info; others: debug,warn,trace)
pidfile=/tmp/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false               ; (start in foreground if true;default false)
minfds=1024                  ; (min. avail startup file descriptors;default 1024)
minprocs=200                 ; (min. avail process descriptors;default 200)

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

[program:thumbor]
; The following command uses a different thumbor config file for each
; processes, however we want the same setup for each so that isn't necessary
; command=thumbor --ip=127.0.0.1 --port=800%(process_num)s --conf=/etc/thumbor800%(process_num)s.conf
; Instead we'll use this command to use just the one conf file
command=/usr/bin/thumbor --ip=127.0.0.1 --port=800%(process_num)s --conf=/etc/thumbor.conf
process_name=thumbor800%(process_num)s
numprocs=4
autostart=true
autorestart=true
startretries=3
stopsignal=TERM
; Output logs for each of our processes
stdout_logfile=/var/log/thumbor.stdout.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=10
stderr_logfile=/var/log/thumbor.stderr.log
stderr_logfile_maxbytes=1MB
stderr_logfile_backups=10
#--------------------------------------------------------------------------------------------------------------
```
start supervisord service

` sudo /etc/init.d/supervisord start `

Configure nginx Proxy config for backend thumbor  access  [thumbor.conf](https://raw.githubusercontent.com/veeru538/learning_path/master/thumbor/thumbor.conf)

```
sudo vi /etc/nginx/conf.d/nginx-thumbor.conf

#--------------------------------------------------------------------------------------------------------------
# A virtual host using mix of IP-, name-, and port-based configuration


upstream thumbor  {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

server {
    listen       80;
    server_name  <INSERT YOUR DOMAIN NAME>;
    client_max_body_size 10M;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header HOST $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://thumbor;
        proxy_redirect off;
    }
}

#--------------------------------------------------------------------------------------------------------------

start nginx service

` sudo systemctl  restart nginx.service `

