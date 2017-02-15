--all client slot based functions in here
clientSlot={}

-- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID
function clientSlot.getUnitId(_slotID)
    local _unitId = tostring(_slotID)
    if clientSlot.find(tostring(_unitId),"_",1,true) then
        --extract substring
        _unitId = string.sub(_unitId,1,string.find(_unitId,"_",1,true))
        net.log("Unit ID Substr ".._unitId)
    end
    return tonumber(_unitId)
end

-- Logic for determining if player is allowed in a slot, should check lives if configured (_playerID)
function clientSlot.shouldAllowSlot(_slotID) -- _slotID == Unit ID unless its multi aircraft in which case slotID is unitId_seatID 
  local _unitId = clientSlot.getUnitId(_slotID)
  local _flag = clientSlot.getFlagValue("blockUnitID_".._unitId)
  if _flag == config.flagBlockValue and _unitId ~= nil then
    return false
  end
  return true
end