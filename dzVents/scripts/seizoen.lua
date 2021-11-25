return {
	active = true,
	on = {
		timer = {'at 00:00'}
	},
	execute = function(domoticz)
            local season = domoticz.variables('season').value
            if domoticz.time.day >= 21 then
                if     domoticz.time.month ==  3 then
                    season = 'spring'
                elseif domoticz.time.month ==  6 then
                    season = 'summer'
                elseif domoticz.time.month ==  9 then
                    season = 'autumn'
                elseif domoticz.time.month == 12 then
                    season = 'winter'
                end
                if (season ~= domoticz.variables('season').value) then
                    domoticz.variables('season').set(season)
                    domoticz.notify('nieuw seizoen', season)
                end
            end
	    end
}
