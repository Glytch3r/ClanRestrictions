
ClanRestrictions = ClanRestrictions or {}
local updateButtons_hook = ISSafehouseUI.updateButtons
function ISSafehouseUI:updateButtons()
    updateButtons_hook(self)

    local pl = getPlayer()

    if not ClanRestrictions.playerHasSafehouse(pl) then
        self.releaseSafehouse.enable = false
        self.quitSafehouse.enable = false
    end
--[[ 
    self.releaseSafehouse
    self.changeOwnership
    self.removePlayer
    self.addPlayer
    self.changeTitle
    self.quitSafehouse
 ]]
    local isOwner = self:isOwner()
    local hasPrivilegedAccessLevel = self:hasPrivilegedAccessLevel()
    local sh = self.safehouse
    local isOfficer = ClanRestrictions.isOfficer(self.player, sh)
    local canOfficerInvite = SandboxVars.ClanRestrictions.OfficersCanInvite and isOfficer
    local canOfficerKick   = SandboxVars.ClanRestrictions.OfficersCanKick   and isOfficer
    local isFull = ClanRestrictions.isFull(sh)

    self.removePlayer.enable = isOwner or hasPrivilegedAccessLevel or canOfficerKick
    self.addPlayer.enable    = (isOwner or hasPrivilegedAccessLevel or canOfficerInvite) and not isFull
end
-----------------------            ---------------------------

local hook = ISFactionUI.onAnswerFactionInvite
function ISFactionUI:onAnswerFactionInvite(button)
    if ISFactionUI.inviteDialogs then
        ISFactionUI.inviteDialogs[button.parent.host] = nil
    end
    if ClanRestrictions.isFactionLocked() then
        if button.internal == "OK" then
            print("ClanRestrictions.isFactionLocked")
            button.parent.ui:setVisible(false);
            button.parent.ui:removeFromUIManager();
        end
    else
        hook(self, button)
    end
end

local hook = ISFactionUI.onChangeTitle
function ISFactionUI:onChangeTitle(button)
    ClanRestrictions.onChangeTitleUI = button.parent.ui    
    hook(self, button)
end

local hook = ISFactionUI.onChangeTag
function ISFactionUI:onChangeTag(button)
    ClanRestrictions.onChangeTagUI = button.parent.ui    
    hook(self, button)
end

local hook = ISFactionUI.onQuitFaction
function ISFactionUI:onQuitFaction(button)
    ClanRestrictions.onQuitFactionUI = button.parent.ui    
    hook(self, button)
end 

local hook = ISFactionUI.onRemovePlayerFromFaction
function ISFactionUI:onRemovePlayerFromFaction(button)
    ClanRestrictions.onRemovePlayerFromFactionUI = button.parent.ui    
    hook(self, button)
end
-----------------------            ---------------------------
local hook = ISFactionUI.prerender
function ISFactionUI:prerender()
    if ClanRestrictions.isFactionLocked() and not self.isAdmin then
        self:close()
        return
    end
    hook(self)
end
