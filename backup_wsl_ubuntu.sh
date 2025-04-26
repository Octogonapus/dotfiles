#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]
  then echo "Must run as root"
  exit 1
fi

DIRS=(/home
/opt
/etc
/var/spool/mail
/var/spool/cron)

for DIR in "${DIRS[@]}"; do
    mkdir -p "/mnt/system-backups/wsl-ubuntu/${DIR:1}"
    rsync -a --delete --safe-links "$DIR" "/mnt/system-backups/wsl-ubuntu/${DIR:1}"
done

apt list --installed > /mnt/system-backups/wsl-ubuntu/apt-installed.txt
