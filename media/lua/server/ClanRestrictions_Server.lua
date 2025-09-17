-- server/ClanRestrictions_Server.lua
if isClient() then return end
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.updateData(data)
    for k, v in pairs(data) do
        ClanRestrictionsData[k] = v
    end
    ModData.transmit("ClanRestrictionsData") 
end

function ClanRestrictions.initServer()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end
Events.OnInitGlobalModData.Add(ClanRestrictions.initServer)

function ClanRestrictions.sync(module, command, player, args)
    if module ~= "ClanRestrictions" then return end
    if command == "Update" and args.data then
        ClanRestrictions.updateData(args.data)
    elseif command == "RequestSync" then
        sendServerCommand(player, "ClanRestrictions", "Update", { data = ClanRestrictionsData })
    elseif command == "Msg" and args.msg then
        sendServerCommand(player, "ClanRestrictions", "Msg", { msg = args.msg })
    end
end
Events.OnClientCommand.Add(ClanRestrictions.sync)

function ClanRestrictions.receivedData(key, data)
    if key == "ClanRestrictionsData" then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.receivedData)
