#!/bin/bash

#--------------------------DEFAULT VARIABLE------------------#
LOGFILE="overheat.log"
SPLUNK_HOME="/opt/splunk/bin/splunk"
TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`
#-------------------------------COLOR------------------------#
YL='\033[1;33m'
PL='\033[0;35m'
NC='\033[0m' # No Color
#-------------------------------HELP-------------------------#
Help()
{
   # Display Help
   echo -e "Syntax: ${YL}overheat${NC} [-s|l|h]"
   echo "options:"
   echo -e "-s     Splunk home directory, default: ${PL}/opt/splunk/bin/splunk"${NC}
   echo -e "-l     Log directory, default: ${PL}$PWD/overheat.log${NC}"
   echo "-h     Help!"
   echo
}
#------------------------------OPTIONS----------------------# 
while getopts s:l:h option
do
    case "${option}" in
        l) LOGFILE=${OPTARG};;
        s) SPLUNK_HOME=${OPTARG};;
        h) # display Help
         Help
         exit;;
    esac
done
#-----------------------------MAIN LOOP----------------------#
while true; 
do  
    USED_RAM=`free | awk 'NR == 2 {print ($2 -$7)/$2 * 100.0}'`; 
    if [ ${USED_RAM%.*} -ge 80 ]
    then 
        # service splunk status | grep 'active (running)' > /dev/null 2>&1
        echo "$(date "+%Y-%m-%d %H:%M:%S") Caution! High RAM usage, in use is: ${USED_RAM%.*}%" >> $LOGFILE
        # restart splunk 
        sudo $SPLUNK_HOME restart > /dev/null
        echo "$(date "+%Y-%m-%d %H:%M:%S") Retarted Splunk!" >> $LOGFILE
        echo "$(date "+%Y-%m-%d %H:%M:%S") Sleep for 2 minutes" >> $LOGFILE
        sleep 120
    else 
        echo "$(date "+%Y-%m-%d %H:%M:%S") RAM in use is: ${USED_RAM%.*}%" >> $LOGFILE
        echo "$(date "+%Y-%m-%d %H:%M:%S") Sleep for 1 minute" >> $LOGFILE
        sleep 60
    fi
done

