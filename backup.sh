#!/bin/bash

# This script takes CyberPanel backups and upload to the Google Drive
# gdrive script is adopted from https://github.com/prasmussen/gdrive
# Author : Arun D
# Rev : 2.0
# To-Do: Cron job details

# Checking whether the gdrive is already installed
if [ ! -e /usr/local/bin/gdrive ]
then
	echo "gdrive not found. Installing it"
   	wget -O gdrive "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
        wait
	sudo install gdrive /usr/local/bin/gdrive
	wait
	echo "Configure your Google Drive connection "
        gdrive about
        echo "gdrive installed and linked to your account. Please edit the G_ID variable with the Directory ID and re-run the script"
        exit;
fi

echo "gdrive installed and linked to your account"

# G_ID is the Google Drive Directory ID. To get it, go to the directory created or add a new one. The GID is the random string found at the end of the URL.

# Variables :-

DATE="$(date +%Y-%m-%d)"
G_ID="1J5XXXXXXXX-YhgXXXXXXXXXXXXXXjDANC"
BACKUP_DIR="/home/backups"


echo " Continuing with the backup generation"
echo "------------------------------------------"

echo $DATE
# Deleteing old backups and Journal Files and create fresh temporary backup directory
rm -rf /home/*/backup/* /var/log/journal/*/*.journal $BACKUP_DIR && mkdir -p "$BACKUP_DIR/$DATE"
wait


# Executing a new CyberPanel's Local Backup Script instance

echo "Calling CybperPanel Backup Script"
ls -1 /home -Icyberpanel -Idocker -Ibackup -Ilscache -Ivmail | while read user; do
      echo "--- Taking backup of $user ---";
      cyberpanel createBackup --domainName $user > /dev/null
done
wait

# Copying tar.gz backup files from the default backup location to the script's backup location
echo "Copying tar.gz files to Backup Directory"
mv /home/*/backup/*.tar.gz "$BACKUP_DIR/$DATE"
wait

echo $(cd $BACKUP_DIR/$DATE && ls -A | wc -l) files in the backup directory

# Upload backup files to Directory with ID provided 

echo "Uploading Backup tar files to Google Drive"
/usr/local/bin/gdrive upload --recursive --parent $G_ID $BACKUP_DIR/$DATE
wait

# Remove backup directory to avoid confusions

echo "Removing temporary backup directory created"
rm -rf $BACKUP_DIR
wait

echo " Backups are uploaded to GDRIVE, Hurray!!!"
sleep 5
exit
