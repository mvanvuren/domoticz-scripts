return {
	active = true,
	on = {
		timer = {'every 5 minutes'}
	},
	execute = function(domoticz)
        if (domoticz.devices('Slaapkamerraam').state == 'Open'
            or domoticz.devices('Badkamerraam').state == 'Open'
            or domoticz.devices('Schuifdeur Tuin').state == 'Open'
            or domoticz.devices('Voordeur').state == 'Open') then

            local min = math.fmod(domoticz.time.min + 5, 60)
            local hour = domoticz.time.hour;
            if (min == 0) then hour = math.fmod(hour + 1, 24) end
            local stime = hour..':'..min

            local handle = io.popen("curl --max-time 5 "..
                "'https://br-gpsgadget-new.azurewebsites.net/data/raintext?lat=52.23&lon=5.18' 2>/dev/null "..
                "| grep "..stime.." "..
                "| tr -d '\r\n' "..
                "| cut -c-3")
            local response = handle:read("*a")
            handle:close()

            if (response ~= nil) then
                local rainindex=tonumber(response)
                if (rainindex ~= nil and rainindex > 76) then -- >= 0.1mm
                    local rain = math.pow(10, (rainindex - 109) / 32)
                    local subject = 'Regen over 5 minuten ('..string.sub(rain,1,3)..' mm/uur)'
                    local message = ''
                    if (domoticz.devices('Slaapkamerraam').state == 'Open') then
                        message = message.."Het slaapkamerraam staat open.\n"
                    end
                    if (domoticz.devices('Badkamerraam').state == 'Open') then
                        message = message.."Het badkamerraam staat open.\n"
                    end
                    if (domoticz.devices('Schuifdeur Tuin').state == 'Open') then
                        message = message.."De schuifdeur staat open.\n"
                    end
                    if (domoticz.devices('Voordeur').state == 'Open') then
                        message = message.."De voordeur staat open.\n"
                    end

                    domoticz.notify(subject, message)
                end
            end
        end
	end
}
