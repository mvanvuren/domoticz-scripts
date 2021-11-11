return {
	active = true,
	on = {
        devices = {'Voordeur'},
		timer = {'every minute'}
	},
    data = {
        frontDoorLastState = { initial = 'Closed' }
    },
    logging = {
        level = domoticz.LOG_ERROR
    },
	execute = function(domoticz, frontDoor, triggerInfo)

        if (triggerInfo.type == domoticz.EVENT_TYPE_DEVICE) then
            if (frontDoor.state == 'Open' and domoticz.time.isNightTime) then
                if (domoticz.devices('Hal lamp').state == 'Off') then
                    domoticz.devices('Hal lamp').switchOn()
                end
                if (domoticz.devices('VS Staande lamp').state == 'Off') then
                    domoticz.devices('VS Staande lamp').switchOn()
                end
            end
            domoticz.data.frontDoorLastState = frontDoor.state
        end

        if (triggerInfo.type == domoticz.EVENT_TYPE_TIMER) then
            frontDoor = domoticz.devices('Voordeur')
            if (frontDoor.state == 'Open'
                and domoticz.data.frontDoorLastState == 'Open'
                and frontDoor.lastUpdate.minutesAgo >= 10
                and frontDoor.lastUpdate.minutesAgo < 60) then -- stop notifying after 60 minutes

                local subject = 'S02: voordeur open'
                local message = '' --'De voordeur staat al '..frontDoor.lastUpdate.minutesAgo..' minuten open!'

                domoticz.helpers.sms(domoticz, subject, message)
                domoticz.notify(subject, message)
            end
        end

	end
}
