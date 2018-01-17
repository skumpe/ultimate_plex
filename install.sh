#!/bin/bash

#Make errors red and scary
error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

#Make good things green and happy
message() {
  printf '\E[32m'; echo "$@"; printf '\E[0m'
}

#Check if run as root or with sudo, error and exit if not
if [[ $EUID -gt 0 ]]; then
            error "This script MUST be run using sudo or as the root user"
            exit 1
    else
	    message "Script run as root or with sudo - yay! This is necessary to complete all the needed tasks, if it freaks you out please press Ctrl-C to exit. I will wait 10 seconds just in case"
	    sleep 10
fi

#add the Sonarr key and repo, test to see if silent! (its probably not)
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC > /dev/null 2>&1
echo "deb http://apt.sonarr.tv/ master main" > /etc/apt/sources.list.d/sonarr.list
echo -e "\n"
message "Successfully added Sonarr repo to apt"
