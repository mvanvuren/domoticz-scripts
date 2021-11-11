return {
	active = true,
    on = {
        devices = {'Keukenafvoer Alarm'}
    },
    execute = function(domoticz, kitchenAlarm)
        if (kitchenAlarm.state == 'On') then
            local subject = 'S03: keukenafvoer'
            local message = 'Water gedetecteerd onder in keukenkastje!'

            domoticz.helpers.sms(domoticz, subject, message)
            domoticz.notify(subject, message)
        end
	end
}