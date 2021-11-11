return {
	active = true,
	on = {
		devices = {'Keuken radio'}
	},
	execute = function(_, kitchenRadio)
        if (kitchenRadio.state == 'On') then
            kitchenRadio.update('Play')
        end
	end
}
