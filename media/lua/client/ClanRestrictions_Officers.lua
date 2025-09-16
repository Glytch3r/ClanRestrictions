

ClanRestrictions = ClanRestrictions or {}


function ClanRestrictions.getOfficers(sh)
    sh = sh or  SafeHouse.hasSafehouse(getPlayer())
    if not sh then return {} end
    local members = {}
    local players = sh:getPlayers()
    for i = 0, players:size() - 1 do
        members[players:get(i)] = true
    end
    local result = {}
    local officersList = (ClanRestrictionsData and ClanRestrictionsData.officers) or {}
    for name, _ in pairs(officersList) do
        if members[name] then
            table.insert(result, name)
        end
    end
    return result
end

function ClanRestrictions.getOfficersCount(sh)
    sh = sh or  SafeHouse.hasSafehouse(getPlayer())
    return #ClanRestrictions.getOfficers(sh)
end

function ClanRestrictions.getOfficersStr(sh)
    sh = sh or  SafeHouse.hasSafehouse(getPlayer())
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    return tostring(ClanRestrictions.getOfficersCount(sh)) .. "/" .. tostring(max)
end

function ClanRestrictions.setOfficer(targUser, isRemove)
    if not targUser then return end
    ClanRestrictionsData.officers = ClanRestrictionsData.officers or {}
    if isRemove then
        ClanRestrictionsData.officers[targUser] = nil
    else
        ClanRestrictionsData.officers[targUser] = true
    end
    ModData.transmit("ClanRestrictionsData")
end

function ClanRestrictions.isOfficer(plOrUser, sh)
    local user = type(plOrUser) == "string" and plOrUser or (plOrUser and plOrUser:getUsername())
    if not user then return false end

    local members = ClanRestrictions.getMembers(sh)
    if not members then return false end

    for i = 0, members:size() - 1 do
        local member = members:get(i)
        local memberName = nil

        if type(member) == "string" then
            memberName = member
        elseif member and member.getUsername then
            memberName = member:getUsername()
        else
            memberName = tostring(member)
        end

        if memberName == user then
            return (ClanRestrictionsData and ClanRestrictionsData.officers and ClanRestrictionsData.officers[user]) or false
        end
    end

    return false
end

function ClanRestrictions.isOfficersFull(sh)
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    return ClanRestrictions.getOfficersCount(sh) >= max
end
