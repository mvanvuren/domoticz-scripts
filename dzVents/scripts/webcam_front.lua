return {
	active = true,
	on = {
		devices = {'WebCam Voorkant'}
	},
	execute = function(domoticz, webcam)
		if (webcam.state == 'On' and domoticz.devices('FIO - Wind').gustMs < 10.0) then
			domoticz.helpers.snapshotFront(domoticz)
		    domoticz.notify('Beweging bij voordeur (camera)', 'Foto wordt genomen...')
		end
	end
}
