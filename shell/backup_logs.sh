#!/bin/bash
BACKUPFOLDER="${BACKUP_LOGS_PATH}/$(/bin/date +"%Y%m%d")"
mkdir -p "${BACKUPFOLDER}"
find /var/log -name '*.gz' -exec mv {} "${BACKUPFOLDER}" \;
