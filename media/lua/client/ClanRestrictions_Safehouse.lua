--ClanRestrictions_Safehouse.lua
ClanRestrictions = ClanRestrictions or {}


function ClanRestrictions.playerHasSafehouse(pl)
    if not pl then return false end
    return pl:hasSafehouse()
end

local updateButtons_hook = ISSafehouseUI.updateButtons
function ISSafehouseUI:updateButtons()
    updateButtons_hook(self)
    local pl = getPlayer()
    local safehouseTitle = self.safehouse and self.safehouse:getTitle() or ""
    local isOfficer = ClanRestrictions.isOfficer and ClanRestrictions.isOfficer(pl, safehouseTitle) or false
    if not ClanRestrictions.playerHasSafehouse(pl) then
        self.inviteFriend.enable = false
        self.releaseSafehouse.enable = false
        self.quitSafehouse.enable = false
    end
end


-----------------------            ---------------------------
ClanRestrictions.iconList = {
    ["Member"] = getTexture("media/ui/LootableMaps/map_o.png"),
    ["Officer"] = getTexture("media/ui/LootableMaps/map_diamond.png"),
    ["Owner"] = getTexture("media/ui/LootableMaps/map_star.png"),
}

local hook = ISSafehouseUI.updateButtons
function ISSafehouseUI:updateButtons()
    hook(self)
    local isOwner = self:isOwner()
    local hasPrivilegedAccessLevel = self:hasPrivilegedAccessLevel()
    local sh = self.safehouse:getTitle()
    local isOfficer = ClanRestrictions.isOfficer(self.player, sh)
    local canOfficerInvite = SandboxVars.ClanRestrictions.OfficersCanInvite and isOfficer
    local canOfficerKick = SandboxVars.ClanRestrictions.OfficersCanKick and isOfficer
    local isFull = ClanRestrictions.isFull(sh)
    self.removePlayer.enable = isOwner or hasPrivilegedAccessLevel or canOfficerKick
    self.addPlayer.enable = (isOwner or hasPrivilegedAccessLevel or canOfficerInvite) and not isFull
end

function ClanRestrictions.getSafeHouse(key)
    if not key then return nil end
    if type(key) == "table" and key.getID then return key end
    if type(key) == "number" then
        local list = SafeHouse.getSafehouseList()
        if not list then return nil end
        for i = 0, list:size() - 1 do
            local sh = list:get(i)
            if sh and sh:getID() == key then return sh end
        end
        return nil
    end
    if type(key) == "string" then
        local list = SafeHouse.getSafehouseList()
        if not list then return nil end
        for i = 0, list:size() - 1 do
            local s = list:get(i)
            if s and s:getTitle() == key then return s end
        end
        return nil
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
    return (m and m.size) and m:size() or 0
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
    if not sh or not targUser then return end
    local data = ClanRestrictions.getSafehouseData(sh)
    if not data then return end
    data.officers = data.officers or {}
    if isRemove then
        for i, name in ipairs(data.officers) do
            if name == targUser then
                table.remove(data.officers, i)
                break
            end
        end
    else
        local exists = false
        for _, name in ipairs(data.officers) do
            if name == targUser then
                exists = true
                break
            end
        end
        if not exists then table.insert(data.officers, targUser) end
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
