do -- start do loop (main)
local slotBlock = {}
net.log('MOOSE Server SlotBlock is loading...') 
-- MOOSE Server SlotBlock version 0.1 - Drex (afinegan), original Script by Ciribob with ideas from Grimes
-- TASK: Write Instructions on how to set mission side flags for slot locking.
-- TASK: Extend module to handle blocking based on amount of lives player has.
-- TASK: Set aside slots for members only (set flags for members based on UCID(most reliable, cant be spoofed))
-- INSTRUCTIONS:
-- 1. to turn on SlotBlock System set "SLOTBLOCK" flag in mission to 100 aka 'trigger.action.setUserFlag("SLOTBLOCK", 100)'
-- 2. Set a flag for every slot you want to block "AIRCRAFT_".._unitId = 100 aka 'trigger.action.setUserFlag("AIRCRAFT", 100)'
--Note: if flag value changed in config, you must use the new value

--SAMPLE CODE TO USE IN MISSION for turning base slots on and off - it loops through all clients in the _DATABASE table and sets the ownership flags
--START CODE SNIPPIT
--
--local airfieldName = 'batumi'
--local curCoalitionID = 1
--for ClientName, ClientTemplate in pairs( _DATABASE.Templates.ClientsByName ) do
--  unitAccess.curName = ClientTemplate.name
--  if unitAccess.curName == airfieldName then
--    if ClientTemplate.CoalitionID == curCoalitionID then
--      trigger.action.setUserFlag("AIRCRAFT_"..ClientTemplate.unitId, 0)
--    else
--      trigger.action.setUserFlag("AIRCRAFT_"..ClientTemplate.unitId, 100)
--    end
--  end
--end
--
--END CODE SNIPPIT


--SlotBlock Config area
local errorMsgWhenSlotBlocked = "Slot DISABLED, Please capture this airport to use this slot"
local flagBlockValue = 100

--SlotBlock Code area
-- Logic for determining if player is allowed in a slot
function slotBlock.shouldAllowSlot(_playerID, _slotID) -- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID
  if slotBlock.slotBlockEnabled() then 
    local _unitId = slotBlock.getUnitId(_slotID)
    local _flag = slotBlock.getFlagValue("AIRCRAFT_".._unitId)
    if _flag == flagBlockValue and _unitId ~= nil then
      return false
    end
  end
  return true
end

function slotBlock.getFlagValue(_flag)
    local _status,_error  = net.dostring_in('server', " return trigger.misc.getUserFlag(\"".._flag.."\"); ")
    if not _status and _error then
        net.log("error getting flag: ".._error)
        return 0
    else
        net.log("flag value ".._flag.." value: ".._status)
        --disabled
        return tonumber(_status)
    end
end

-- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID
function slotBlock.getUnitId(_slotID)
    local _unitId = tostring(_slotID)
    if string.find(tostring(_unitId),"_",1,true) then
        --extract substring
        _unitId = string.sub(_unitId,1,string.find(_unitId,"_",1,true))
        net.log("Unit ID Substr ".._unitId)
    end

    return tonumber(_unitId)
end

--DOC
-- onGameEvent(eventName,arg1,arg2,arg3,arg4)
--"friendly_fire", playerID, weaponName, victimPlayerID
--"mission_end", winner, msg
--"kill", killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName
--"self_kill", playerID
--"change_slot", playerID, slotID, prevSide
--"connect", id, name
--"disconnect", ID_, name, playerSide
--"crash", playerID, unit_missionID
--"eject", playerID, unit_missionID
--"takeoff", playerID, unit_missionID, airdromeName
--"landing", playerID, unit_missionID, airdromeName
--"pilot_death", playerID, unit_missionID
--
slotBlock.onGameEvent = function(eventName,playerID,arg2,arg3,arg4) -- This stops the user flying again after crashing or other events
    if  DCS.isServer() and DCS.isMultiplayer() then
        if DCS.getModelTime() > 1 then  -- must check this to prevent a possible CTD by using a_do_script before the game is ready to use a_do_script. -- Source GRIMES :)
            if eventName == "self_kill"
                    or eventName == "crash"
                    or eventName == "eject"
                    or eventName ==  "pilot_death" then
                -- is player in a slot and valid?
                local _playerDetails = net.get_player_info(playerID)               
                if _playerDetails ~=nil and _playerDetails.side ~= 0 and _playerDetails.slot ~= "" and _playerDetails.slot ~= nil then
                    local _allow = slotBlock.shouldAllowSlot(playerID, _playerDetails.slot )
                    if not _allow then
                        slotBlock.rejectPlayer(playerID)
                    end
                end
            end
        end
    end
end

slotBlock.onPlayerTryChangeSlot = function(playerID, side, slotID)
    if  DCS.isServer() and DCS.isMultiplayer() then
        if  (side ~=0 and  slotID ~='' and slotID ~= nil)  then
            local _allow = slotBlock.shouldAllowSlot(playerID,slotID)
            if not _allow then
                slotBlock.rejectPlayer(playerID)
                return false
            else
                local _playerName = net.get_player_info(playerID, 'name')
                if _playerName ~= nil and slotBlock.showEnabledMessage and
                  slotBlock.slotBlockEnabled() then
                    net.send_chat_to(_chatMessage, playerID)
                end
            end
            net.log("SLOT - allowed -  playerid: "..playerID.." side:"..side.." slot: "..slotID)
        end
    end
    return true
end

slotBlock.slotBlockEnabled = function()
    local _res = slotBlock.getFlagValue("SLOTBLOCK")
    return _res == 100
end


slotBlock.rejectPlayer = function(playerID)
    net.log("Reject Slot - force spectators - "..playerID)
    -- put to spectators
    net.force_player_slot(playerID, 0, '')
    local _playerName = net.get_player_info(playerID, 'name')
    if _playerName ~= nil then
        --Disable chat message to user
        local _chatMessage = string.format("*** Sorry %s - "..errorMsgWhenSlotBlocked.." ***",_playerName)
        net.send_chat_to(_chatMessage, playerID)
    end
end

slotBlock.trimStr = function(_str)
    return  string.format( "%s", _str:match( "^%s*(.-)%s*$" ) )
end

net.log('MOOSE:Server SlotBlock was loaded successfully.') 
DCS.setUserCallbacks( slotBlock )  -- here we set our callbacks
log_write("MOOSE:slotblock enabled: LAST LINE IN DO LOOP - script file is now loaded")
end -- end do loop
