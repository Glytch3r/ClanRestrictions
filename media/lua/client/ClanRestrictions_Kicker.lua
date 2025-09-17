
ClanRestrictions = ClanRestrictions or {}
local ticks = 0
function ClanRestrictions.autoLeave(pl)
    if not SandboxVars.ClanRestrictions.AutoKicker then  return end

    ticks = ticks + 1
    if ticks % 250 ~= 0 then return end  
   
    local user   = pl:getUsername()
    if not user then return end

    local userSh = SafeHouse.hasSafehouse(user)
    if not userSh then return end

    local boss   = userSh:getOwner()
    if not boss then return end

    local bossFac = Faction.getPlayerFaction(boss)
    if not bossFac then return end

    local plFac  = Faction.getPlayerFaction(user)
    if not plFac then return end

    if plFac:getName() ~= bossFac:getName() then
        local x, y = pl:getX(), pl:getY()
        if x >= userSh:getX() - 1 and x < userSh:getX2() + 1
        and y >= userSh:getY() - 1 and y < userSh:getY2() + 1 then
            userSh:kickOutOfSafehouse(pl)
        end
        ClanRestrictions.setOfficer(user, false)
        userSh:removePlayer(user)
    end
    ticks = 0
end
Events.OnPlayerUpdate.Add(ClanRestrictions.autoLeave)
