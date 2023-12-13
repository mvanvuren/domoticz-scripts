#!/bin/bash
if ping -c 1 "$IPC_FRONT_IP" >/dev/null; then
	(
		sleep 3
		echo "$IPC_FRONT_USR"
		sleep 3
		echo "$IPC_FRONT_PWD"
		sleep 3
		echo /media/mmcblk0p2/data/etc/scripts/99-rtsp-check status
		sleep 3
		echo wget -s -q "$HEALTHCHECKS_URL/ping/f1325ea9-be3e-41c8-bd99-5beb6829683f"
		sleep 3
	) | telnet "$IPC_FRONT_IP" "$IPC_FRONT_PORT" | tee "$LOG_PATH/monit_cam/monit_front_cam.txt"
else
	# TODO: put KAKU behind cam, in order to power off/on
	echo "No response from $IPC_FRONT_IP"
fi
