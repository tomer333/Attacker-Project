#!/bin/bash

#Author:  TOMER DAHAN
#Github:  https://github.com/tomer333/
#Social:  https:https://www.linkedin.com/in/tomer-dahan-375540235/
#Version: 1.0

#Project Cyber Warfare - Attacker

### scan.sh - a thread program for attacker.sh

#Mapping ports, services, versions and versions vulnerabilities of the ip.
#Uses the directory Targets for ip list.
#
#Scanning and Enumeration
#	-The code should scan and enumerate random ports and IPs
#	-Scanning can be done by Shodan, Masscan, and Nmap (This version only nmap!!).

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

#Global vars
targetList=$1
sensitiveList="./Targets/.sensitive.lst"
startPort=20 #1
endPort=25 #65535
ip_count=0
port_count=0

#initializes files for logs
echo "${BLUE}Nmap results:" > ./logs/results.log
echo "${BLUE}vulnerabilities results:" > ./logs/vul.log
echo "${BLUE}Sensitive IPs log:" > ./logs/.sensitive.log
echo "${WHITE}Nmap Count of IPs and Ports scanned: ${RED}IPs: 0 ${GREEN}Ports: 0" > ./logs/count.log

#Big loop runs through the ports in random
# shuf - Shuffle ports
for port in $(seq $startPort $endPort | shuf)
do
	#counts ports
	let "port_count+=1"
	
	#loop that runs through the ip targets in random
	for target in $(cat $targetList | shuf)
	do
		#counts the number of ip targets one time
		if [ "$port_count" == "1" ]
		then
			let "ip_count+=1"
		fi
		scan=$(nmap -Pn -sV $target -p $port -oX res.xml)
		status=$(echo "$scan" | grep open | awk '{print $2}')
		searchsploit --nmap res.xml > temp.txt 2> /dev/null
		vulnerabilities=$(cat temp.txt | grep -v "No Results" | grep "\S")
		
		#when port is open enter data to logs
		if [ "$status" == "open" ]
		then
			# Extract result details
			service=$(echo "$scan" | grep open | awk '{print $3}')
			version=$(echo "$scan" | grep open | awk '{for(i=4;i<=NF;++i){printf $i; printf " "}}')
			time=$(echo "$scan" | grep "Starting Nmap" | awk '{print $(NF-2), $(NF-1)}')
			if [ "$version" == "" ]
			then
				version="none"
			fi
			data="${RED}IP: ${WHITE}$target ${RED}Time & Date: ${MAGENTA}$time ${RED}Open ${GREEN}Port/${ORANGE}Service/${CYAN}Version: ${GREEN}$port/${ORANGE}$service/${CYAN}$version"
			echo "$data" >> ./logs/results.log
			
			#send to brute force
			echo "$data" > To_Brute.lst
			sudo bash brute.sh
			printf "${GREEN}IP: ${ORANGE}$target ${GREEN}Port: ${ORANGE}$port ${GREEN}Version: ${ORANGE}$version ${RED}Vulnerabilities:\n\n${WHITE}$vulnerabilities\n\n" >> ./logs/vul.log
			if [ "$(cat $sensitiveList | grep -o "$target")" != "" ]
			then
				echo "$data" >> ./logs/.sensitive.log
			fi
		fi
		echo "${WHITE}Nmap Count of IPs and Ports scanned: ${RED}IPs: $ip_count ${GREEN}Ports: $port_count" > ./logs/count.log
	done 
done
