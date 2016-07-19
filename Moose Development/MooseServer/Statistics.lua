local MooseCallBacks = {}

function MooseCallBacks.onPlayerTryConnect(ipaddr, name, ucid, playerID)
    print('onPlayerTryConnect(%s, %s, %s, %d)', ipaddr, name, ucid, playerID)
    -- if you want to gently intercept the call, allowing other user scripts to get it,
    -- you better return nothing here
    return true -- allow the player to connect
end

function MooseCallBacks.onSimulationStart()
    print('Current mission is '..DCS.getMissionName())
end

function MooseCallBacks.onGameEvent( eventName, arg1, arg2, arg3, arg4 ) 
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
  local Time = DCS.getModelTime()
  if eventName == "self_kill" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "change_slot" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "crash" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "eject" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "takeoff" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "landing" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  elseif eventName == "pilot_death" then
    local PlayerName = net.get_player_info( arg1, "name" )
    log.write( 'MooseFT', log.INFO, string.format( '"%8f", "%s", "%s"\n', Time, eventName, PlayerName ) )
  end
    
end

function MooseCallBacks.onSimulationPause()
  log.write( 'MooseFT', log.INFO, "Simulation paused.\n" )
end

-- Add date and time as file ID to identify logstart. Dues not need to be user understandable, just unique.
local logtime = tostring(os.date("%Y%m%d%I%M%S"))
log.set_output( 'Moose-FlightTimes_' .. logtime, 'MooseFT', log.TRACE + log.ALL, log.MESSAGE + log.TIME + log.LEVEL )
DCS.setUserCallbacks( MooseCallBacks )  -- here we set our callbacks
