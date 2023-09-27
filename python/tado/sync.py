#!/usr/bin/python3
"""update presence from Tado"""
import os

import requests
from libtado.api import Tado

DOMO_URL = os.environ["DOMO_URL"]
TADO_USR = os.environ["TADO_USR"]
TADO_PWD = os.environ["TADO_PWD"]
TADO_TOK = os.environ["TADO_TOK"]

MARTIJN_IDX = 193
LEONIE_IDX = 209
ANYONE_IDX = 434


def update_status_domoticz(idx, at_home):
    """update status in domoticz"""
    if at_home is None:
        return

    response = requests.get(f"{DOMO_URL}/json.htm?type=devices&rid={idx}", verify='/root/.local/share/mkcert/rootCA.pem')
    # print(response.json())
    if (response.json()["result"][0]["Status"] == "On") != at_home:
        requests.get(
            f"{DOMO_URL}/json.htm?type=command&param=switchlight&idx={idx}&switchcmd="
            + ("On" if at_home else "Off")
            , verify='/root/.local/share/mkcert/rootCA.pem'
        )


def get_status_tado():
    """get status tado"""
    tado = Tado(TADO_USR, TADO_PWD, TADO_TOK)

    users = tado.get_users()
    # print(users)
    martijn_at_home = users[1]["mobileDevices"][0]["location"]
    if martijn_at_home is not None:
        martijn_at_home = martijn_at_home["atHome"]

    leonie_at_home = users[0]["mobileDevices"][0]["location"]
    if leonie_at_home is not None:
        leonie_at_home = leonie_at_home["atHome"]

    return (martijn_at_home, leonie_at_home)


(martijn, leonie) = get_status_tado()

update_status_domoticz(MARTIJN_IDX, martijn)
update_status_domoticz(LEONIE_IDX, leonie)
update_status_domoticz(ANYONE_IDX, martijn or leonie)
