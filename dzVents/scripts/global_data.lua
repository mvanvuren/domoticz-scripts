return {
    helpers = {
        sms = function(domoticz, subject, message)
            local text = subject .. ' ' .. message
            local smsVariable = domoticz.variables('SMS')
            local previousText = smsVariable.value
            if (smsVariable.lastUpdate.daysAgo > 0
                and string.sub(previousText, 1, 3) ~= string.sub(text, 1, 3)) then -- save some money ;-)
                domoticz.executeShellCommand("(/root/scripts/sms.sh '" .. text .. "')&")
                smsVariable.set(text)
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
