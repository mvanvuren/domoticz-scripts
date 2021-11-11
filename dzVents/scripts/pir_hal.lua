return {
	active = true,
	on = {
		devices = {'VS PIR Hal'}
	},
	execute = function(domoticz, pirHall)
		if (pirHall.state == 'On'
		and domoticz.time.isNightTime
		and domoticz.devices('Hal lamp').state == 'Off') then
			domoticz.devices('Hal lamp').switchOn()
		end
	end
}
