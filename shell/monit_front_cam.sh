#!/bin/bash
if ping -c 1 "$IPC_FRONT_IP" >/dev/null; then
	(
		sleep 3
		echo root
		sleep 3
		echo ismart12
		sleep 3
		echo /media/mmcblk0p2/data/etc/scripts/99-rtsp-check status
		echo wget -s "$HEALTHCHECKS_URL/ping/79ce12a6-bd81-4b8c-8105-31bb494be418"
		sleep 3
	) | telnet "$IPC_FRONT_IP" "$IPC_FRONT_PORT" | tee "$LOG_PATH/monit_cam/monit_front_cam.txt"
else
	# TODO: put KAKU behind cam, in order to power off/on
	echo "No response from $IPC_FRONT_IP"
fi
