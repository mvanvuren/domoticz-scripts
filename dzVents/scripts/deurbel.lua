local device = 'Deurbel'

return {
	active = true,
	on = {
		devices = { device },
        shellCommandResponses = { 'callback' }
	},
	execute = function(domoticz, doorbell)
        if doorbell.isDevice then
            if (doorbell.state == 'Group On') then

                doorbell.switchOff().afterSec(30)

                domoticz.executeShellCommand({ 
                    command = '/root/scripts/front.sh',
                    callback = 'callback',
                    timeout = 60,
                })			

                if (domoticz.time.isNightTime) then
                    if (domoticz.devices('Hal lamp').state == 'Off') then
                        domoticz.devices('Hal lamp').switchOn()
                    end
                    if (domoticz.devices('Voordeur lamp').state == 'Off') then
                        domoticz.devices('Voordeur lamp').switchOn()
                    end
                end

                local subject = 'S04: iemand aan de deur'
                local message = 'foto\'s worden genomen'
                domoticz.notify(subject, message)
                if (domoticz.devices('Tado - Anyone').state == 'Off') then
                    domoticz.helpers.sms(domoticz, subject, message)
                end
            end
        elseif doorbell.isShellCommandResponse then
            if not doorbell.ok then
                domoticz.notify(doorbell.name, doorbell.errorText, domoticz.LOG_ERROR)
            end
        end
	end
}
