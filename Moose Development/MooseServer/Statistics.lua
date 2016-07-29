do -- start do loop (main)
local MooseCallBacks = {}
net.log('MOOSE Server Statistics logfile are loading...') 
-- TASK: Use functions LoGetObjectById and LoGetPlayerPlaneId to get players aircraft.
-- TASK: Use DCS.getUnitProperty(missionId, propertyId) with 4 as propertyId to get unittype returned
-- TASK: use net.get_server_id() to identify server admin user and get the server IP address. Use: net.get_player_info(playerID)
-- TASK: Current player list. Use net.get_player_list() -> array of playerID to Returns the list of currently connected players.

local MooseLogsDir = lfs.writedir() .. [[MooseLogs]]
local MooseConfigDir = lfs.writedir() ..[[Scripts/MooseServer]]
local t_serverConfig = {}
local owner_ownerID="1234"
local owner_serverIP="unknown IP"
local owner_serverName="unknown name"
local owner_serverUCID="unknown UCID"

-- !!!! global logging configuration START
moose_servlog = MooseLogsDir.."/MooseServerlog.log"
mooselogger, logerr = io.open(moose_servlog, "w")
if not mooselogger then
  net.log("ERROR: Could not create MOOSE Server Statistics logfile. Error: ".. logerr)
else
  net.log("MOOSE Server Statistics logfile: "..moose_servlog)
end
function log_write(str)
  if nil==str then return end
  if mooselogger then
    mooselogger:write(os.date("%c") .. " : " .. str,"\r\n")
    mooselogger:flush()
  end
end
-- !!!! global logging configuration END
log_write("MOOSE logging enabled: FIRST LINE AFTER LOG CONFIG")

lfs.mkdir(MooseLogsDir)

local loadID = tostring(os.date("%Y%m%d%H%M%S"))
local loadDate = tostring(os.date("%Y-%m-%d"))
local loadTime = tostring(os.date("%H:%M:%S"))

local roundID = loadID
roundCount = 0

local function load_serverConfig()  -- loads server config file with owner information.
  log_write('moose:load_serverConfig: first line in function') 
  file = MooseConfigDir .. '/serverConfig.cfg'
  local f = io.open(file, "r")
  if f then
    f:close()
    log_write('moose:load_serverConfig: FILE exist. ') 
  else
    log_write('moose:load_serverConfig: FILE does NOT exist. ') 
  end

  local confFile, conferr = io.open(MooseConfigDir .. '/serverConfig.cfg', 'r')
  -- log_write('moose: read config file lines to variables: start')
  local lines = {}
  if not confFile then
      return  
    else
      for line in io.lines(confFile) do 
        if line:match("ownerID=(.+)") ~= nil then
          owner_ownerID = tostring(line:match("ownerID=(.+)"))
        end
        if line:match("serverIP=(.+)") ~= nil then
          owner_serverIP = tostring(line:match("serverIP=(.+)"))
        end
        if line:match("serverName=(.+)") ~= nil then
          owner_serverName = tostring(line:match("serverName=(.+)"))
        end
        if line:match("serverUCID=(.+)") ~= nil then
          owner_serverUCID = tostring(line:match("serverUCID=(.+)"))
        end
        lines[#lines + 1] = line
      end
  end
  
  -- log_write('moose: read config file lines to variables: finished')
end

function MooseCallBacks.onNetConnect(localPlayerID)
  log_write('moose:onNetConnect: FIRST line in function') 
  local loadConfig = 0
  if loadConfig >= 0 then
    load_serverConfig()
    loadConfig = 1  
  end

  mlog = io.open(lfs.writedir() .. "MooseLogs/missioninfo_" .. loadID .. ".csv", "w")
  mlog:write('serverIP, loadID, roundID, startTime, missionName\n')
  plog = io.open(lfs.writedir() .. "MooseLogs/playerinfo_" .. loadID .. ".csv", "w")
  plog:write( 'serverIP, loadID, roundID, playerTime, PlayerUCID, PlayerName, PlayerIP\n')
  log_write('MOOSE:logging enabled: ' ..moose_servlog)

  log_write('moose:onNetConnect: LAST line in function') 
end

function MooseCallBacks.onNetMissionChanged(newMissionName)
  log_write('moose:onNetMissionChanged: FIRST line in function') 
  -- Using this function to close round files and roll ower to new round info.
  local missionName = tostring(newMissionName)
  log_write('moose:onNetMissionChanged mission name: ' ..missionName) 
  roundID = tostring(os.date("%Y%m%d%H%M%S"))
  local startTime = tostring(os.date("%Y-%m-%d %H:%M:%S"))
  local simTime = DCS.getModelTime()

  mlog:write( string.format( '"%s", "%s", "%s", "%s", "%s"\n', owner_serverIP, loadID, roundID, startTime, missionName))

  if roundCount == 0 then
    rlog = io.open(lfs.writedir() .. "MooseLogs/roundinfo_" .. loadID .. ".csv", "w")
    rlog:write( "serverIP, loadID, roundID, playerTime, simTime, eventName, PlayerName\n")
    roundCount = 1  
  
  else
    rlog:close()
    rlog = nil
    rlog = io.open(lfs.writedir() .. "MooseLogs/roundinfo_" .. roundID .. ".csv", "w")
    rlog:write( "serverIP, loadID, roundID, playerTime, simTime, eventName, PlayerName\n")
  end
  
end

function MooseCallBacks.onNetDisconnect(reason_msg, err_code)
  log_write('moose:onNetDisconnect: FIRST line in function') 
  -- closes opened files so they can be moved over to webserver
  if rlog then
    rlog:close() -- Closes round log if present.
    rlog = nil
  end

  if mlog then
    mlog:close() -- Closes mission log if present.
    mlog = nil
  end

  if plog then
    plog:close() -- Closes player log if present.
    plog = nil
  end

  if mooselogger then
    mooselogger:close() -- Closes player log if present.
    mooselogger = nil
  end

end

function MooseCallBacks.onPlayerTryConnect(addr, name, ucid, playerID)
  -- don't use this function for anything at the moment, just keep it here.
    return true -- allow the player to connect
end

function MooseCallBacks.onPlayerStart(id)
  -- Not used at this time!!!!
end

function MooseCallBacks.onPlayerChangeSlot(id)
--a player successfully changed the slot. Not needed at the moment, just keep it here.
--  log_write('moose:onPlayerChangeSlot: FIRST line in function') 
--  local PlayerName = net.get_player_info( id, "name" )
end

function MooseCallBacks.onPlayerConnect(id, name)
  log_write('moose:onPlayerConnect: first line in function') 
  local playerTime = tostring(os.date("%Y-%m-%d %H:%M:%S"))
  local PlayerName = net.get_player_info( id, 'name' )
  local PlayerIP = net.get_player_info( id, 'ipaddr' )
  local PlayerUCID = net.get_player_info( id, 'ucid' )
  plog:write(string.format( '"%s", "%s", "%s", "%s", "%s", "%s", "%s"\n', owner_serverIP, loadID, roundID, playerTime, PlayerUCID, PlayerName, PlayerIP))

  log_write('moose:onPlayerConnect: LAST line in function') 
  return
end

function MooseCallBacks.onSimulationStart()
  -- log_write('moose:onSimulationStart: first line in function') 
  -- Not used at this time!!!!
end

function MooseCallBacks.onMissionLoadBegin()
  -- log_write('moose:onMissionLoadBegin: first line in function') 
  -- Not used at this time!!!!
end

function MooseCallBacks.onMissionLoadEnd()
  -- log_write('moose:onMissionLoadEnd: first line in function') 
  -- Not used at this time!!!!
end


function MooseCallBacks.onGameEvent( eventName, arg1, arg2, arg3, arg4 ) 
  log_write('moose:onGameEvent: first line in function. Event: ' ..eventName) 

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
--  net.log('moose_test_getUnitType: ' ..MooseCallBacks.getUnitType(missionId))
-- Use function onGameEvent(eventName,arg1,arg2,arg3,arg4) for disconnect event to log actual time on server.
-- "disconnect", ID_, name, playerSide, reason_code

  --  eventName == "connect" or eventName == "disconnect"
  
  if eventName == "self_kill" or eventName == "change_slot" or eventName == "crash" or eventName == "eject" or eventName == "takeoff" or eventName == "landing" or eventName == "pilot_death" then
    local simTime = DCS.getModelTime()
    local playerTime = tostring(os.date("%Y-%m-%d %H:%M:%S"))
    local PlayerName = net.get_player_info( arg1, "name" )
    rlog:write( string.format( '"%s", "%s", "%s", "%s", "%8f", "%s", "%s"\n', owner_serverIP, loadID, roundID, playerTime, simTime, eventName, PlayerName ) )
  end
  if eventName ==  "connect" or eventName == "disconnect" then
    local simTime = DCS.getModelTime()
    local playerTime = tostring(os.date("%Y-%m-%d %H:%M:%S"))
    local PlayerName = tostring(arg2)
    rlog:write( string.format( '"%s", "%s", "%s", "%s", "%8f", "%s", "%s"\n', owner_serverIP, loadID, roundID, playerTime, simTime, eventName, PlayerName ) )
  end
    

  -- log_write('moose:onGameEvent: LAST line in function. Event: ' ..eventName) 
end

net.log('MOOSE:Server Statistics logfile was loaded successfully.') 
DCS.setUserCallbacks( MooseCallBacks )  -- here we set our callbacks
log_write("MOOSE:logging enabled: LAST LINE IN DO LOOP - script file is now loaded")
end -- end do loop
