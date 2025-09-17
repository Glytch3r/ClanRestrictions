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
    ClanRestrictionsData.isFactionLocked = ClanRestrictionsData.isFactionLocked or false
    
    return ClanRestrictionsData.isFactionLocked
end

function ClanRestrictions.closeFactPanels()
    if ISFactionUI.instance then ISFactionUI.instance:close() end
    if ISCreateFactionUI.instance then ISCreateFactionUI.instance:close() end
    if ISFactionAddPlayerUI.instance then ISFactionAddPlayerUI.instance:close() end
    if ISCreateFactionTagUI.instance then ISCreateFactionTagUI.instance:close() end
end


function ClanRestrictions.setFactionLocked(isLocked)
    ClanRestrictionsData.isFactionLocked = isLocked
    --ModData.transmit("ClanRestrictionsData")
    ClanRestrictions.sendToServer()
end

--[[ 
sendClientCommand("ClanRestrictions", "Msg", {msg = tostring(ClanRestrictionsData.isFactionLocked)})
 ]]
-----------------------            ---------------------------