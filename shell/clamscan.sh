#!/bin/bash
LOG_FILE="${LOG_PATH}/clamav/clamav-$(date +'%Y-%m-%d').log"
MAIL_MSG="Please see the log file attached."
DIRTOSCAN="/root"

for S in ${DIRTOSCAN}; do
	DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1)

	echo "Starting a weekly scan of $S directory. Amount of data to be scanned is $DIRSIZE."

	clamscan -ri "${S}" >>"${LOG_FILE}"

	# get the value of "Infected lines"
	MALWARE=$(tail "${LOG_FILE}" | grep Infected | cut -d" " -f3)

	# if the value is not equal to zero, send an email with the log file attached
	if [ "${MALWARE}" -ne "0" ]; then
		echo "${MAIL_MSG}" | mail -A "${LOG_FILE}" -s "Malware Found" "${MAILTO}"
	fi
done

exit 0
