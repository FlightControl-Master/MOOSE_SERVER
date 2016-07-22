do

local MooseCallBacks = {}
loadID = tostring(os.date("%Y%m%d%H%M%S"))
loadDate = tostring(os.date("%Y-%m-%d"))
loadTime = tostring(os.date("%H:%M:%S"))
roundID = loadID
roundCount = 0
mlog = io.open(lfs.writedir() .. "moose/missioninfo_" .. loadID .. ".log", "w")
mlog:write('roundID, simTime, missiontime, cur_mission\n')
plog = io.open(lfs.writedir() .. "moose/playerinfo_" .. loadID .. ".log", "w")
plog:write( "PlayerUCID, PlayerName, PlayerIP\n")

function MooseCallBacks.onPlayerTryConnect(addr, name, ucid, playerID)
    return true -- allow the player to connect
end

function MooseCallBacks.onPlayerStart(id)
  local simTime = DCS.getModelTime()
  local uniqueIndex = tostring(os.date("%Y%m%d%H%M%S")) .. string.format( "%g", simTime)
  local PlayerName = net.get_player_info( id, "name" )
  local playerDate = tostring(os.date("%Y-%m-%d"))
  local playerTime = tostring(os.date("%H:%M:%S"))
  rlog:write( string.format( '"%s", "%s", "%s", "%s", "%8f", "%s", "%s"\n', uniqueIndex, roundID, playerDate, playerTime, simTime, "player_connect", PlayerName ) )
end

function MooseCallBacks.onPlayerConnect(id, name)
    local PlayerName = net.get_player_info( id, 'name' )
    local PlayerIP = net.get_player_info( id, 'ipaddr' )
    local PlayerUCID = net.get_player_info( id, 'ucid' )
    plog:write(string.format( '"%s", "%s", "%s"\n', PlayerUCID, PlayerName, PlayerIP))
  return
end

function MooseCallBacks.onSimulationStart()

end

function MooseCallBacks.onMissionLoadBegin()
  roundID = tostring(os.date("%Y%m%d%H%M%S"))
end

function MooseCallBacks.onMissionLoadEnd()
  local cur_mission = tostring(DCS.getMissionName())
  local missiontime = tostring(os.date("%Y-%m-%d %H:%M:%S"))
  local simTime = DCS.getModelTime()
  mlog:write( string.format( '"%s", "%8f", "%s", "%s"\n', roundID, simTime, missiontime, cur_mission))
  if roundCount == 0 then
    rlog = io.open(lfs.writedir() .. "moose/roundinfo_" .. loadID .. ".log", "w")
    rlog:write( "uniqueIndex, roundID, Date, Time, simTime, eventName, PlayerName\n")
    roundCount = 1  
  else
    rlog:close()
    rlog = nil
    rlog = io.open(lfs.writedir() .. "moose/roundinfo_" .. roundID .. ".log", "w")
    rlog:write( "uniqueIndex, roundID, Date, Time, simTime, eventName, PlayerName\n")
  end
end

function MooseCallBacks.onGameEvent( eventName, arg1, arg2, arg3, arg4 ) 
  if eventName == "self_kill" or eventName == "change_slot" or eventName == "crash" or eventName == "eject" or eventName == "takeoff" or eventName == "landing" or eventName == "pilot_death" then
    local simTime = DCS.getModelTime()
    local realTime = DCS.getRealTime()
    local uniqueIndex = tostring(os.date("%Y%m%d%H%M%S")) .. string.format( "%g", simTime)
  	local playerDate = tostring(os.date("%Y-%m-%d"))
  	local playerTime = tostring(os.date("%H:%M:%S"))
    local PlayerName = net.get_player_info( arg1, "name" )
    rlog:write( string.format( '"%s", "%s", "%s", "%s", "%8f", "%s", "%s"\n', uniqueIndex, roundID, playerDate, playerTime, simTime, eventName, PlayerName ) )
  end
end

DCS.setUserCallbacks( MooseCallBacks )
end
