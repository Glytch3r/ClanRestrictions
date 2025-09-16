ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.init()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end
Events.OnInitGlobalModData.Add(ClanRestrictions.init)

function ClanRestrictions.receivedData(key, data)
    if key == "ClanRestrictionsData" or key == "ClanRestrictions" then
        ClanRestrictions.save(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.receivedData)

function ClanRestrictions.save(key, data)
    if (key == "ClanRestrictionsData" or key == "ClanRestrictions") and data then
        for k, v in pairs(data) do
            ClanRestrictionsData[k] = v
        end
        for k, _ in pairs(ClanRestrictionsData) do
            if data[k] == nil then
                ClanRestrictionsData[k] = nil
            end
        end
        return ClanRestrictionsData
    end
end

function ClanRestrictions.core(module, command, args)
    local pl = getPlayer()
    if module == "ClanRestrictions" then
        if command == "Fetch" and args.data then
            ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
        elseif command == "Sync" and args.data then
            for k, v in pairs(args.data) do
                ClanRestrictionsData[k] = v
            end
        elseif command == "Msg" and args.msg then
            print(tostring(args.msg))
            if pl then pl:Say(args.msg) end
        end
    end
end
Events.OnServerCommand.Add(ClanRestrictions.core)
