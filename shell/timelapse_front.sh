#!/bin/bash
minimumsize=10

log2domo() {
	script="(Script: $(basename $0))"
	message=$(echo -n "$script $1" | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
	curl -s -i -H "Accept: application/json" "${DOMO_URL}/json.htm?type=command&param=addlogmessage&message=$message" >/dev/null 2>&1
}

sunrise=$(curl -s "${DOMO_URL}/json.htm?type=command&param=getSunRiseSet" | jq -r '.Sunrise')
sunset=$(curl -s "${DOMO_URL}/json.htm?type=command&param=getSunRiseSet" | jq -r '.Sunset')

now=$(date +"%H:%M:%S")
if [[ "$now" > "$sunrise" ]] && [[ "$now" < "$sunset" ]]; then 

	log2domo "Start..."

	if ping -c 1 $IPC_FRONT_IP >/dev/null; then

		Now=$(/bin/date +%Y%m%d%H%M%S)
		SnapFile="${PHOTO_PATH}/timelapse/front/timelapse$Now.jpg"

		ffmpeg -rtsp_transport tcp -i "rtsp://${IPC_FRONT_IP}/unicast" -r 1 -vframes 1 $SnapFile >/dev/null 2>&1
		#sleep 1

		actualsize=$(du -k "$SnapFile" | cut -f 1)
		if [ $actualsize -ge $minimumsize ]; then
			echo "$SnapFile"
			log2domo "$SnapFile"
		else
			if [ -e $SnapFile ]; then
				rm $SnapFile # something went wrong
			fi
			log2domo "ERROR: $SnapFile"
		fi
	else
		log2domo "ERROR: ping ${IPC_FRONT_IP} failed" # script monit_front_cam.sh should be able to fix this
	fi

	log2domo "Finished"
fi
