return {
	active = true,
	on = {
		devices = {'woonkamer - CO2'}
	},
	execute = function(domoticz, livingRoom)
        if (livingRoom.co2 > 1500
            and domoticz.devices('Schuifdeur Tuin').state == 'Closed') then

            local subject = 'S01: CO2 niveau'
            local message = livingRoom.co2 .. 'PPM. Zet schuifdeur open!'

            domoticz.helpers.sms(domoticz, subject, message)
            domoticz.notify(subject, message, domoticz.PRIORITY_HIGH, nil, nil, domoticz.NSS_TELEGRAM)
        end
	end
}
