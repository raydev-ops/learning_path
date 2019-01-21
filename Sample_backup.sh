#!/bin/bash

echo "sample backup script"
NOW=$(date +"%S%M%H_%m-%d-%Y")
DATA_DIR=/var/www/html

BACKUP_DIR=/mnt/sitebackup/backupwebsites/
mkdir -p /mnt/sitebackup/backupwebsites

tar czvf $BACKUP_DIR/backup_$NOW.tar.gz .
