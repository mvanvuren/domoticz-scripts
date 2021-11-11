return {
	active = true,
	on = {
		timer = {'every 5 minutes'}
	},
	execute = function(domoticz)
        if (domoticz.devices('BR - Het Regent')).state == 'On' then
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
            if (message ~= '') then
                local subject = 'Ramen sluiten!'
                domoticz.notify(subject, message)
            end
        end
	end
}
