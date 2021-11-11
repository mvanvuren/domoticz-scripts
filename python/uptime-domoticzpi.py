#!/usr/bin/python3
import paho.mqtt.client as mqtt
from uptime import uptime

uptime = uptime()

(days, remainder) = divmod(uptime, 24 * 60 * 60)
(hours, remainder) = divmod(remainder, 60 * 60)
(minutes, remainder) = divmod(remainder, 60)

svalue = ("%dd %dh %dm" % (days, hours, minutes))

payload = '{ "idx":%d,"nvalue":0,"svalue":"%s" }' % (205, svalue)

client = mqtt.Client('uptime')
client.connect("127.0.0.1")
client.publish('domoticz/in', payload)
client.disconnect()
