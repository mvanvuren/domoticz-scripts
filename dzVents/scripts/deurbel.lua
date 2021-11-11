return {
	active = true,
	on = {
		devices = {'Deurbel'}
	},
	execute = function(domoticz, doorbell)
        if (doorbell.state == 'Group On') then

            doorbell.switchOff().afterSec(30)

            domoticz.helpers.snapshotFront(domoticz)

            if (domoticz.time.isNightTime) then
                if (domoticz.devices('Hal lamp').state == 'Off') then
                    domoticz.devices('Hal lamp').switchOn()
                end
                if (domoticz.devices('Voordeur lamp').state == 'Off') then
                    domoticz.devices('Voordeur lamp').switchOn()
                end
            end

            local subject = 'S04: iemand aan de deur'
            local message = 'Kijk in Telegram!'
            domoticz.notify(subject, message)
            if (domoticz.devices('Tado - Anyone').state == 'Off') then
               domoticz.helpers.sms(domoticz, subject, message)
            end
        end
	end
}
