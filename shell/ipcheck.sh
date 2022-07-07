#!/bin/bash

log2domo() {
	script="(Script: $(basename "$0"))"
	message=$(echo -n "$script $1" | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
	curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=addlogmessage&message=$message" >/dev/null 2>&1
}

log2domo "Started..."

datestamp=$(date '+%Y-%m-%d %H:%M:%S')

# the actual command getting the public IP, change the
# URL to your php hosting if you have one
myipnow=$(wget -4 -qO - icanhazip.com)

previp="0.0.0.0"

logfile="${LOG_PATH}/ipcheck/log.txt" #create this file yourself
iplog="${LOG_PATH}/ipcheck/ip.log"    #create this file yourself

if [ -f "$iplog" ]; then
	previp=$(cat "$iplog")
fi

if [ "$myipnow" != "$previp" ]; then
	#ip changed, sending alert
	/bin/bash "${TELEGRAM_SCRIPT}" "IP-adres gewijzigd: $previp => $myipnow"
	/bin/bash "${MAIL_SCRIPT}" "IP-adres gewijzigd" "$previp => $myipnow"

	#write the new ip to log file
	echo "$myipnow" >"$iplog"

	message="$datestamp IP changed. $previp => $myipnow"
	echo "$message" >>"$logfile"
	log2domo "$message"
else
	echo "$datestamp IP is same. $myipnow" >>"$logfile"
fi
log2domo "Finished"
