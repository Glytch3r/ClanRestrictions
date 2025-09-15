--ClanRestrictions_Context.lua
ClanRestrictions = ClanRestrictions or {}

function ClanRestrictions.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end

function ClanRestrictions.context(player, context, worldobjects, test)
    local pl = getSpecificPlayer(player)
    local sq = clickedSquare
    if not pl or not sq then return end
    local user = pl:getUsername()
    local safehouse = SafeHouse.hasSafehouse(user)
    if not safehouse then
        local shAtSq = SafeHouse.getSafeHouse(sq)
        if not shAtSq then return end
        safehouse = shAtSq
    end
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
    infoSub:addOption("Officers: " .. tostring(ClanRestrictions.getOfficersStr(safehouse)), worldobjects, nil)
    infoSub:addOption(
        "Coordinates: (X1: " .. tostring(math.floor(safehouse:getX() + 0.5)) ..
        ", Y1: " .. tostring(math.floor(safehouse:getY() + 0.5)) ..
        ") (X2: " .. tostring(math.floor(safehouse:getX2() + 0.5)) ..
        ", Y2: " .. tostring(math.floor(safehouse:getY2() + 0.5)) .. ")",
        worldobjects,
        nil
    )
    infoSub:addOption("Area: W" .. tostring(safehouse:getW()) .. " H" .. tostring(safehouse:getH()), worldobjects, nil)
    local members = safehouse:getPlayers()
    local membersOpt = mainSub:addOptionOnTop("Members: " .. tostring(members:size()) .. "/" .. tostring(SandboxVars.ClanRestrictions.MaxSafehouseMembers or "∞"))
    local membersSub = ISContextMenu:getNew(context)
    context:addSubMenu(membersOpt, membersSub)
    for i = 0, members:size() - 1 do
        local memberName = members:get(i)
        local memberOpt = membersSub:addOption(memberName)
        local memberSub = ISContextMenu:getNew(context)
        context:addSubMenu(memberOpt, memberSub)
        local isOfficer = ClanRestrictions.isOfficer(memberName, safehouse)
        local isOwnerMember = safehouse:getOwner() == memberName
        local rankStr = "Member"
        if isOwnerMember then
            rankStr = "Owner"
        elseif isOfficer then
            rankStr = "Officer"
        end
        local rankOpt = memberSub:addOption("Rank: " .. rankStr, worldobjects, nil)
        rankOpt.iconTexture = ClanRestrictions.iconList[rankStr]
        local onlinePl = getPlayerFromUsername and getPlayerFromUsername(memberName) or nil
        memberSub:addOption("Online: " .. (onlinePl and "Yes" or "No"), worldobjects, nil)
        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            memberSub:addOption("Kick", worldobjects, function()
                safehouse:removePlayer(memberName)
                context:hideAndChildren()
            end)
        end
        if (isOwner or ClanRestrictions.isAdm(pl)) and not isOwnerMember then
            if isOfficer then
                memberSub:addOption("Demote", worldobjects, function()
                    ClanRestrictions.setOfficer(safehouse, memberName, true)
                    context:hideAndChildren()
                end)
            else
                if not ClanRestrictions.isOfficersFull(safehouse) then
                    memberSub:addOption("Promote", worldobjects, function()
                        ClanRestrictions.setOfficer(safehouse, memberName, false)
                        context:hideAndChildren()
                    end)
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ClanRestrictions.context)
