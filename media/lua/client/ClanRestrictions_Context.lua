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
    local isAdmin  = ClanRestrictions.isAdm(pl)
    if not (isOwner or isMember or isAdmin) then return end

    local maxMembers  = SandboxVars.ClanRestrictions.MaxSafehouseMembers or 10
    local maxOfficers = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    local canOffKick  = SandboxVars.ClanRestrictions.OfficersCanKick   or false
    local canOffInvite= SandboxVars.ClanRestrictions.OfficersCanInvite or false

    targetSh:syncSafehouse()
    local shTitle = targetSh:getTitle() or "Safehouse"
    local members = targetSh:getPlayers()
    local membersCount = members:size()
    local officersCount = ClanRestrictions.getOfficersCount(targetSh)

    local mainOpt = context:addOptionOnTop("Safehouse Info: " .. shTitle, worldobjects, nil)
    mainOpt.iconTexture = getTexture("media/ui/LootableMaps/map_house.png")
    local mainSub = ISContextMenu:getNew(context)
    context:addSubMenu(mainOpt, mainSub)

    local infoOpt = mainSub:addOption("Information")
    local infoSub = ISContextMenu:getNew(context)
    context:addSubMenu(infoOpt, infoSub)
    infoSub:addOption("Title: " .. shTitle, worldobjects, nil)
    infoSub:addOption("Owner: " .. (targetSh:getOwner() or "None"), worldobjects, nil)
    infoSub:addOption("Officers: " .. officersCount .. " / " .. maxOfficers, worldobjects, nil)
    infoSub:addOption("Members: " .. membersCount .. " / " .. maxMembers, worldobjects, nil)
--[[     infoSub:addOption("OfficersCanKick: " .. tostring(canOffKick), worldobjects, nil)
    infoSub:addOption("OfficersCanInvite: " .. tostring(canOffInvite), worldobjects, nil) ]]
    infoSub:addOption(
        string.format(
            "Coordinates: (X1:%d, Y1:%d) (X2:%d, Y2:%d)",
            round(targetSh:getX()),
            round(targetSh:getY()),
            round(targetSh:getX2()),
            round(targetSh:getY2())
        ),
        worldobjects,
        nil
    )
    infoSub:addOption("Area: W" .. round(targetSh:getW()) .. " H" .. round(targetSh:getH()), worldobjects, nil)

    local membersOpt = mainSub:addOptionOnTop(
        "Members: " .. membersCount .. " / " .. maxMembers
    )
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)


    for i = 0, membersCount - 1 do
        local memberName = members:get(i)
        local isOfficer     = ClanRestrictions.isOfficer(memberName, targetSh)
        local isOwnerMember = targetSh:getOwner() == memberName
        local rankStr       = isOwnerMember and "Owner" or (isOfficer and "Officer" or "Member")

        local memberOpt = membersSub:addOption(memberName)
        memberOpt.iconTexture = ClanRestrictions.iconList[rankStr]
        memberOpt.tooltip = "Rank: " .. rankStr
        local targMember = getPlayerFromUsername(memberName)
        membersSub:setOptionChecked(memberOpt, targMember ~= nil)

        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[rankStr]

        if targMember then
            memberSub:addOption((targMember and "Online" or "Offline"), worldobjects, nil)
        end

        local canKick = (isOwner or isAdmin) or (canOffKick and isOfficer and not isOwnerMember)
        if canKick and not isOwnerMember then
            memberSub:addOption("Kick", worldobjects, function()
                targetSh:removePlayer(memberName)
                context:hideAndChildren()
            end)
        end

        if (isOwner or isAdmin) and not isOwnerMember then
            if isOfficer then
                memberSub:addOption("Demote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, true)
                    context:hideAndChildren()
                end)
            elseif officersCount < maxOfficers then
                memberSub:addOption("Promote", worldobjects, function()
                    ClanRestrictions.setOfficer(memberName, false)
                    context:hideAndChildren()
                end)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)
