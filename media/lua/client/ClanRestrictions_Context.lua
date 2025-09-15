ClanRestrictions = ClanRestrictions or {}


function ClanRestrictions.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end
ClanRestrictions.iconList = {
    ["Member"] = getTexture("media/ui/LootableMaps/map_o.png"),
    ["Officer"] = getTexture("media/ui/LootableMaps/map_diamond.png"),
    ["Owner"] = getTexture("media/ui/LootableMaps/map_star.png"),
}

function ClanRestrictions.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if not pl or not sq then return end
    local user = pl:getUsername()
    local safehouse = SafeHouse.hasSafehouse(user)
    if not safehouse then return end
    
    local shTitle = safehouse:getTitle() or "Safehouse"
    local isOwner = safehouse:getOwner() == user
    local isMember = safehouse:getPlayers():contains(user)
    local isAuthorized = isOwner or isMember or ClanRestrictions.isAdm(pl)
    if not isAuthorized then return end

    safehouse:syncSafehouse()
    local mainOpt = context:addOptionOnTop("Safehouse Info: " .. tostring(shTitle), worldobjects, nil)
    mainOpt.iconTexture = getTexture("media/ui/LootableMaps/map_house.png")
    local mainSub = ISContextMenu:getNew(context)
    context:addSubMenu(mainOpt, mainSub)
    
    local infoOpt = mainSub:addOption("Information")
    local infoSub = ISContextMenu:getNew(context)
    context:addSubMenu(infoOpt, infoSub)
    infoSub:addOption("Title: " .. tostring(shTitle), worldobjects, nil)
    infoSub:addOption("Owner: " .. (safehouse:getOwner() or "None"), worldobjects, nil)

    infoSub:addOption("Officers: "..tostring(ClanRestrictions.getOfficersStr(shTitle)), worldobjects, nil)


    --infoSub:addOption("ID: " .. tostring(safehouse:getId()), worldobjects, nil)

    infoSub:addOption(
        "Coordinates: (X1: " .. round(safehouse:getX()) ..
        ", Y1: " .. round(safehouse:getY()) ..
        ") (X2: " .. round(safehouse:getX2()) ..
        ", Y2: " .. round(safehouse:getY2()) .. ")",
        worldobjects,
        nil
    )


  infoSub:addOption("Area: W" .. safehouse:getW() .. " H" .. safehouse:getH(), worldobjects, nil)
    
    local members = safehouse:getPlayers()
    local membersOpt = mainSub:addOptionOnTop("Members: " .. members:size() .. "/" .. tostring(SandboxVars.ClanRestrictions.MaxSafehouseMembers or "∞"))
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)
    
    for i = 0, members:size() - 1 do
        local memberName = members:get(i)
        local memberOpt = membersSub:addOption(memberName)
        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)
        
        local isOfficer = ClanRestrictions.isOfficer and ClanRestrictions.isOfficer(memberName, shTitle) or false
        local isOwnerMember = safehouse:getOwner() == memberName
        local rankStr = "Member"
        if isOwnerMember then
            rankStr = "Owner"
        elseif isOfficer then
            rankStr = "Officer"
        end
        
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[tostring(rankStr)]

        local onlinePl = getPlayerFromUsername(memberName)
        memberSub:addOption("Online: " .. (onlinePl and "Yes" or "No"), worldobjects, nil)
        
        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            local actionText = isOwner and "Release" or "Kick"
            memberSub:addOption(actionText, worldobjects, function()
                safehouse:removePlayer(memberName)
                context:hideAndChildren()
            end)
        end
        
        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            local canPromote = not isRemove and not ClanRestrictions.isOfficersFull(shTitle)
            if canPromote or isRemove then
                memberSub:addOption(isRemove and "Demote" or "Promote", worldobjects, function()
                    ClanRestrictions.setOfficer(shTitle, memberName, isRemove)
                    context:hideAndChildren()
                end)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)

--[[ 

optTip.notAvailable = true

context:hideAndChildren()
optTip:setOptionChecked(optTip,  bool)
 ]]


function ClanRestrictions.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end

--[[ local pl = getPlayer() 
local user = pl:getUsername() 
print(SafeHouse.hasSafehouse(user):getTitle())

ClanRestrictions.setOfficer(sh, targUser, isRemove) ]]
--


function ClanRestrictions.getOfficersStr(sh)
    if not sh then return "0/0" end
    local max = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    local count = ClanRestrictions.getOfficersCount(sh) or 0
    return tostring(count) .. "/" .. tostring(max)
end
