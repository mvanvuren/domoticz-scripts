local device = 'WebCam Tuin'

return {
	active = true,
	on = {
		devices = { device },
        shellCommandResponses = { 'callback' }
	},
	execute = function(domoticz, webcam)
        if webcam.isDevice then
            if (webcam.state == 'On' and domoticz.devices('BR - Wind').gustMs < 10.0) then
                domoticz.notify(webcam.name, 'start...')
                domoticz.executeShellCommand({
                    command = '/root/scripts/garden.sh',
                    callback = 'callback',
                    timeout = 60,
                })
            end
        elseif webcam.isShellCommandResponse then
            if not webcam.ok then
                domoticz.notify(webcam.name, webcam.errorText, domoticz.LOG_ERROR)
            end
        end
	end
}
