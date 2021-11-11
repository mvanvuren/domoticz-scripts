return {
    active = true,
    on = {
        devices = {"Woonkamerdeur"}
    },
    execute = function(domoticz, livingRoomDoor)
        if (livingRoomDoor.state == "Open" and domoticz.time.isNightTime) then
            if (domoticz.devices("Hal lamp").state == "Off") then
                domoticz.devices("Hal lamp").switchOn()
            end
            if (domoticz.devices("VS Staande lamp").state == "Off") then
                domoticz.devices("VS Staande lamp").switchOn()
            end
        end
    end
}
