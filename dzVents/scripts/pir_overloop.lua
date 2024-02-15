local devicePirOverloop = 'PIR Overloop'
local deviceOverloopLamp = 'Overloop lamp'

return {
	active = true,
	on = {
		devices = { devicePirOverloop }
	},
	execute = function(domoticz, pirOverloop)
    if pirOverloop.active then
      local level = 10
      if domoticz.time.hour >= 8 and domoticz.time.hour < 23 then
        level = 50
      end
      local lastLevel = domoticz.devices(deviceOverloopLamp).lastLevel
      if lastLevel ~= level then
        domoticz.devices(deviceOverloopLamp).setLevel(level).repeatAfterSec(5)
      else
        domoticz.devices(deviceOverloopLamp).switchOn().repeatAfterSec(5)
      end
    else
      domoticz.devices(deviceOverloopLamp).switchOff()
    end
	end
}
