require "lib.moonloader"

function addCriminal(nick, crimeLvl, collection)
  collection[nick] = crimeLvl
end

function increaseCrimeLvl(nick, crimeLvl, collection)
  if (setContainsKey(collection, nick)) then
    collection[nick] = math.min(collection[nick] + crimeLvl, 6) 
    return 
  end
  addCriminal(nick, crimeLvl, collection)  
end

function decreaseCrimeLvl(nick, crimeLvl, collection)
  if (setContainsKey(collection, nick)) then
    collection[nick] = collection[nick] - crimeLvl
    if (collection[nick] <= 0) then 
      removeCriminal(nick, collection)
    end
  end
end

function removeOfflineUsers(nicknames)
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  for id = 0, sampGetMaxPlayerId(false) do
    if (sampIsPlayerConnected(id) or id == myid) then
      local name = sampGetPlayerNickname(id)
      if (setContainsKey(nicknames, name)) then
        nicknames[name] = nil end
    end
  end
  return nicknames
end

function checkWantedPlayers(wantedCollection, pursitCollection, timeout)
  while true do
    wait(timeout)
    for id = 0, sampGetMaxPlayerId(false) do
      if (sampIsPlayerConnected(id)) then
        local name = sampGetPlayerNickname(id)
        if (setContainsKey(wantedCollection, name) and not setContainsKey(pursitCollection, name)) then
          local result, ped = sampGetCharHandleBySampPlayerId(id) 
          if (result) then 
            lua_thread.create(function() startSurveillance(name, id, pursitCollection) end) 
          end
        end
      end
    end
  end
end

function startSurveillance(nick, id, pursitCollection)
  pursitCollection[nick] = true
  local messageToPlayer = getSuspectInfo(nick, id)
  if (messageToPlayer ~= "") then
    dispatcherNotifications(messageToPlayer)
  end
  hangCheckpoint(id)
  pursitCollection[nick] = nil
end

function getSuspectInfo(nick, id)
  local isNear, ped = sampGetCharHandleBySampPlayerId(id)
  if (not isNear) then return "" end
  local info = string.format("Рядом подозреваемый %s", nick)
  local carModel = getPlayerCarModelByPed(ped)
  if (carModel == "") then 
    info = info .. ", передвигается пешком"
  else
    info = info .. ", передвигается на транспорте: " .. carModel
  end
  return info
end

function hangCheckpoint(id)
  local isSucces, ped = sampGetCharHandleBySampPlayerId(id) 
  
  if (not isSucces) then sampAddChatMessage("ss" .. id, -1) return end
  local x, y, z = getCharCoordinates(ped)
  local checkpoint = createCheckpoint(1, x, y, z, x, y, z, 1)
  moveCheckpointToPlayer(id, checkpoint, 30000, 20)
end

function moveCheckpointToPlayer(id, checkpoint, timeout, frequency)
  while (timeout >= 0) do
    local isSucces, ped = sampGetCharHandleBySampPlayerId(id) 
    if (isSucces) then
      local x, y, z = getCharCoordinates(ped)
      setCheckpointCoords(checkpoint, x, y, z)      
    else
      setCheckpointCoords(checkpoint, 0, 0, 0)
      timeout = timeout - frequency
    end
    wait(frequency)
  end
  deleteCheckpoint(checkpoint)
end

function getPlayerCarModelByPed(ped)
  local carHandle = storeCarCharIsInNoSave(ped)
  if (carHandle <= 0) then return "" end
  return getVehicleNameById(getCarModel(carHandle))
end

function setContainsKey(set, key)
  return set[key] ~= nil
end

function calculateCrimeLvl(line)
  local _, count = string.gsub(line, "%]", "")
  return count
end

function removeCriminal(nick, collection)
  if (setContainsKey(collection, nick)) then
    collection[nick] = nil end
end

function pressKey(k)
  setCharKeyDown(k, true)
  wait(20)
  setCharKeyDown(k, false)
end