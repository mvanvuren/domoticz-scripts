#!/bin/bash

#setup
IDX_DOWNLOAD=271
IDX_UPLOAD=272
IDX_PING=273

LOG_FILE="${LOG_PATH}/speedtest/speedtest.txt"

/usr/bin/speedtest-cli --simple >"${LOG_FILE}"

download=$(printf "%.*f" 1 $(sed -ne 's/^Download: \([0-9]*\.[0-9]*\).*/\1/p' < "${LOG_FILE}"))
upload=$(printf "%.*f" 1 $(sed -ne 's/^Upload: \([0-9]*\.[0-9]*\).*/\1/p' < "${LOG_FILE}"))
png=$(printf "%.*f" 1 $(sed -ne 's/^Ping: \([0-9]*\.[0-9]*\).*/\1/p' < "${LOG_FILE}"))

# output if you run it manually
#echo "Download: $download Mbps"
#echo "Upload:   $upload Mbps"
#echo "Ping:     $png ms"

curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_DOWNLOAD}&nvalue=0&svalue=$download" >/dev/null 2>&1
curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_UPLOAD}&nvalue=0&svalue=$upload" >/dev/null 2>&1
curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=udevice&idx=${IDX_PING}&nvalue=0&svalue=$png" >/dev/null 2>&1

exit 0
