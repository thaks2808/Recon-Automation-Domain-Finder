#!/bin/bash
#Recon Automation: Active and Passive Recon
#see whois : see detail info about the domain using 'whois'
#find subdomains of the domain you want to perform Recon using subfinder,assetfinder,amass
#see if subdomains are alive using httprobe
#screenshot alive subdomains using gowitness

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots


if [ ! -d "$domain" ];then
    mkdir $domain
fi

if [ ! -d "$info_path" ];then
    mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
    mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
    mkdir $screenshot_path
fi

echo -e "${RED} [+] checking who it is ................... ${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Launching subfinder  ................... ${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder ................... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Running Amass. This could take a while! HAVE PATIENCE! ............. ${RESET}"
amass enum -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Checking what's alive! ............. ${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt

echo -e "${RED} [+] Taking Domain screenshots! ............. ${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http
