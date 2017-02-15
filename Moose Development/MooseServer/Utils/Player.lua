player = {}

--reject player/force spectators
player.rejectPlayerSlot = function(playerID)
    net.log("Reject Slot - force spectators - "..playerID)
    -- put to spectators
    net.force_player_slot(playerID, 0, '')
    local _playerName = net.get_player_info(playerID, 'name')
    if _playerName ~= nil then
        --Disable chat message to user
        local _chatMessage = string.format("*** Sorry %s - "..config.errorMsgWhenSlotBlocked.." ***",_playerName)
        net.send_chat_to(_chatMessage, playerID)
    end
end

player.kickPlayer = function(playerID, message)
    net.log("Kicking Player - "..playerID)
    -- kick player off the server
    net.kick(playerID, message)
    local _playerName = net.get_player_info(playerID, 'name')
    if _playerName ~= nil then
        --Disable chat message to user
        local _chatMessage = string.format("*** Sorry %s - "..config.errorMsgWhenSlotBlocked.." ***",_playerName)
        net.send_chat_to(_chatMessage, playerID)
    end
end

player.kickPlayerByPing = function(playerID)
  if net.get_stat(playerID, 0) > config.maxPingAllowed then
    local kickMsg = "You have been kicked for having a ping greater than "..config.maxPingAllowed
    player.kickPlayer(playerID, kickMsg)
  end
end