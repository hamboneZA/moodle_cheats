#!/bin/sh

# Dirty moodle reset from backup files and a .gz mysqldump 
# Assumes backup, moodledata and core are in the same directory

echo
echo "--------------------------"
echo "| \e[1;31m MOODLE IS BEING RESET\e[0m |"
echo "--------------------------"

###############################
# TURN ON MAINTAINENCE MODE   #
###############################

sudo -u www-data php /var/www/moodle/admin/cli/maintenance.php --enablelater=1 >> /dev/null 2>&1
sleep 1m
echo "\e[1;30m ---------- WAITING A MINUTE FOR MAINTANENCE MODE -------------\e[0m \r"
echo -n ">>>                       [20%]\r"
cd /var/www/backups

###############################
# RESTORE MYSQLDUMP           #
###############################

gzip -dk moodle-database.sql.gz
mysql moodledb < moodle-database.sql
echo -n ">>>>>>>                   [40%]\r"
rm moodle-database.sql

cd /var/www
rm -r moodle
rm -r moodledata

###############################
# UNTAR BACKUP/TEMPLATE       #
###############################

cd /var/www
tar -xzf /var/www/backups/moodledata.tar.gz
tar -xzf /var/www/backups/moodlecore.tar.gz
echo -n ">>>>>>>>>>>>>>            [60%]\r"

###############################
# FIX PERMISSIONS             #
###############################

sudo chmod -R 0700 /var/www/moodledata
sudo find /var/www/moodledata -type f -exec chmod 0600 {} \;
chown -R www-data:www-data /var/www/moodledata

echo -n ">>>>>>>>>>>>>>>>>>>>>>>   [80%]\r"
sudo chmod -R 0755 /var/www/moodle
sudo find /var/www/moodle -type f -exec chmod 0644 {} \;
chown -R root:www-data /var/www/moodle
echo -n ">>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r"

###############################
# DISABLE MAINTAINENCE MODE   #
###############################

sudo -u www-data php /var/www/moodle/admin/cli/maintenance.php --disable >> /dev/null 2>&1
echo
echo "--------------------------"
echo "| \e[1;32m MOODLE HAS BEEN RESET \e[0m |"
echo "--------------------------"
