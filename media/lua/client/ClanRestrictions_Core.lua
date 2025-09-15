ClanRestrictions = ClanRestrictions or {}

-----------------------     ---------------------------

function ClanRestrictions.getSafeHouse(sh)
    if not sh then return nil end
    return SafeHouse.getSafeHouse(sh)
end

function ClanRestrictions.getUserSh(user)
    local pl = getPlayer()
    user = user or (pl and pl:getUsername())
    if not user then return nil end
    return SafeHouse.hasSafehouse(user)
end

--[[ 
function ClanRestrictions.getSafeHouse(sh)
    if not sh then return nil end
    return SafeHouse.getSafeHouse(sh)
end ]]

function ClanRestrictions.getSafehouseData(sh)
    if not sh then return nil end
    ClanRestrictionsData[sh] = ClanRestrictionsData[sh] or {}
    return ClanRestrictionsData[sh]
end

-----------------------     -------
--[[ 
function ClanRestrictions.getSafeHouse(targ)
    if not targ then return nil end


    return 
end
 ]]

--------------------
-----------------------            ---------------------------
--[[ 
local sh =  SafeHouse.hasSafehouse("Glytch3r")
sh:addPlayer("mrRobot");
sh:syncSafehouse();

sendSafehouseInvite(sh, pl, targPl);
sh:kickOutOfSafehouse(self.player);
 ]]
-----------------------            ---------------------------
function ClanRestrictions.getMembers(sh)
    if not sh then return {} end
    local safehouse = ClanRestrictions.getSafeHouse(sh)
    if safehouse then
        return safehouse:getPlayers()
    end
    return {}
end

function ClanRestrictions.getMembersCount(sh)
    local mem = ClanRestrictions.getMembers(sh)
    return (mem and mem.size) and mem:size() or 0
end

function ClanRestrictions.getOfficers(sh)
    if not sh then return {} end
    local data = ClanRestrictionsData[sh]
    if not data or not data.officers then return {} end
    return data.officers
end

function ClanRestrictions.getOfficersCount(sh)
    return #ClanRestrictions.getOfficers(sh)
end

function ClanRestrictions.setOfficer(sh, targUser, isRemove)
    if not sh or not targUser then return nil end
    local data = ClanRestrictions.getSafehouseData(sh)
    data.officers = data.officers or {}

    if isRemove then
        for i, name in ipairs(data.officers) do
            if name == targUser then
                table.remove(data.officers, i)
                break
            end
        end
    else
        table.insert(data.officers, targUser)
    end
    ModData.transmit('ClanRestrictionsData')
    
end

function ClanRestrictions.isOfficer(plOrUser, sh)
    if not plOrUser or not sh then return false end
    local user = type(plOrUser) == "string" and plOrUser or plOrUser:getUsername()
    for _, officerName in ipairs(ClanRestrictions.getOfficers(sh)) do
        if officerName == user then
            return true
        end
    end
    return false
end

-----------------------     ---------------------------

function ClanRestrictions.isFull(sh)
    if not sh then return false end
    local max = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    return ClanRestrictions.getMembersCount(sh) >= max
end

function ClanRestrictions.isOfficersFull(sh)
    if not sh then return false end
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    return ClanRestrictions.getOfficersCount(sh) >= max
end

-----------------------    ---------------------------
