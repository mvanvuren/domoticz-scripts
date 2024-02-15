local devicePirOverloop = 'PIR Overloop'
local deviceOverloopLamp = 'Overloop lamp'

return {
	active = true,
	on = {
		devices = { devicePirOverloop }
	},
	execute = function(domoticz, pirOverloop)
    domoticz.log('PIR Overloop TRIGGER', domoticz.LOG_FORCE)
    if pirOverloop.active then
      --domoticz.log('PIR Overloop ON', domoticz.LOG_FORCE)
      --if (domoticz.time.isNightTime) then
        -- local level = time_condition and 15 or 5
        local level = 10
        if domoticz.time.hour >= 8 and domoticz.time.hour < 23 then
          level = 50
        end
        local lastLevel = domoticz.devices(deviceOverloopLamp).lastLevel
        --domoticz.log(lastLevel, domoticz.LOG_FORCE)
        if lastLevel ~= level then
          domoticz.devices(deviceOverloopLamp).setLevel(level).repeatAfterSec(5)
        else
          domoticz.devices(deviceOverloopLamp).switchOn().repeatAfterSec(5)
        end
      --end
    else
      --domoticz.log('PIR Overloop OFF', domoticz.LOG_FORCE)
      --domoticz.log(pirOverloop.state, domoticz.LOG_FORCE)
      domoticz.devices(deviceOverloopLamp).switchOff()
    end
	end
}
