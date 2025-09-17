-- client/ClanRestrictions_Data.lua
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.init()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end
Events.OnInitGlobalModData.Add(ClanRestrictions.init)

function ClanRestrictions.receivedData(key, data)
    if key == "ClanRestrictionsData" then
        for k, v in pairs(data) do
            ClanRestrictionsData[k] = v
        end
        for k in pairs(ClanRestrictionsData) do
            if data[k] == nil then
                ClanRestrictionsData[k] = nil
            end
        end
    end
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.receivedData)

function ClanRestrictions.sendToServer()
    if isClient() then
        sendClientCommand("ClanRestrictions", "Update", { data = ClanRestrictionsData })
    end
end

function ClanRestrictions.request()
    if isClient() then
        sendClientCommand("ClanRestrictions", "RequestSync", {})
    end
end

function ClanRestrictions.core(module, command, args)
    if module ~= "ClanRestrictions" then return end
    if command == "Update" and args.data then
        for k, v in pairs(args.data) do
            ClanRestrictionsData[k] = v
        end
    elseif command == "Msg" and args.msg then
        local pl = getPlayer()
        if pl then
            pl:setHaloNote(tostring(args.msg),150,250,150,400)
        end
    end
end
Events.OnServerCommand.Add(ClanRestrictions.core)
