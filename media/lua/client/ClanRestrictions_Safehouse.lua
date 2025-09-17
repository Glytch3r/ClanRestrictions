-- ClanRestrictions_Safehouse.lua
ClanRestrictions = ClanRestrictions or {}

ClanRestrictions.iconList = {
    ["Member"]  = getTexture("media/ui/LootableMaps/map_o.png"),
    ["Officer"] = getTexture("media/ui/LootableMaps/map_diamond.png"),
    ["Owner"]   = getTexture("media/ui/LootableMaps/map_star.png"),
}

function ClanRestrictions.getUserSh(user)
    local pl = getPlayer()
    user = user or (pl and pl:getUsername())
    if not user then return nil end
    return SafeHouse.hasSafehouse(user)
end

function ClanRestrictions.getMembers(sh)
    local shObj = ClanRestrictions.getSafeHouse and ClanRestrictions.getSafeHouse(sh) or nil
    if not shObj then
        shObj = SafeHouse.hasSafehouse(getPlayer())
    end
    if not shObj then return nil end
    return shObj:getPlayers() 
end

function ClanRestrictions.getMembersCount(sh)
    local members = ClanRestrictions.getMembers(sh)
    return members and members:size() or 0
end

function ClanRestrictions.isFull(sh)
    local max = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    return ClanRestrictions.getMembersCount(sh) >= max
end

function ClanRestrictions.playerHasSafehouse(pl)
    pl = pl or getPlayer()
    return SafeHouse.hasSafehouse(pl) ~= nil
end

function ClanRestrictions.getSafeHouse(key)
    if not key then return nil end
    if type(key) == "userdata" and instanceof(key, "SafeHouse") then
        return key
    end
    local list = SafeHouse.getSafehouseList()
    for i = 0, list:size() - 1 do
        local sh = list:get(i)
        if type(key) == "number" and sh:getID() == key then
            return sh
        end
        if type(key) == "string" and sh:getTitle() == key then
            return sh
        end
    end
    return nil
end
-----------------------            ---------------------------
function ClanRestrictions.disbandListener()
    if not ClanRestrictionsData or not ClanRestrictionsData.officers then return end

    for username, _ in pairs(ClanRestrictionsData.officers) do
        if not SafeHouse.hasSafehouse(username) then
            ClanRestrictions.setOfficer(username, false)
            ClanRestrictions.sendToServer()
        end
    end
    ClanRestrictions.sendToServer()
    --ModData.transmit("ClanRestrictionsData")
end

Events.OnSafehousesChanged.Add(ClanRestrictions.disbandListener)




-----------------------            ---watervomb revpvery------------------------
--[[ 
SafeHouse.addSafeHouse(_x, _y, _w, _h, _owner, false);
SafeHouse.addSafeHouse(sq, pl)

local sq = getPlayer():getSquare() 
local pl = getPlayer() 
SafeHouse.addSafeHouse(sq, pl)

sh:alreadyHaveSafehouse(user)
sh:syncSafehouse()
sendSafehouseInvite
setOwner
kickOutOfSafehouse
sh:updateSafehouse(pl)
SafeHouse.getSafeHouse(sq)
sh:removePlayer(user);
sh:removeSafeHouse(pl)
sh:kickOutOfSafehouse(pl)
SafeHouse.alreadyHaveSafehouse 
isRespawnInSafehouse
removeSafeHouse
checkTrespass
removeSafeHouse
print(SafeHouse:alreadyHaveSafehouse(getPlayer()))
setRespawnInSafehouse(boolean b, String username)


print(SafeHouse.isSafeHouse(getPlayer():getSquare() ))
    safehouse:addPlayer(player:getUsername());

]]


--[[ 
local sh = SafeHouse.hasSafehouse(getPlayer())
sh:addPlayer('test')
sh:addPlayer('someone')
 ]]