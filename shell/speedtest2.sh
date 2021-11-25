#!/bin/bash

#setup
IDX_DOWNLOAD=271
IDX_UPLOAD=272
IDX_PING=273

json=$(/usr/bin/speedtest-cli --json) 

ping=$(printf "%.*f" 0 "$(echo "$json" | jq '.ping')")
download=$(printf "%.*f" 0 "$(echo "$json" | jq '.download')")
download=$((download / 1048578))
upload=$(printf "%.*f" 0 "$(echo "$json" | jq '.upload')")
upload=$((upload / 1048578))

# output if you run it manually
#echo "ping:     $ping ms"
#echo "download: $download Mbps"
#echo "upload:   $upload Mbps"

curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_PING}&nvalue=0&svalue=$ping" >/dev/null 2>&1
curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_DOWNLOAD}&nvalue=0&svalue=$download" >/dev/null 2>&1
curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_UPLOAD}&nvalue=0&svalue=$upload" >/dev/null 2>&1

exit 0
