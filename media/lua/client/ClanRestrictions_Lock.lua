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
    if not ClanRestrictionsData then
        ClanRestrictionsData = {}
    end
    if type(ClanRestrictionsData.isFactionLocked) ~= "boolean" then
        ClanRestrictionsData.isFactionLocked = true
    end
    return ClanRestrictionsData.isFactionLocked
end

function ClanRestrictions.setFactionLocked(isLocked)
    if type(isLocked) ~= "boolean" then
        isLocked = not ClanRestrictions.isFactionLocked()
    end
    ClanRestrictionsData.isFactionLocked = isLocked
    ClanRestrictions.sendToServer()
end
-----------------------            ---------------------------
function ClanRestrictions.closeFactPanels()
    if ISFactionUI.instance then ISFactionUI.instance:close() end
    if ISCreateFactionUI.instance then ISCreateFactionUI.instance:close() end
    if ISFactionAddPlayerUI.instance then ISFactionAddPlayerUI.instance:close() end
    if ISCreateFactionTagUI.instance then ISCreateFactionTagUI.instance:close() end
end
--[[ 
function ClanRestrictions.isFactionLocked()
    local v = ClanRestrictionsData and ClanRestrictionsData.isFactionLocked
    if v == nil then
        v = true
        ClanRestrictionsData.isFactionLocked = v
    end
    return v == true
end


function ClanRestrictions.setFactionLocked(isLocked)
    if isLocked == nil then
        isLocked = not ClanRestrictions.isFactionLocked()
    end
    ClanRestrictionsData.isFactionLocked = isLocked
    ClanRestrictions.sendToServer()
end
 ]]
--[[ 
sendClientCommand("ClanRestrictions", "Msg", {msg = tostring(ClanRestrictionsData.isFactionLocked)})
 ]]
-----------------------            ---------------------------