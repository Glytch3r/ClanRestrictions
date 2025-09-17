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
    local playerSh = SafeHouse.hasSafehouse(user)
    if not playerSh then return end
    if not SandboxVars.ClanRestrictions.AnySquareAccess then
        if not SafeHouse.getSafeHouse(sq) or SafeHouse.getSafeHouse(sq) ~= playerSh then
            return
        end
    end

    if not ClanRestrictions.shouldShow(user, sq) then return end

    local isOwner   = playerSh:getOwner() == user
    local isMember  = playerSh:getPlayers():contains(user)
    local isAdmin   = ClanRestrictions.isAdm(pl)
    if not (isOwner or isMember or isAdmin) then return end

    local maxMembers    = SandboxVars.ClanRestrictions.MaxSafehouseMembers  or 10
    local maxOfficers   = SandboxVars.ClanRestrictions.MaxSafehouseOfficers or 3
    local canOffKick    = SandboxVars.ClanRestrictions.OfficersCanKick       or false
    local canOffInvite  = SandboxVars.ClanRestrictions.OfficersCanInvite     or false
    local canOffAssign  = SandboxVars.ClanRestrictions.OfficersAssignRank    or false

    playerSh:syncSafehouse()
    local shTitle      = playerSh:getTitle() or "Safehouse"
    local members      = playerSh:getPlayers()
    local membersCount = members:size()
    local officersCount = ClanRestrictions.getOfficersCount(playerSh)

    local mainOpt = context:addOptionOnTop("Safehouse Info: " .. shTitle, worldobjects, nil)
    mainOpt.iconTexture = getTexture("media/ui/LootableMaps/map_house.png")
    local mainSub = ISContextMenu:getNew(context)
    context:addSubMenu(mainOpt, mainSub)

    local infoOpt = mainSub:addOption("Information")
    local infoSub = ISContextMenu:getNew(context)
    context:addSubMenu(infoOpt, infoSub)
    infoSub:addOption("Title: " .. shTitle, worldobjects, nil)
    infoSub:addOption("Owner: " .. (playerSh:getOwner() or "None"), worldobjects, nil)
    infoSub:addOption("Officers: " .. officersCount .. " / " .. maxOfficers, worldobjects, nil)
    infoSub:addOption("Members: " .. membersCount .. " / " .. maxMembers, worldobjects, nil)
    infoSub:addOption(
        string.format(
            "Coordinates: (X1:%d, Y1:%d) (X2:%d, Y2:%d)",
            round(playerSh:getX()),
            round(playerSh:getY()),
            round(playerSh:getX2()),
            round(playerSh:getY2())
        ),
        worldobjects,
        nil
    )
    infoSub:addOption("Area: W" .. round(playerSh:getW()) .. " H" .. round(playerSh:getH()), worldobjects, nil)

    local membersOpt = mainSub:addOptionOnTop("Members: " .. membersCount .. " / " .. maxMembers)
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)

    for i = 0, membersCount - 1 do
        local targUser = members:get(i)
        local isOfficer     = ClanRestrictions.isOfficer(targUser, playerSh)
        local isOwnerMember = playerSh:getOwner() == targUser
        local rankStr       = isOwnerMember and "Owner" or (isOfficer and "Officer" or "Member")

        local memberOpt = membersSub:addOption(targUser)
        memberOpt.iconTexture = ClanRestrictions.iconList[rankStr]
        memberOpt.tooltip = "Rank: " .. rankStr
        local targMember = getPlayerFromUsername(targUser)
        membersSub:setOptionChecked(memberOpt, targMember ~= nil)

        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[rankStr]

        if targMember then
            memberSub:addOption("Online", worldobjects, nil)
        else
            memberSub:addOption("Offline", worldobjects, nil)
        end

        local canKick = (isOwner or isAdmin) or (canOffKick and isOfficer and not isOwnerMember)
        if canKick and not isOwnerMember then
            local kickOpt = memberSub:addOption("Kick", worldobjects, function()
                playerSh:removePlayer(targUser)
                context:hideAndChildren()
            end)
            if not canOffKick and not (isOwner or isAdmin) then
                kickOpt.notAvailable = true
            end
        end

        if (isOwner or isAdmin or (isOfficer and canOffAssign)) and not isOwnerMember then
            if isOfficer then
                local demoteOpt = memberSub:addOption("Demote", worldobjects, function()
                    ClanRestrictions.setOfficer(targUser, false)
                    context:hideAndChildren()
                end)
                if not canOffAssign and not (isOwner or isAdmin) then
                    demoteOpt.notAvailable = true
                end
            else
                local promoteOpt = memberSub:addOption("Promote", worldobjects, function()
                    ClanRestrictions.setOfficer(targUser, true)
                    context:hideAndChildren()
                end)
                if not canOffAssign and not (isOwner or isAdmin) then
                    promoteOpt.notAvailable = true
                end
                if officersCount >= maxOfficers then
                    promoteOpt.notAvailable = true
                end
            end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)
