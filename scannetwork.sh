#!/bin/bash

#specify color for echo output
Red='\033[0;31m'
BRed='\033[1;31m'
Green='\033[0;32m'
BGreen='\033[1;32m'
Color_Off='\033[0m'

#check for argument
if [[ $# -lt 1 ]];then
        printf "${BRed}[-] Please specify a range of ip's${Color_Off}\n"
        printf "[+] example '192.168.1.0/24'\n"
	printf "[+] example '192.168.1.1-100'\n"
        exit 1 #exit the script
fi

#check for scannetwork dir
if [ ! -d scan_results ]; then
	printf "[-] scan_results directory not present yet.\n"
	printf "[+] making directory right now.\n"
	mkdir scan_results
fi

#check if scannetwork subdir exists to store our results
if [ ! -d scan_results/$1 ]; then
	printf "[-] scan_results/$1 directory not present yet.\n"
	printf "[+] making directory right now\n"
	mkdir scan_results/$1
fi

#ping sweep all network for alive hosts
printf "[+] Sweeping Network...\n"
nmap -sn $1 | grep "report" | cut -d" " -f 5 > ips.txt

#print live hosts
for host in $(cat ips.txt); do
	printf "${Green}[+] Alive host on IP: ${BGreen}$host${Color_Off}\n"
done

#full port scan on all alive hosts
printf "[+] scanning all hosts alive...\n"
for ip in $(cat ips.txt | cut -d" " -f 5); do
        printf "[+] scanning for open ports on host $ip\n"
	mkdir scan_results/$1/$ip
        nmap -p- -Pn $ip > scan_results/$1/$ip/$ip
done
printf "[+] full port scan has been performed on all alive hosts\n"
printf "[+] time for detailed scan...\n"
for ip in $( ls scan_results/$1/ | cut -d"." -f1,2,3,4); do
	printf "\n${Red}============================================\n${Color_Off}"
        printf "${Red}[+] scanning for ip $ip:\n${Green}"
	printf "${Red}============================================\n\n${Color_Off}"
        for port in $(cat scan_results/$1/$ip/$ip | grep "/tcp" | cut -d"/" -f1); do
		echo "$port" >> scan_results/$1/$ip/ports
        done
        printf "\n"
	nmap -sC -sV -p$(cat scan_results/$1/$ip/ports | tr "\n" ", ") $ip -oN scan_results/$1/$ip/$ip.full >/dev/null
	cat scan_results/$1/$ip/$ip.full
	printf "\n"
done

printf "${BGreen}[+] The script has finished!${Color_Off}\n"
printf "${Green}Results can be checked in each Directory in scan_results/$1/\n"
exit 1
