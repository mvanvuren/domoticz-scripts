#!/usr/bin/python3
"""bridge between monit and healtchecks for failing services"""
import os
import urllib.request
import xml.etree.ElementTree as ET

MONIT_URL = os.environ["MONIT_URL"]
HEALTHCHECKS_URL = os.environ["HEALTHCHECKS_URL"]


def get_monit_data():
    """retrieve information from monit api"""
    try:
        request = urllib.request.urlopen(f"{MONIT_URL}/_status?format=xml")
        root = ET.fromstring(request.read().decode())

    except ValueError:
        return (False, False)

    for status in root.iter("status"):
        if int(status.text) != 0:
            return (True, False)

    return (True, True)


def update_healthchecks(is_monit_alive, all_services_alive):
    """update healtchecks"""
    urllib.request.urlopen(
        f"{HEALTHCHECKS_URL}/ping/316afc48-66ab-4f8b-93aa-d136fce90591"
        + ("/fail" if not is_monit_alive else "")
    )
    urllib.request.urlopen(
        f"{HEALTHCHECKS_URL}/ping/a1eb7af1-7fe8-4934-b836-2965c8084967"
        + ("/fail" if not all_services_alive else "")
    )


update_healthchecks(*get_monit_data())
