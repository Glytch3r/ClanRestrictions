


--ClanRestrictions_Safehouse.lua
ClanRestrictions = ClanRestrictions or {}



local hook = ISSafehouseUI.updateButtons
function ISSafehouseUI:updateButtons()
    hook(self)
    local isOwner = self:isOwner();
    local hasPrivilegedAccessLevel = self:hasPrivilegedAccessLevel();
    
    local sh = self.safehouse:getTitle() 
    local isOfficer = ClanRestrictions.isOfficer(self.player, sh)
    local canOfficerInvite = SandboxVars.ClanRestrictions.OfficersCanInvite and isOfficer
    local canOfficerKick = SandboxVars.ClanRestrictions.OfficersCanKick and isOfficer
    local isFull = ClanRestrictions.isFull(sh)
    self.removePlayer.enable = isOwner or hasPrivilegedAccessLevel or canOfficerKick
    self.addPlayer.enable = (isOwner or hasPrivilegedAccessLevel or canOfficerInvite ) and not isFull
end
