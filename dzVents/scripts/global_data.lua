return {
    helpers = {
        sms = function(domoticz, subject, message)
            local text = subject .. ' ' .. message
            local previousText = domoticz.variables('SMS').value
            if (string.sub(previousText, 1, 3) ~= string.sub(text, 1, 3)) then -- save some money ;-)
                domoticz.executeShellCommand("(/root/scripts/sms.sh '" .. text .. "')&")
                domoticz.variables('SMS').set(text)
            end
        end,
        snapshotFront = function(domoticz)
            domoticz.executeShellCommand('(/root/scripts/front.sh)&')
        end,
        snapshotGarden = function(domoticz)
            domoticz.executeShellCommand('(/root/scripts/garden.sh)&')
        end
    }
}
