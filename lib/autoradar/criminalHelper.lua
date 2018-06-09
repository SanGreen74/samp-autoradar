require "lib.moonloader"
require "lib.autoradar.cars"

local h = {}

function h.bindParams(wantedCollection, pursitCollection)
  h.wanted = wantedCollection
  h.pursit = pursitCollection
  h.count = 0  
end

function h.setSettings(settings)
  h.isActive = settings.isWantedFinderActive
  h.minStars = settings.minStarsCount
  h.maxDistance = settings.maxDistance
end

function h.addCriminal(nick, crimeLvl)
  if (not setContainsKey(h.wanted, nick)) then
    h.count = h.count + 1 
  end
  h.wanted[nick] = crimeLvl
end

function h.increaseCrimeLvl(nick, crimeLvl)
  if (setContainsKey(h.wanted, nick)) then
    h.wanted[nick] = math.min(h.wanted[nick] + crimeLvl, 6) 
    return 
  end
  h.addCriminal(nick, crimeLvl)  
end

function h.decreaseCrimeLvlAll()
  for key, _ in pairs(h.wanted) do
    h.decreaseCrimeLvl(key, 1)
  end
end

function h.decreaseCrimeLvl(nick, crimeLvl)
  if (setContainsKey(h.wanted, nick)) then
    h.wanted[nick] = h.wanted[nick] - crimeLvl
    if (h.wanted[nick] <= 0) then 
      h.removeCriminal(nick)
    end
  end
end

function h.getOfflineUsers(nicknames)
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

function h.removeOfflineUsers(frequency)
  while true do 
    local offlineUsers = h.getOfflineUsers(h.copyTable(h.wanted))
    for key, _ in pairs(offlineUsers) do
      -- h.wanted[key] = nil
      h.removeCriminal(key)
    end
    wait(frequency)
  end
end

function h.clearAllCollections()
  h.clearWantedCollection()
  h.clearPursitCollection()
end

function h.clearWantedCollection()
  for k, _ in pairs(h.wanted) do
    h.removeCriminal(k)
  end
end

function h.clearPursitCollection()
  for k, _ in pairs(h.pursit) do
    h.pursit[k] = nil
  end
end

function h.copyTable(table)
  local newTable = {}
  for key,value in pairs(table) do
    newTable[key] = value
  end
  return newTable 
end 

function h.checkWantedPlayers(timeout)
  while true do
    wait(timeout)
    if (h.isActive.v) then
      for id = 0, sampGetMaxPlayerId(false) do
        if (sampIsPlayerConnected(id)) then
          local name = sampGetPlayerNickname(id)
          if (h.canStartSurveillance(name, id)) then
            local result, ped = sampGetCharHandleBySampPlayerId(id) 
            if (result) then 
              local cancellationToken = function() return not setContainsKey(h.wanted, name) end
              lua_thread.create(function() h.startSurveillance(name, id, cancellationToken) end) 
            end
          end
        end
      end
    end
  end
end

function h.canStartSurveillance(nick, id)
  return (setContainsKey(h.wanted, nick) 
          and not setContainsKey(h.pursit, nick)
          and h.wanted[nick] + 0 >= h.minStars.v
          and h.getDistanceToPlayer(id) + 0 <= h.maxDistance.v + 0)
end

function h.getDistanceToPlayer(data)
  local result, ped = sampGetCharHandleBySampPlayerId(data)
  if (not result) then return 999999 end
  local x, y, _ = getCharCoordinates(PLAYER_PED)
  local x1, y1, _ = getCharCoordinates(ped)
  return getDistanceBetweenCoords2d(x, y, x1, y1)
end 

function h.startSurveillance(nick, id, cancellationToken)
  --if (setContainsKey(WHITE_LIST, nick)) then return end
  h.pursit[nick] = true
  local messageToPlayer = h.getSuspectInfo(nick, id)
  if (messageToPlayer ~= "") then
    dispatcherNotification(messageToPlayer)
  end
  h.hangCheckpoint(id, cancellationToken)
  h.pursit[nick] = nil
end

function h.getSuspectInfo(nick, id)
  sampAddChatMessage(nick .. " -> " .. id, -1)
  local isNear, ped = sampGetCharHandleBySampPlayerId(id)
  if (not isNear) then return "" end
  local info = string.format("Рядом подозреваемый {FFFFFF}%s{ff0066}", nick)
  local carModel = h.getPlayerCarModelByPed(ped)
  if (carModel == "") then 
    info = info .. ", передвигается {FFFFFF}пешком"
  else
    info = info .. ", передвигается на транспорте: {FFFFFF}" .. carModel
  end
  return info .. " {FFFF00}" .. h.wanted[nick] .. " зв."
end

function h.hangCheckpoint(id, cancellationToken)
  local isSucces, ped = sampGetCharHandleBySampPlayerId(id) 
  
  if (not isSucces) then sampAddChatMessage("ss" .. id, -1) return end
  local x, y, z = getCharCoordinates(ped)
  local checkpoint = createCheckpoint(1, x, y, z, x, y, z, 1)
  h.moveCheckpointToPlayer(id, checkpoint, 10000, 20, cancellationToken)
end

function h.moveCheckpointToPlayer(id, checkpoint, timeout, frequency, cancellationToken)
  while (timeout >= 0) do
    if (cancellationToken()) then break end
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

function h.getPlayerCarModelByPed(ped)
  sampAddChatMessage(ped, -1)
  if (not doesCharExist(ped) or not isCharInAnyCar(ped)) then 
    sampAddChatMessage("nogi", -1) 
  return "" end
  local carHandle = storeCarCharIsInNoSave(ped)
  sampAddChatMessage("AfterStore", -1)
  if (carHandle <= 0) then return "" end
  return getVehicleNameById(getCarModel(carHandle))
end

function setContainsKey(set, key)
  return set[key] ~= nil
end

function h.calculateCrimeLvl(line)
  local _, count = string.gsub(line, "%]", "")
  return count
end

function h.removeCriminal(nick)
  if (setContainsKey(h.wanted, nick)) then
    h.wanted[nick] = nil 
    h.count = h.count - 1
  end
end

function pressKey(k)
  setCharKeyDown(k, true)
  wait(20)
  setCharKeyDown(k, false)
end

return h