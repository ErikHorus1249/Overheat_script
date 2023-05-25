#!/bin/bash

# script home 
SCT_HOME=/usr/bin/rammon
SYSFILE=/lib/systemd/system/rammon.service
LOG=/var/log/rammon 

# create script dir and chmod 
if [ -d "$SCT_HOME" ]; then
    echo "[+]$SCT_HOME: File exists!"
else
    echo "Create script dir"
    sudo mkdir $SCT_HOME
fi

if [ -d "$LOG" ]; then
    echo "[+]$LOG: File exists!"
else
    echo "Create log dir"
    sudo mkdir $LOG
fi

sudo chmod -R 777 $SCT_HOME
sudo chmod -R 777 $LOG

# create file script 
sudo cat overheat.sh > $SCT_HOME/overheat.sh

# Create A SystemD File
sudo chmod -R 777 /lib/systemd/system/
sudo cat rammon.service > /lib/systemd/system/rammon.service 

# Reload daemon 
sudo systemctl daemon-reload

# start 
sudo systemctl enable rammon.service 
sudo systemctl start rammon.service 

