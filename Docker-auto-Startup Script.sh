#vi /etc/rc.local

#!/bin/bash
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Fix hostname in hosts file
sed -i /etc/hosts -e "s/^127.0.0.1 localhost$/127.0.0.1 localhost $(hostname)/"


# Start the Docker App Container
/usr/bin/docker run -t --hostname nodejs --name alpinenodejs -v  -p 3000:3000 --privileged --restart unless-stopped --ulimit nofile=999999:999999 --ulimit nproc=256899:256899  bd432d23k2321s /etc/rc.local

exit 0
