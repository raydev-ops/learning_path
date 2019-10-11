# backup all databases
mysqldump --all-databases --single-transaction --quick --lock-tables=false > full-backup-$(date +%F).sql -u root -p

# import backup
mysql –u[user name] -p[password] -h[hostname] [database name] < C:\[filename].sql
mysql –u root -p < full-backup-*.sql

# view users
SELECT User, Host, Password FROM mysql.user;

# see table struc
desc mysql.user;