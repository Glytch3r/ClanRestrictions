
ClanRestrictions = ClanRestrictions or {}
-----------------------   ISSafehouseUI         ---------------------------

local receiveInvite_orig = ISSafehouseUI.ReceiveSafehouseInvite

function ISSafehouseUI.ReceiveSafehouseInvite(safehouse, host)
    local pl = getPlayer()
    if pl then
        local inviterFaction = Faction.getPlayerFaction(host)
        local inviteeFaction = Faction.getPlayerFaction(pl)
        if inviterFaction and inviteeFaction
           and inviterFaction:getName() ~= inviteeFaction:getName() then
            return 
        end
    end
    return receiveInvite_orig(safehouse, host)
end


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
-----------------------   ISSafehouseAddPlayerUI         ---------------------------
local hookPrerender = ISSafehouseAddPlayerUI.prerender
function ISSafehouseAddPlayerUI:prerender()
    hookPrerender(self)

    local targUser = self.selectedPlayer
    if not targUser then
        self.addPlayer.enable = false
        return
    end

    local user   = getPlayer():getUsername()
    local plFac    = Faction.getPlayerFaction(user)
    local targFac  = Faction.getPlayerFaction(targUser)
    if plFac and targFac and plFac:getName() ~= targFac:getName() then
        self.addPlayer.enable = false
        return
    end

    local sh = SafeHouse.hasSafehouse(user)
    if sh and ClanRestrictions.isFull(sh) then
        self.addPlayer.enable = false
        return
    end
end

-----------------------    ISFactionUI        ---------------------------
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

local hookISFactionUI = ISFactionUI.prerender
function ISFactionUI:prerender()
    if ClanRestrictions.isFactionLocked() and not self.isAdmin then
        self:close()
        return
    end
    hookISFactionUI(self)
end
-----------------------  ISFactionsList          ---------------------------

local hookISFactionsList = ISFactionsList.prerender
function ISFactionsList:prerender()
    hookISFactionsList(self)
    if ClanRestrictions.isFactionLocked() then   
        self.viewBtn.enable = false;
    end
end



-----------------------    ISUserPanelUI        ---------------------------

local hookCreate = ISUserPanelUI.createChildren
function ISUserPanelUI:createChildren()
    hookCreate(self)

    self.FactionLock = ISTickBox:new(
        173, 180, 150, 25,
        "Faction Lock",
        self,
        function()
            local locked = not ClanRestrictions.isFactionLocked()
            ClanRestrictions.setFactionLocked(locked)
        end
    )
    self.FactionLock:initialise()
    self.FactionLock:instantiate()
    self.FactionLock.selected[1] = ClanRestrictions.isFactionLocked()
    self.FactionLock:addOption("Faction Lock")
    self:addChild(self.FactionLock)
end

local hookUpdate = ISUserPanelUI.updateButtons
function ISUserPanelUI:updateButtons()
    hookUpdate(self)

    local locked = ClanRestrictions.isFactionLocked()
    local suffix = locked and " [LOCKED]" or " [UNLOCKED]"

    self.factionBtn.enable  = not locked
    self.factionBtn.title   = getText("UI_userpanel_factionpanel") .. suffix
    self.factionBtn.tooltip = getText("UI_userpanel_factionpanel") .. suffix
    self.factionBtn.borderColor = locked
        and { r = 1,   g = 0.4, b = 0.4, a = 1 }
         or { r = 0.4, g = 0.4, b = 0.4, a = 1 }

  --  self.FactionLock.selected[1] = locked

    local isAdmin = ClanRestrictions.isAdm(self.player)

    self.FactionLock.enable = isAdmin
end

local hookOption = ISUserPanelUI.onOptionMouseDown
function ISUserPanelUI:onOptionMouseDown(button, x, y)
    if button.internal == "FACTIONPANEL" then
        if ISFactionUI.instance then ISFactionUI.instance:close() end
        if ISCreateFactionUI.instance then ISCreateFactionUI.instance:close() end
        if Faction.isAlreadyInFaction(self.player) then
            local modal = ISFactionUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, Faction.getPlayerFaction(self.player), self.player)
            modal:initialise()
            modal:addToUIManager()
        else
            local modal = ISCreateFactionUI:new(self.x + 100, self.y + 100, 350, 250, self.player)
            modal:initialise()
            modal:addToUIManager()
        end
    else
        hookOption(self, button, x, y)
    end
end

Events.OnCreatePlayer.Add(function()
    if ISUserPanelUI.instance then
        ISUserPanelUI.instance:close()
        ISUserPanelUI.instance = nil
    end
end)

--[[ 

local hookUpdate = ISUserPanelUI.updateButtons
function ISUserPanelUI:updateButtons()
    hookUpdate(self)
    local isLocked = ClanRestrictions.isFactionLocked()
    local sufix    = isLocked and " [LOCKED]" or " [UNLOCKED]"
    self.factionBtn.enable  = not isLocked
    self.factionBtn.title   = getText("UI_userpanel_factionpanel") .. sufix
    self.factionBtn.tooltip = getText("UI_userpanel_factionpanel") .. sufix
    self.factionBtn.borderColor = isLocked and {r=1,   g=0.4, b=0.4, a=1}  or  {r=0.4, g=0.4, b=0.4, a=1}
    --self.FactionLock.selected[1] = isLocked
    self.FactionLock.enable = ClanRestrictions.isAdm(getPlayer())
end



 ]]



-----------------------            ---------------------------
--[[ 
local adminHook = ISAdminPanelUI.updateButtons
function ISAdminPanelUI:updateButtons()
    adminHook(self)
    self.seeFactionBtn.enable = not ClanRestrictions.isFactionLocked() 
end ]]