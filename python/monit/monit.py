#!/usr/bin/python3
import urllib.request, xml.etree.ElementTree as ET
import os

MONIT_URL = os.environ['MONIT_URL']
HEALTHCHECKS_URL = os.environ['HEALTHCHECKS_URL']

isMonitAlive = True
root = None
try:
    request = urllib.request.urlopen(f"{MONIT_URL}/_status?format=xml")
    root = ET.fromstring(request.read().decode())

except ValueError:
    isMonitAlive = False

allServicesAlive = isMonitAlive
if isMonitAlive:
    for status in root.iter('status'):
        if int(status.text) != 0:
            allServicesAlive = False
            break

urllib.request.urlopen(f"{HEALTHCHECKS_URL}/ping/ce7ae874-0d0d-4f7b-8f23-3e93231f831d" + ('/fail' if not isMonitAlive else ''))
urllib.request.urlopen(f"{HEALTHCHECKS_URL}/ping/09316e6e-b76b-4aed-8551-e91769836454" + ('/fail' if not allServicesAlive else ''))
