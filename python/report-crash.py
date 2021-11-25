#!/usr/bin/python3
import os

DOMO_PATH = os.environ['DOMO_PATH']
REPORT = f"{DOMO_PATH}/domoticz_crash.log"
SUBJECT = 'domoticz crash report'
MAILTO = os.environ['MAILTO']



if os.path.exists(REPORT):
    command = f"mutt -a {REPORT} -s \"{SUBJECT}\" -- {MAILTO} </dev/null"
    os.system(command)
    os.remove(REPORT)
