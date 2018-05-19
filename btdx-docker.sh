#!/bin/bash
set -u

DOCKER_REPO='dalijolijo'

#
# Set bitcloud user pwd and masternode genkey
#
echo -n "Enter new password for [bitcloud] user and Hit [ENTER]: "
read BTDXPWD
echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
read MN_KEY

#
# Check distro version for further configurations (TODO)
#
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Configurations for Ubuntu
if [[ $OS =~ "Ubuntu" ]] || [[ $OS =~ "ubuntu" ]]; then
    echo "Configuration for $OS ($VER)..."
 
    # Firewall settings (for Ubuntu)
    echo "Firewall settings"
    ufw logging on
    ufw allow 22/tcp
    ufw limit 22/tcp
    ufw allow 8329/tcp
    ufw allow 51473/tcp
    # if other services run on other ports, they will be blocked!
    #ufw default deny incoming 
    ufw default allow outgoing 
    yes | ufw enable

    # Installation further package (Ubuntu 16.04)
    echo "Installation further package"
    apt-get update
    sudo apt-get install -y apt-transport-https \
                           ca-certificates \
                           curl \
                           software-properties-common
else
    echo "Configure firewall settings for $OS ($VER) not supported!"
    exit
fi

#
# Pull docker images and run the docker container
#
docker pull ${DOCKER_REPO}/btdx-masternode
docker run -p 8329:8329 -p 51473:51473 --name btdx-masternode -e BTDXPWD="${BTDXPWD}" -e MN_KEY="${MN_KEY}" -v /home/bitcloud:/home/bitcloud:rw -d ${DOCKER_REPO}/btdx-masternode
