local authorization = "testing" -- < Should change that y'know

local customData = {}

SetHttpHandler(function(req, res)
    for k,v in pairs(req.headers)do
        if(k == "Authorization")then
            -- Little hack as prometheus doesn't support setting raw auth headers
            if(v == "Bearer " .. authorization)then
                local custom = ""

                for Kc, Vc in pairs(customData) do
                    custom = custom .. "\nfivem_" .. Kc .. " " .. Vc
                end

                res.send("fivem_num_players " .. #GetPlayers() ..
                        "\nfivem_num_resources " .. GetNumResources() .. custom)
            else
                print("Auth attempt: " .. v)
                res.send(json.encode({ error = 'Incorrect authorization header'}))
            end

            return
        end
    end

	res.send(json.encode({ error = 'No authorization header found'}))
end)

AddEventHandler("fivem_prometheus:addMetric", function(key, value)
    customData[key] = value
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4000)

        TriggerEvent("fivem_prometheus:addMetric", "customDataPoint", math.random(3, 100))
    end
end)