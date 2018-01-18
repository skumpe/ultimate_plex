#!/bin/bash

#Make errors red and scary
error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

#Make good things green and happy
message() {
  printf '\E[32m'; echo "$@"; printf '\E[0m'
}

#Make infos white
info() {
  echo "$@"
}

#Check if run as root or with sudo, error and exit if not
if [[ $EUID -gt 0 ]]; then
            error "This script MUST be run using sudo or as the root user"
            exit 1
    else
	    message "Script run as root or with sudo - yay! This is necessary to complete all the needed tasks, if it freaks you out please press Ctrl-C to exit. I will wait 10 seconds just in case"
	    sleep 10
fi

#Get the current directory for future use
$APPDIR = $(/bin/pwd)

#Add the plex user, for now with no password to prevent remote logins, may change in future
info "Adding plex user"
/usr/sbin/useradd -m -s /bin/bash plex
message "Successfully added Plex user"

#add the keys and repos, test to see if silent! (its probably not)
info "Adding needed repos and corresponding keys"
/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC > /dev/null 2>&1
info "deb http://apt.sonarr.tv/ master main" > /etc/apt/sources.list.d/sonarr.list
message "Successfully added Sonarr repo to apt"
/usr/bin/add-apt-repository -y ppa:jcfp/nobetas > /dev/null 2>&1
message "Successfully added SABnzbd repo to apt"

#update apt repo data, install Sonarr and change ownership to the plex user (dont freak out about the package name, Sonarr used to be NZBDrone)
info "Installing Sonarr and dependencies..."
/usr/bin/apt-get update > /dev/null 2>&1
/usr/bin/apt-get install nzbdrone -y > /dev/null 2>&1
/bin/chown -R plex: /opt/NzbDrone
message "Sonarr installed successfully"

#And now install Radarr dependencies
info "Installing Radarr dependencies..."
/usr/bin/apt-get install libmono-cil-dev curl mediainfo -y > /dev/null 2>&1
message "Radarr deps installed successfully"

#With the deps isntalled, time to install Radarr. Its currently in beta and there is no repo, so we need to get it from github and unpack it, etc
info "Downloading and installing Radarr..."
/bin/mkdir -p /root/Downloads
cd /root/Downloads
/usr/bin/wget -q $( /usr/bin/curl -s https://api.github.com/repos/Radarr/Radarr/releases | /bin/grep linux.tar.gz | /bin/grep browser_download_url | /usr/bin/head -1 | /usr/bin/cut -d \" -f 4 )
/bin/tar -xf Radarr.*.linux.tar.gz
/bin/mv /root/Downloads/Radarr /opt/Radarr
/bin/chown -R plex: /opt/Radarr
message "Radarr installed successfully"

#Copy the systemd service file for Sonarr in to place, enable during startup, and start the service
/bin/cp -fr $APPDIR/sonarr.service /etc/systemd/system/
/bin/systemctl daemon-reload
/bin/systemctl enable sonarr.service > /dev/null 2>&1
/bin/systemctl start sonarr.service
message "Sonar service installed, enabled to start on boot, and started" 
