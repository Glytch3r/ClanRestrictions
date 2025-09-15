--client/ClanRestrictions_Data.lua

ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.init()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end
Events.OnInitGlobalModData.Add(ClanRestrictions.init)

function ClanRestrictions.receivedData(key, data)
    if key == "ClanRestrictionsData" or  key == "ClanRestrictions"  then
        ClanRestrictions.save(key, data)
    end
  
end
Events.OnReceiveGlobalModData.Add(ClanRestrictions.OnReceiveGlobalModData)

function ClanRestrictions.save(key, data)
    if (key == "ClanRestrictionsData" or key == "ClanRestrictions") and data then      
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
end

function ClanRestrictions.core(module, command, args)
    local pl = getPlayer()    
    if module == "ClanRestrictions" then 
        if command == "Fetch" and args.data then
            ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")            
        elseif command == "Sync" and args.data then
            for key, value in pairs(args.data) do
                ClanRestrictionsData[key] = value
            end
        elseif command == "Msg" and args.msg then
            print(tostring(args.msg))
            if pl then
                pl:Say(args.msg)
            end
        end
    end
end
Events.OnServerCommand.Add(ClanRestrictions.core)

-----------------------            ---------------------------
--SafeHouse:removeSafeHouse(getSpecificPlayer(player))