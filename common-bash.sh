#folder sizes
du -sh *

# reset dns
sudo systemctl restart nscd dnsmasq
# reload dns ubuntu 18.04
sudo systemd-resolve --flush-caches
sudo systemd-resolve --statistics

#rsync from local folder to remote folder
rsync -azP /home/odoo/.local/share/Odoo/ <user>@<host>:/odoo

#change ubuntu mirror country
sed -i 's/gh./uk./g' /etc/apt/sources.list

#disable sudo password prompt
sudo vi /etc/sudoers
%wheel ALL=(ALL) NOPASSWD: ALL ### add this line ###

#enable ntp
ntptime
adjtimex -p
timedatectl

# format drive
# mke4fs -t ext4 <block_device>
mkfs.ext4 <block_device>

# set drive label
e4label <block_device> new-label

# mount drive
mkdir /mount/point
mount <block_device> /mount/point

# mount drive
# /etc/fstab
<block_device>	/mount/point         ext4    defaults        0       0

# create self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout self-ssl.key -out self-ssl.crt

#############################################
# Postgresql
#############################################

# change postgresql dir
systemctl stop postgresql
mkdir -p /pgdata
chown -R postgres:postgres /pgdata
chmod -R 700 /pgdata
# edit postgresql.conf to point to /pgdata
systemctl start postgresql

# create user (super user, login, create db)
createuser -P -s -e <user>

# dump
pg_dump -Fc mydb > db.dump

# restore
pg_restore -C -d postgres db.dump
