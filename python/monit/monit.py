#!/usr/bin/python3
"""bridge between monit and healtchecks for failing services"""
import urllib.request
import xml.etree.ElementTree as ET
import os

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
        f"{HEALTHCHECKS_URL}/ping/ce7ae874-0d0d-4f7b-8f23-3e93231f831d"
        + ("/fail" if not is_monit_alive else "")
    )
    urllib.request.urlopen(
        f"{HEALTHCHECKS_URL}/ping/09316e6e-b76b-4aed-8551-e91769836454"
        + ("/fail" if not all_services_alive else "")
    )


update_healthchecks(*get_monit_data())
