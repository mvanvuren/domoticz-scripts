#!/bin/bash
sudo dd bs=4M if=/dev/mmcblk0 | gzip >/mnt/diskstation/domoticzpi4.img.gz
