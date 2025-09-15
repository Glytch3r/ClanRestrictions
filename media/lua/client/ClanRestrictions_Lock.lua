----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

--ClanRestrictions_Lock.lua
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.isFactionLocked()
    return ClanRestrictionsData.isFactionLocked or false
end

function ClanRestrictions.closeFactPanels()
    if ISFactionUI.instance then ISFactionUI.instance:close() end
    if ISCreateFactionUI.instance then ISCreateFactionUI.instance:close() end
    if ISFactionAddPlayerUI.instance then ISFactionAddPlayerUI.instance:close() end
    if ISCreateFactionTagUI.instance then ISCreateFactionTagUI.instance:close() end
end

function ClanRestrictions.FactionLockChange(active)
    if active then
        sendClientCommand(getPlayer(), "ClanRestrictions", "closeFactPanels", {})
        ClanRestrictions.closeFactPanels()
    end
end

function ClanRestrictions.setFactionLocked(isLocked)
    ClanRestrictionsData.isFactionLocked = isLocked
    ModData.transmit("ClanRestrictionsData")
end

local hookCreate = ISUserPanelUI.createChildren
function ISUserPanelUI:createChildren()
    hookCreate(self)
    self.FactionLock = ISTickBox:new(173, 180, 150, 25, "Faction Lock", self, function()
        local isLocked = not ClanRestrictions.isFactionLocked()
        ClanRestrictions.setFactionLocked(isLocked)
    end)
    self.FactionLock:initialise()
    self.FactionLock:instantiate()
    self.FactionLock.selected[1] = ClanRestrictions.isFactionLocked()
    self.FactionLock:addOption("Faction Lock")
    self:addChild(self.FactionLock)
end

local hookUpdate = ISUserPanelUI.updateButtons
function ISUserPanelUI:updateButtons()
    hookUpdate(self)
    local isLocked = ClanRestrictions.isFactionLocked()
    local sufix = isLocked and " [LOCKED]" or " [UNLOCKED]"
    self.factionBtn.enable = not isLocked
    self.factionBtn.title   = getText("UI_userpanel_factionpanel") .. sufix
    self.factionBtn.tooltip = getText("UI_userpanel_factionpanel") .. sufix
    if isLocked then
        self.factionBtn.borderColor = {r=1, g=0.4, b=0.4, a=1}
    else
        self.factionBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    end
    self.FactionLock.enable = ClanRestrictions.isAdm(getPlayer())
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
