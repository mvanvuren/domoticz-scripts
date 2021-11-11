return {
	active = true,
	on = {
		devices = {'Trap schakelaar'}
	},
	execute = function(domoticz, switch)
        if (switch.state == 'On') then

            if (domoticz.devices('VS Staande lamp').state == 'Off') then
                domoticz.devices('VS Staande lamp').switchOn()
            end
        else -- Off
            if (domoticz.devices('VS Staande lamp').state == 'On') then
                domoticz.devices('VS Staande lamp').switchOff()
            else
                domoticz.devices('Overloop lamp').switchOff()
            end
        end
	end
}
