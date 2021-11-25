#!/bin/bash
date "+%Y-%m-%d %H:%M:%S" >>"${LOG_PATH}/clear_cache.txt"
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches" >/dev/null 2>&1
