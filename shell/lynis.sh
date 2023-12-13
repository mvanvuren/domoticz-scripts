#!/bin/bash
set -u
DATE=$(date +%Y%m%d)
HOST=$(hostname)
LOG_DIR="${LOG_PATH}/lynis"
REPORT="${LOG_DIR}/report-${HOST}.${DATE}.txt"
DATA="${LOG_DIR}/report-data-${HOST}.${DATE}.txt"

/usr/local/lynis/lynis audit system --cronjob --quiet >"${REPORT}"

if [ -f /var/log/lynis-report.dat ]; then
	mv /var/log/lynis-report.dat "${DATA}"
fi

mutt -a "${REPORT}" -s "domoticz lynis report" -- "${MAILTO}" </dev/null

exit 0
