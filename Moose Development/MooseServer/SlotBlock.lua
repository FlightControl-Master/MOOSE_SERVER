do -- start do loop (main)
local slotBlock = {}
net.log('MOOSE Server SlotBlock is loading...') 
-- MOOSE Server SlotBlock version 0.1 - Drex (afinegan), original Script by Ciribob with ideas from Grimes
-- SlotBlock blocks slots, so you can keep people from taking the slot, this can be controlled by base ownership or life amount* (in future)
-- TASK: Write Instructions on how to set mission side flags for slot locking.
-- TASK: Extend module to handle blocking based on amount of lives player has.
-- TASK: Set aside slots for members only (set flags for members based on UCID(most reliable, cant be spoofed))
-- INSTRUCTIONS:
-- 1. to turn on SlotBlock System set "ConfigSlotBlockOn" flag in mission to 1 aka 'trigger.action.setUserFlag("ConfigSlotBlockOn", 1)'
-- 2. Set a flag for every slot you want to block "blockUnitID_".._unitId = 100 aka 'trigger.action.setUserFlag("blockUnitID_1048", 100)', 1048 is the client slot number
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

--EVENTHANDLER
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

--this code monitors the death count, on each death it makes sure if player has enough lives left to spawn in same slot
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
                        player.rejectPlayerSlot(playerID)
                    end
                end
            end
        end
    end
end

--check if player is allowed to change into slot
slotBlock.onPlayerTryChangeSlot = function(playerID, side, slotID)
    if  DCS.isServer() and DCS.isMultiplayer() then
        if  (side ~=0 and  slotID ~='' and slotID ~= nil)  then
            local _allow = clientSlot.shouldAllowSlot(playerID,slotID)
            if not _allow then
                player.rejectPlayerSlot(playerID)
                return false
            else
                local _playerName = net.get_player_info(playerID, 'name')
                if _playerName ~= nil and slotBlock.showEnabledMessage then
                    net.send_chat_to(_chatMessage, playerID)
                end
            end
            net.log("SLOT - allowed -  playerid: "..playerID.." side:"..side.." slot: "..slotID)
        end
    end
    return true
end

net.log('MOOSE:Server SlotBlock was loaded successfully.') 
  --enable Statistics is flag is set correctly
  if config.slotBlockEnabled then
    DCS.setUserCallbacks( slotBlock )  -- here we set our callbacks
    log_write("MOOSE:slotblock enabled: LAST LINE IN DO LOOP - script file is now loaded")
  end
end -- end do loop
