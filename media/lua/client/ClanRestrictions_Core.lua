--ClanRestrictions_Core.lua
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.init()
    ClanRestrictionsData = ModData.getOrCreate("ClanRestrictionsData")
end

Events.OnInitGlobalModData.Add(ClanRestrictions.init)

function ClanRestrictions.getSafeHouse(key)
    if not key then return nil end
    local list = SafeHouse.getSafehouseList()
    for i = 0, list:size() - 1 do
        local sh = list:get(i)
        if type(key) == "string" and sh:getTitle() == key then
            return sh
        elseif type(key) == "table" and sh.getTitle and sh:getTitle() == key:getTitle() then
            return sh
        end
    end
    return nil
end

function ClanRestrictions.getSafehouseData(shOrId)
    local sh = ClanRestrictions.getSafeHouse(shOrId) 
    if not sh then return nil end
    local id = sh:getID()                       
    ClanRestrictionsData[id] = ClanRestrictionsData[id] or {}
    return ClanRestrictionsData[id]
end

function ClanRestrictions.getUserSh(user)
    local pl = getPlayer()
    user = user or (pl and pl:getUsername())
    if not user then return nil end
    return SafeHouse.hasSafehouse(user)
end

function ClanRestrictions.getMembers(sh)
    local shObj = ClanRestrictions.getSafeHouse(sh)
    return shObj and shObj:getPlayers() or {}
end

function ClanRestrictions.getMembersCount(sh)
    local m = ClanRestrictions.getMembers(sh)
    return m and m.size and m:size() or 0
end

function ClanRestrictions.getOfficers(sh)
    local data = ClanRestrictions.getSafehouseData(sh)
    return (data and data.officers) or {}
end

function ClanRestrictions.getOfficersCount(sh)
    return #ClanRestrictions.getOfficers(sh)
end

function ClanRestrictions.getOfficersStr(sh)
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    return tostring(ClanRestrictions.getOfficersCount(sh)) .. "/" .. tostring(max)
end

function ClanRestrictions.setOfficer(sh, targUser, isRemove)
    local data = ClanRestrictions.getSafehouseData(sh)
    if not data or not targUser then return end
    data.officers = data.officers or {}
    if isRemove then
        for i, name in ipairs(data.officers) do
            if name == targUser then
                table.remove(data.officers, i)
                break
            end
        end
    else
        if not table.contains(data.officers, targUser) then
            table.insert(data.officers, targUser)
        end
    end
    ModData.transmit("ClanRestrictionsData")
end

function ClanRestrictions.isOfficer(plOrUser, sh)
    local user = type(plOrUser) == "string" and plOrUser or (plOrUser and plOrUser:getUsername())
    if not user then return false end
    for _, n in ipairs(ClanRestrictions.getOfficers(sh)) do
        if n == user then return true end
    end
    return false
end

function ClanRestrictions.isFull(sh)
    local max = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    return ClanRestrictions.getMembersCount(sh) >= max
end

function ClanRestrictions.isOfficersFull(sh)
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    return ClanRestrictions.getOfficersCount(sh) >= max
end
