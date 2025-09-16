----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

--server/ClanRestrictions_Server.lua

if isClient() then return end
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.updateData(data)
    for dataKey, value in pairs(data) do
        ClanRestrictionsData[dataKey] = value
    end        
    for dataKey, _ in pairs(ClanRestrictionsData) do
        if data[dataKey] == nil then
            ClanRestrictionsData[dataKey] = nil
        end
    end        
    return ClanRestrictionsData
end

function ClanRestrictions.initServer()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end
Events.OnInitGlobalModData.Add(ClanRestrictions.initServer)

function ClanRestrictions.OnReceiveGlobalModData(key, data)
    if key == "ClanRestrictionsData" or  key == "ClanRestrictions" then
        ClanRestrictions.updateData(data)  
        ModData.transmit("ClanRestrictionsData")

    end  
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.OnReceiveGlobalModData)

function ClanRestrictions.sync(module, command, player, args)
    if module == "ClanRestrictions" then 
        if command == "Update" and args.data then
            ClanRestrictionsData = args.data
            ModData.add('ClanRestrictionsData', ClanRestrictionsData)
            ModData.transmit("ClanRestrictionsData")
        elseif command == "RequestSync" then
            sendServerCommand(player, "ClanRestrictions", "Update", {data = ClanRestrictionsData})
        elseif command == "Check" then
        elseif command == "Assign" then
            if not args.data then return end
        end
        sendServerCommand(player, "ClanRestrictions", tostring(command), args)
    end
end
Events.OnClientCommand.Add(ClanRestrictions.sync)

