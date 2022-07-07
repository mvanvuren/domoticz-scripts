#!/usr/bin/python3
"""sets virtual sensor domoticz-uptime"""
import json
import os

import paho.mqtt.client as mqtt
from uptime import uptime

IDX = 205
MQTT_IP = os.environ["MQTT_IP"]


def format_uptime(uptime_in_seconds):
    """formats uptime seconds into days hours minutes"""
    (days, remainder) = divmod(uptime_in_seconds, 24 * 60 * 60)
    (hours, remainder) = divmod(remainder, 60 * 60)
    (minutes, remainder) = divmod(remainder, 60)

    return f"{days}d {hours}h {minutes}m"


def format_payload(svalue):
    """formats mqtt payload"""
    data = {"idx": IDX, "nvalue": 0, "svalue": svalue}
    return json.dumps(data)


def send_payload(payload):
    """send mqtt payload"""
    client = mqtt.Client("uptime")
    client.connect(MQTT_IP)
    client.publish("domoticz/in", payload)
    client.disconnect()


send_payload(format_payload(format_uptime(int(uptime()))))
