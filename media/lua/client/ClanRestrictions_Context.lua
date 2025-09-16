--ClanRestrictions_Context.lua
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end
function ClanRestrictions.shouldShow(user, sq)
    if not user or not sq then return false end
    local userSh = SafeHouse.hasSafehouse(user)
    if not userSh then return false end
    if SandboxVars.ClanRestrictions.AnySquareAccess then return true end
    local sqSh = SafeHouse.getSafeHouse(sq)
    return sqSh and sqSh:getId() == userSh:getId()
end



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
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    return sh and sh:getPlayers() or {}
end

function ClanRestrictions.getMembersCount(sh)
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    local m = ClanRestrictions.getMembers(sh)
    return (m and m.size) and m:size() or 0
end

function ClanRestrictions.isFull(sh)
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    local max = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    return ClanRestrictions.getMembersCount(sh) >= max
end

function ClanRestrictions.playerHasSafehouse(pl)
    pl = pl or getPlayer()
    return SafeHouse.hasSafehouse(pl) ~= nil
end

function ClanRestrictions.shouldShow(user, sq)
    if not user or not sq then return false end
    local userSh = SafeHouse.hasSafehouse(user)
    if not userSh then return false end
    if SandboxVars.ClanRestrictions.AnySquareAccess then return true end
    local sqSh = SafeHouse.getSafeHouse(sq)
    return sqSh and sqSh:getId() == userSh:getId()
end



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
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    return sh and sh:getPlayers() or {}
end

function ClanRestrictions.getMembersCount(sh)
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    local m = ClanRestrictions.getMembers(sh)
    return (m and m.size) and m:size() or 0
end

function ClanRestrictions.isFull(sh)
    sh = sh or SafeHouse.hasSafehouse(getPlayer())
    local max = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    return ClanRestrictions.getMembersCount(sh) >= max
end

function ClanRestrictions.playerHasSafehouse(pl)
    pl = pl or getPlayer()
    return SafeHouse.hasSafehouse(pl) ~= nil
end

function ClanRestrictions.shouldShow(user, sq)
    if not user or not sq then return false end
    local userSh = SafeHouse.hasSafehouse(user)
    if not userSh then return false end
    if SandboxVars.ClanRestrictions.AnySquareAccess then return true end
    local sqSh = SafeHouse.getSafeHouse(sq)
    return sqSh and sqSh:getId() == userSh:getId()
end

function ClanRestrictions.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if not pl or not sq then return end
    local user = pl:getUsername()
    local targetSh = SafeHouse.hasSafehouse(user) or SafeHouse.getSafeHouse(sq)
    if not targetSh then return end
    if not ClanRestrictions.shouldShow(user, sq) then return end
    local isOwner  = targetSh:getOwner() == user
    local isMember = targetSh:getPlayers():contains(user)
    local isAuthorized = isOwner or isMember or ClanRestrictions.isAdm(pl)
    if not isAuthorized then return end
    targetSh:syncSafehouse()
    local shTitle = targetSh:getTitle() or "Safehouse"
    local shId    = targetSh:getId()
    local mainOpt = context:addOptionOnTop("Safehouse Info: " .. shTitle, worldobjects, nil)
    mainOpt.iconTexture = getTexture("media/ui/LootableMaps/map_house.png")
    local mainSub = ISContextMenu:getNew(context)
    context:addSubMenu(mainOpt, mainSub)
    local infoOpt = mainSub:addOption("Information")
    local infoSub = ISContextMenu:getNew(context)
    context:addSubMenu(infoOpt, infoSub)
    --infoSub:addOption("ID: " .. shId, worldobjects, nil)
    infoSub:addOption("Title: " .. shTitle, worldobjects, nil)
    infoSub:addOption("Owner: " .. (targetSh:getOwner() or "None"), worldobjects, nil)
    infoSub:addOption("Officers: " .. ClanRestrictions.getOfficersStr(targetSh), worldobjects, nil)
    infoSub:addOption(
        string.format(
            "Coordinates: (X1:%d, Y1:%d) (X2:%d, Y2:%d)",
            math.floor(targetSh:getX() + 0.5),
            math.floor(targetSh:getY() + 0.5),
            math.floor(targetSh:getX2() + 0.5),
            math.floor(targetSh:getY2() + 0.5)
        ),
        worldobjects,
        nil
    )
    infoSub:addOption("Area: W" .. targetSh:getW() .. " H" .. targetSh:getH(), worldobjects, nil)
    local members    = targetSh:getPlayers()
    local membersOpt = mainSub:addOptionOnTop(
        "Members: " .. members:size() .. " / " .. (SandboxVars.ClanRestrictions.MaxSafehouseMembers)
    )
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)
    local getPlayerFromUsernameSafe = _G.getPlayerFromUsername
    for i = 0, members:size() - 1 do
        local memberName = members:get(i)
        local isOfficer     = ClanRestrictions.isOfficer(memberName, targetSh)
        local isOwnerMember = targetSh:getOwner() == memberName
        local rankStr       = isOwnerMember and "Owner" or (isOfficer and "Officer" or "Member")
        local memberOpt = membersSub:addOption(memberName)
        memberOpt.iconTexture = ClanRestrictions.iconList[rankStr]
        memberOpt.tooltip = "Rank: " .. rankStr
        membersSub:setOptionChecked(memberOpt, getPlayerFromUsernameSafe and getPlayerFromUsernameSafe(memberName) ~= nil)
        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[rankStr]
        if getPlayerFromUsernameSafe then
            local onlinePl = getPlayerFromUsernameSafe(memberName)
            memberSub:addOption((onlinePl and "Online" or "Offline"), worldobjects, nil)
        end
        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            memberSub:addOption("Kick", worldobjects, function()
                targetSh:removePlayer(memberName)
                context:hideAndChildren()
            end)
            if isOfficer then
                memberSub:addOption("Demote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, true)
                    context:hideAndChildren()
                end)
            elseif not ClanRestrictions.isOfficersFull(targetSh) then
                memberSub:addOption("Promote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, false)
                    context:hideAndChildren()
                end)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)









--[[ 
function ClanRestrictions.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if not pl or not sq then return end
    local user = pl:getUsername()

    local targetSh = SafeHouse.hasSafehouse(user) or SafeHouse.getSafeHouse(sq)
    if not targetSh then return end

    if not ClanRestrictions.shouldShow(user, sq) then return end

    local isOwner  = targetSh:getOwner() == user
    local isMember = targetSh:getPlayers():contains(user)
    local isAuthorized = isOwner or isMember or ClanRestrictions.isAdm(pl)
    if not isAuthorized then return end

    targetSh:syncSafehouse()

    local shTitle = targetSh:getTitle() or "Safehouse"
    local shId    = targetSh:getId()

    local mainOpt = context:addOptionOnTop("Safehouse Info: " .. shTitle, worldobjects, nil)
    mainOpt.iconTexture = getTexture("media/ui/LootableMaps/map_house.png")
    local mainSub = ISContextMenu:getNew(context)
    context:addSubMenu(mainOpt, mainSub)

    local infoOpt = mainSub:addOption("Information")
    local infoSub = ISContextMenu:getNew(context)
    context:addSubMenu(infoOpt, infoSub)
--    infoSub:addOption("ID: " .. shId, worldobjects, nil)
    infoSub:addOption("Title: " .. shTitle, worldobjects, nil)
    infoSub:addOption("Owner: " .. (targetSh:getOwner() or "None"), worldobjects, nil)
    infoSub:addOption("Officers: " .. ClanRestrictions.getOfficersStr(targetSh), worldobjects, nil)
    infoSub:addOption(
        string.format(
            "Coordinates: (X1:%d, Y1:%d) (X2:%d, Y2:%d)",
            math.floor(targetSh:getX() + 0.5),
            math.floor(targetSh:getY() + 0.5),
            math.floor(targetSh:getX2() + 0.5),
            math.floor(targetSh:getY2() + 0.5)
        ),
        worldobjects,
        nil
    )
    infoSub:addOption("Area: W" .. targetSh:getW() .. " H" .. targetSh:getH(), worldobjects, nil)

    local members    = targetSh:getPlayers()
    local membersOpt = mainSub:addOptionOnTop(
        "Members: " .. members:size() .. "/" .. (SandboxVars.ClanRestrictions.MaxSafehouseMembers or "∞")
    )
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)

    local getPlayerFromUsernameSafe = _G.getPlayerFromUsername
    for i = 0, members:size() - 1 do
        local memberName = members:get(i)
        local memberOpt  = membersSub:addOption(memberName)
        membersSub:setOptionChecked(memberOpt, getPlayerFromUsernameSafe and getPlayerFromUsernameSafe(memberName) ~= nil)

        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)

        local isOfficer     = ClanRestrictions.isOfficer(memberName, targetSh)
        local isOwnerMember = targetSh:getOwner() == memberName
        local rankStr = isOwnerMember and "Owner" or (isOfficer and "Officer" or "Member")
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[rankStr]

        if getPlayerFromUsernameSafe then
            local onlinePl = getPlayerFromUsernameSafe(memberName)
            memberSub:addOption("Online: " .. (onlinePl and "Yes" or "No"), worldobjects, nil)
        end

        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            memberSub:addOption("Kick", worldobjects, function()
                targetSh:removePlayer(memberName)
                context:hideAndChildren()
            end)

            if isOfficer then
                memberSub:addOption("Demote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, true)
                    context:hideAndChildren()
                end)
            elseif not ClanRestrictions.isOfficersFull(targetSh) then
                memberSub:addOption("Promote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, false)
                    context:hideAndChildren()
                end)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)
 ]]