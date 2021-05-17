#!/bin/bash

# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`


function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $UID -ne 0 ]
then
	RED "You must run this script as root!" && echo
	exit
fi


# Variables
PATH_CONFIG_SSHD="/etc/ssh/sshd_config"

USER=`logname`
NEW_PORT=`shuf -i 1000-65535 -n 1` #Attribut a new port for SSH
#echo $NEW_PORT
# Scripts

GREEN "Actual user: `logname`"
GREEN "New SSH PORT: $NEW_PORT"
echo " "

BLUE "=============================="
BLUE "Create copy of the config file"
cp "$PATH_CONFIG_SSHD" "$PATH_CONFIG_SSHD""_save"

# File editing 

## Change SSH PORT
BLUE "Change SSH PORT"
sed -i "s/#Port 22/Port $NEW_PORT/" $PATH_CONFIG_SSHD

## Remove X11 Forwarding
BLUE "Remove X11 Forwarding"
sed -i "s/X11Forwarding yes/X11Forwarding no/" $PATH_CONFIG_SSHD

## Limit SSH connexion only to the actual user
BLUE "Limit SSH connexion only to the actual user"
echo "AllowUsers `logname`" >> $PATH_CONFIG_SSHD

## Remove root connexion authorization
BLUE "Remove root connexion authorization"
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" $PATH_CONFIG_SSHD

RED "Restart the service"
/etc/init.d/ssh restart