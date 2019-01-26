# linux script to check if a service is running or not and if it’s stopped it will start it 


You will have to replace **replace_me_with_a_valid_service** with the name of the service you want to check

```
#!/bin/bash
service=replace_me_with_a_valid_service

if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
echo "$service is running!!!"
else
/etc/init.d/$service start
fi

```

You can place it in crontab and have it executed automatically
eg. to check every minute, insert into cron

```
crontab -e 
* * * * * /path/to/script
```
