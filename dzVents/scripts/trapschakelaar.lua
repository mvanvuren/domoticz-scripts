local nameTrapschakelaar = 'Trap schakelaar'
local nameStaandeLamp = 'VS Staande lamp'
local nameOverloopLamp = 'Overloop lamp'

return {
	active = true,
	on = {
		devices = { nameTrapschakelaar }
	},
	execute = function(domoticz, dvTrapschakelaar)
        local dvStaandeLamp = domoticz.devices(nameStaandeLamp)
        if dvTrapschakelaar.active then
            if not dvStaandeLamp.active then
                dvStaandeLamp.switchOn()
            end
        else -- Off
            if dvStaandeLamp.active then
                dvStaandeLamp.switchOff()
            else
                domoticz.devices(nameOverloopLamp).switchOff()
            end
        end
	end
}
