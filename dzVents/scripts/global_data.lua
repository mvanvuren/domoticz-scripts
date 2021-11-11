return {
    helpers = {
        sms = function(domoticz, subject, message)
            local text = subject .. ' ' .. message
            local previousText = domoticz.variables('SMS').value
            if (string.sub(previousText, 1, 3) ~= string.sub(text, 1, 3)) then -- save some money ;-)
                local sms_script = os.getenv('SMS_SCRIPT')
                os.execute("(" .. sms_script .. " '" .. text .. "')&")
                domoticz.variables('SMS').set(text)
            end
        end,
        snapshotFront = function()
            local front_script = os.getenv('FRONT_SCRIPT')
            os.execute("(" .. front_script .. ")&")
        end,
        snapshotGarden = function()
            local garden_script = os.getenv('GARDEN_SCRIPT')
            os.execute("(" .. garden_script .. ")&")
        end
    }
}
