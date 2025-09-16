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
    for k, v in pairs(data) do
        ClanRestrictionsData[k] = v
    end
    for k, _ in pairs(ClanRestrictionsData) do
        if data[k] == nil then
            ClanRestrictionsData[k] = nil
        end
    end
    ModData.add("ClanRestrictionsData", ClanRestrictionsData)
    ModData.transmit("ClanRestrictionsData")
    return ClanRestrictionsData
end

function ClanRestrictions.initServer()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
    ModData.add("ClanRestrictionsData", ClanRestrictionsData)
end
Events.OnInitGlobalModData.Add(ClanRestrictions.initServer)

function ClanRestrictions.OnReceiveGlobalModData(key, data)
    if key == "ClanRestrictionsData" or key == "ClanRestrictions" then
        ClanRestrictions.updateData(data)
    end
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.OnReceiveGlobalModData)

function ClanRestrictions.sync(module, command, player, args)
    if module ~= "ClanRestrictions" then return end

    if command == "Update" and args.data then
        ClanRestrictions.updateData(args.data)
    elseif command == "RequestSync" then
        sendServerCommand(player, "ClanRestrictions", "Update", { data = ClanRestrictionsData })
    elseif command == "Assign" and args.data then
    end
end
Events.OnClientCommand.Add(ClanRestrictions.sync)
