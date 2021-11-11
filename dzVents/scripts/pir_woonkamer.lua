return {
	active = true,
	on = {
		devices = {'VS PIR Woonkamer'}
	},
	execute = function(domoticz, pirLivingRoom)
                if (pirLivingRoom.state == 'On'
                and domoticz.time.isNightTime
                --and domoticz.devices('PIRL Woonkamer').state == 'On' -- it's dark
                and domoticz.devices('VS Staande lamp').state == 'Off') then
                        domoticz.devices('VS Staande lamp').switchOn()
                end
	end
}
