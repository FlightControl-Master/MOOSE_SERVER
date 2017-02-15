do -- start do loop (main)
kickBanWatcher={}
net.log('MOOSE Server KickBanWatcher is loading...') 
--run this after every crash/kill/takeoff event, this can handle kicking/banning people for misconduct, store in a table, inside a file

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


net.log('MOOSE:Server KickBanWatcher was loaded successfully.') 
  --enable Statistics is flag is set correctly
  if config.kickBanWatcherEnabled then
    DCS.setUserCallbacks( kickBanWatcher )  -- here we set our callbacks
    log_write("MOOSE:slotblock enabled: LAST LINE IN DO LOOP - script file is now loaded")
  end
end -- end do loop
