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

require "ISUI/ISPanelJoypad"

ClanRestrictions = ClanRestrictions or {}
ClanRestrictions.FactionUIList = {
    ISFactionUI,
    ISCreateFactionUI,
    ISCreateFactionTagUI,
}

ClanRestrictions.FactionUIRefs = {
    "changeTitleUI",
    "onChangeTagUI",
    "onQuitFactionUI",
    "onRemovePlayerFromFactionUI",
}
function ClanRestrictions.getFactionName(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    local fac = Faction.getPlayerFaction(pl)
    return fac and fac:getName() or nil
end

function ClanRestrictions.getPlayerFaction(targ)
    targ = targ or getPlayer() 
    local fact = Faction.getPlayerFaction(targ) 
    return fact or nil
end

function ClanRestrictions.getUserFaction(targUser)    
    targUser = targUser or getPlayer():getUsername() 
    local fact = Faction.getPlayerFaction(targUser) 
    return fact or nil
end

function ClanRestrictions.isPlayerInFaction(user, name)
    local fact = ClanRestrictions.getFactionFromName(name)
    if not fact then return false end
    return fact:isMember(user) 
end

function ClanRestrictions.getMemberCount(faction)
    if not faction then return 0 end
    return faction:getPlayers():size()
end

function ClanRestrictions.isOwner(pl, faction)
    pl = pl or getPlayer()
    local fact = ClanRestrictions.getPlayerFaction(pl)
    if not fact then return false end
    return fact and fact:isOwner(pl:getUsername())
end

function ClanRestrictions.isFactionOwner(pl, faction)
    if not pl or not faction then return false end
    local fact = ClanRestrictions.getPlayerFaction(pl)
    return fact and fact:isOwner(pl:getUsername())
end

function ClanRestrictions.isMember(targ, name)
    targ = targ or getPlayer() 
    local fact =  ClanRestrictions.getPlayerFaction(targ)
    local factName
    if fact then
        factName = fact:getName()
    end
    if factName then
        return factName == name
    end
    return false
end

function ClanRestrictions.getFactionFromTag(tag)
    if not tag then return nil end
    local factions = Faction.getFactions()
    for i = 0, factions:size() - 1 do
        local fact = factions:get(i)
        if fact and fact:getTag() == tag then
            return fact
        end
    end
    return nil
end

function ClanRestrictions.getFactionFromName(name)
    if not name then return nil end
    local factions = Faction.getFactions()
    for i = 0, factions:size() - 1 do
        local fact = factions:get(i)
        if fact and fact:getName() == name then
            return fact
        end
    end
    return nil
end

function ClanRestrictions.getAllFactionNames()
    local names = {}
    local factions = Faction.getFactions()
    if not factions then return names end
    for i = 0, factions:size() - 1 do
        local f = factions:get(i)
        if f then
            local name = f:getName()
            if name and name ~= "" then
                table.insert(names, name)
            end
        end
    end
    return names
end



function ClanRestrictions.FactionLockHandler()
    if ClanRestrictions.isFactionLocked() then        
        if ISFactionUI.instance then
            ISFactionUI.instance:close()
            ISFactionUI.instance = nil
        end
        if ISFactionsList.instance then
            ISFactionsList.instance:close()
            ISFactionsList.instance = nil
        end
        if ISCreateFactionUI.instance then
            ISCreateFactionUI.instance:close()
            ISCreateFactionUI.instance = nil
        end
        if ISCreateFactionTagUI.instance then
            ISCreateFactionTagUI.instance:setVisible(false)
            ISCreateFactionTagUI.instance:removeFromUIManager()
            ISCreateFactionTagUI.instance = nil
        end

        if ClanRestrictions.onChangeTitle then
            ClanRestrictions.onChangeTitle:setVisible(false);
            ClanRestrictions.onChangeTitle:removeFromUIManager();
            ClanRestrictions.onChangeTitle = nil
        end
        if ClanRestrictions.onChangeTagUI then
            ClanRestrictions.onChangeTagUI:setVisible(false);
            ClanRestrictions.onChangeTagUI:removeFromUIManager();
            ClanRestrictions.onChangeTagUI = nil
        end
        if ClanRestrictions.onQuitFactionUI then
            ClanRestrictions.onQuitFactionUI:setVisible(false);
            ClanRestrictions.onQuitFactionUI:removeFromUIManager();
            ClanRestrictions.onQuitFactionUI = nil
        end
        if ClanRestrictions.onRemovePlayerFromFactionUI then
            ClanRestrictions.onRemovePlayerFromFactionUI:setVisible(false);
            ClanRestrictions.onRemovePlayerFromFactionUI:removeFromUIManager();
            ClanRestrictions.onRemovePlayerFromFactionUI = nil
        end
        if ClanRestrictions.onChangeTitleUI then
            ClanRestrictions.onChangeTitleUI:setVisible(false);
            ClanRestrictions.onChangeTitleUI:removeFromUIManager();
            ClanRestrictions.onChangeTitleUI = nil
        end



    end
end

Events.OnPlayerUpdate.Add(ClanRestrictions.FactionLockHandler)




local hook = ISFactionsList.prerender
function ISFactionsList:prerender()
    hook(self)
    if ClanRestrictions.isFactionLocked() then   
        self.viewBtn.enable = false;
    end
end



--[[ 
local hook = ISFactionUI.updateButtons
function ISFactionUI:updateButtons()
    hook(self)
    
    if ClanRestrictions.isFactionLocked() and not self.isAdmin then
        if self.addPlayer then self.addPlayer:setEnable(false) end
        if self.removePlayer then self.removePlayer:setEnable(false) end
        if self.leaveBtn then self.leaveBtn:setEnable(false) end
        if self.colorBtn then self.colorBtn:setEnable(false) end
        if self.tagBtn then self.tagBtn:setEnable(false) end
        if self.titleCombo then self.titleCombo:setEnable(false) end
        return
    end
    
    local pl = getPlayer()
    local safehouseTitle = self.faction and self.faction:getName() or ""

    local isOfficer = ClanRestrictions.isOfficer(pl, safehouseTitle)
    
    if SandboxVars.ClanRestrictions.OfficersCanInvite and isOfficer then
        if self.addPlayer then
            local maxMembers = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
            local currentCount = ClanRestrictions.getMemberCount(self.faction)
            self.addPlayer:setEnable(currentCount < maxMembers)
        end
    end
    
    if SandboxVars.ClanRestrictions.OfficersCanKick and isOfficer then
        if self.removePlayer then
            self.removePlayer:setEnable(true)
        end
    end
end
 ]]

--[[ local hook = ISFactionUI.populateList
function ISFactionUI:populateList()
    if not self.faction then 
        hook(self)
        return 
    end
    
    self.datas:clear()
    local members = self.faction:getPlayers()
    local player = getPlayer()
    local factionName = self.faction:getName()
    
    for i = 0, members:size() - 1 do
        local memberName = members:get(i)
        local isOwner = self.faction:getOwner() == memberName
        local isOfficer = ClanRestrictions.isOfficer(getPlayerByOnlineID(memberName), factionName)
        
        local displayName = memberName
        if isOwner then
            displayName = "[OWNER] " .. memberName
        elseif isOfficer then
            displayName = "[OFFICER] " .. memberName
        end
        
        self.datas:addItem(displayName, memberName)
    end
end ]]