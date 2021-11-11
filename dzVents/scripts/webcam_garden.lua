return {
	active = true,
	on = {
		devices = {'WebCam Tuin'}
	},
	execute = function(domoticz, webcam)
        if (webcam.state == 'On' and domoticz.devices('FIO - Wind').gustMs < 10.0) then
			domoticz.helpers.snapshotGarden(domoticz)
			domoticz.notify('Beweging in tuin', 'Foto wordt genomen...')
        end
	end
}
