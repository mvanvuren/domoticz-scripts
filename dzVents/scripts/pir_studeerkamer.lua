local devicePirStudyRoom = 'PIR Studeerkamer'
local deviceHeatingEnabled = 'Tado Studeerkamer - Heating Enabled'
local deviceSetPoint = 'Tado Studeerkamer - Setpoint'
local deviceTemperature = 'Tado Studeerkamer - Temperatuur'
local setPoint = 19

return {
	active = true,
	on = {
                timer = { 'every 5 minutes' },
		devices = {devicePirStudyRoom}
	},
	execute = function(domoticz, item)
                if (item.isTimer) then
                        if (domoticz.devices(devicePirStudyRoom).lastUpdate.minutesAgo > 60
                        and domoticz.devices(deviceHeatingEnabled).state == 'On') then
                                domoticz.devices(deviceHeatingEnabled).switchOff()
                        end
                elseif (item.isDevice and item.active) then
                        if (domoticz.devices(deviceTemperature).temperature < setPoint
                        and domoticz.devices(deviceHeatingEnabled).state == 'Off') then
                                domoticz.devices(deviceHeatingEnabled).switchOn()
                                domoticz.devices(deviceSetPoint).updateSetPoint(setPoint)
                        end
                end

	end
}
