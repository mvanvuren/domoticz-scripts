#!/usr/bin/python3
from libtado.api import Tado
import requests
import os

DOMO_URL = os.environ['DOMO_URL']
TADO_USR = os.environ['TADO_USR']
TADO_PWD = os.environ['TADO_PWD']
TADO_TOK = os.environ['TADO_TOK']

MARTIJN_IDX = 193
LEONIE_IDX = 209
ANYONE_IDX = 434

def updateStatusDomoticz(idx, atHome) :
	if (atHome is None) :
		return

	response = requests.get(f"{DOMO_URL}/json.htm?type=devices&rid={idx}") 
	if ((response.json()['result'][0]['Status'] == 'On') != atHome) :
		requests.get(f"{DOMO_URL}/json.htm?type=command&param=switchlight&idx={idx}&switchcmd=" + ('On' if atHome else 'Off'))

def getStatusTado() :
	tado = Tado(TADO_USR, TADO_PWD, TADO_TOK)

	users = tado.get_users()

	#print(users)

	martijnAtHome = users[1]['mobileDevices'][0]['location']
	if (martijnAtHome is not None) :
		martijnAtHome = martijnAtHome['atHome']

	leonieAtHome = users[0]['mobileDevices'][0]['location']
	if (leonieAtHome is not None) :
		leonieAtHome = leonieAtHome['atHome']

	return (martijnAtHome, leonieAtHome)

(martijnAtHome, leonieAtHome) = getStatusTado()

updateStatusDomoticz(MARTIJN_IDX, martijnAtHome)
updateStatusDomoticz(LEONIE_IDX, leonieAtHome)
updateStatusDomoticz(ANYONE_IDX, martijnAtHome or leonieAtHome)
