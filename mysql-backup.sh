#!/bin/bash
# Shell script to backup MySql database


MyUSER="nask0"        # USERNAME
MyPASS=""             # PASSWORD
MyHOST="localhost"   # Hostname

# FreeBSD bin paths, change this if it can't be autodetected via "which" command
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"
MAILX="$(which mailx)"
GPG2="$(which gpg2)"
RSYNC=`which rsync`
SSH=`which ssh`
# Get data in dd-mm-yyyy format
NOW="$(date +%m-%d-%y)"
# Backup Dest directory, change this if you have some other location
DEST=${HOME}"/dumps"
SERVER="192.168.0.8"
HOST="localhost"
#HOST="$(hostname)"
# Main directory where backup will be stored
MBD="$DEST/$HOST/$NOW/mysql"
# File to store current backup file
FILE=""
# Store list of databases
DBS=""
# Charset of the selected database
CHARSET=""
# DO NOT BACKUP these databases
SKIP="test information_schema"



echo ${DEST}
exit;




[[ ! -d $MBD ]] && mkdir -p $MBD || : # do nothing if && does not succeed

# Only root can access it!
#$CHOWN 0:0 -R $DEST
#$CHMOD 0600 $DEST

# Get all database list first
DBS="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"

for db in $DBS
do
    skipdb=-1
    if [ "$SKIP" != "" ]
    then
        for i in $SKIP
        do
           [ "$db" = "$i" ] && skipdb=1 || :
        done
    fi
    if [ "$skipdb" = "-1" ] ;
        then
            CHARSET=`($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse "show create database $db") | awk '{print $9}'`
            FILE="$MBD/$db.sql.gz.gpg"
            # do all-in-one job in pipe, connect to mysql using mysqldump for select mysql database
            # and pipe it out to gz file in backup dir :)
            $MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse "show slave status\G" | grep "Seconds_Behind_Master"
            #$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=$CHARSET $db | $GZIP | $GPG2 -c --cipher-algo AES256 --batch --passphrase=$MyPASS -o $FILE
            #$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=$CHARSET $db | $GZIP > $FILE
    fi
done
$RSYNC -avpz -e "$SSH -i /root/.ssh/id_backup_rsa" $DEST/$HOST/ root@10.191.1.98:$DEST/$HOST/
#$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=cp1251 dreamville-bg | $GZIP > $MBD/dreamville-bg.sql.gz
#$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=cp1251 pm.consultcommerce.bg | $GZIP > $MBD/pm.consultcommerce.bg.sql.gz
#$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=cp1251 wiki.consultcommerce.com | $GZIP > $MBD/wiki.consultcommerce.com.sql.gz
#$MYSQLDUMP -u $MyUSER -h $MyHOST --password=$MyPASS --default-character-set=cp1251 wiki.wordframe.net | $GZIP > $MBD/wiki.wordframe.net.sql.gz

### DELETE backups older than 30 days ###
#ssh -i /home/velis/.ssh/id_dsa velis@192.168.0.32 "/usr/bin/find /adm2/Backup/web_bsd2/db/ -mtime +30 -depth 1 | /usr/bin/xargs /bin/rm -rf"
#Copy entire directory to destination server by user velis (ssh login disallowed for root in FreeBSD systems)
#su velis -c 'setenv NOW `date +%y%m%d` && /usr/bin/nice -n 10 scp -r /usr/backup/mysqlDB/$NOW 192.168.0.32:/adm2/Backup/web_bsd2/db && unsetenv NOW'

# Empty TempBackup Folder #
#/usr/bin/nice -n 10 rm -rf $MBD
