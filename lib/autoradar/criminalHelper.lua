require "lib.moonloader"
require "lib.autoradar.cars"

local h = {}

function h.bindParams(wantedCollection, pursitCollection, settings)
  h.wanted = wantedCollection
  h.pursit = pursitCollection
  h.isActive = settings.isActive
  h.minStars = settings.minStars
  h.count = 0  
end

function h.addCriminal(nick, crimeLvl)
  sampAddChatMessage(h.minStars.v, -1)  
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
      h.wanted[key] = nil
      sampAddChatMessage("ѕользователь вышел из игры " .. key, 0xff0000) --todo
    end
    wait(frequency)
  end
end

function h.copyTable(table)
  local newTable = {}
  for key,value in pairs(table) do
    newTable[key] = value
  end
  return newTable 
end 

function h.checkWantedPlayers(timeout, isActive)
  while true do
    if (isActive.v) then
      wait(timeout)
      for id = 0, sampGetMaxPlayerId(false) do
        if (sampIsPlayerConnected(id)) then
          local name = sampGetPlayerNickname(id)
          if (h.canStartSurveillance(name)) then
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

function h.canStartSurveillance(nick)
  return (setContainsKey(h.wanted, nick) 
          and not setContainsKey(h.pursit, nick)
          and h.wanted[nick] + 0 >= h.minStars.v)
end

function h.startSurveillance(nick, id, cancellationToken)
  if (setContainsKey(WHITE_LIST, nick)) then return end
  h.pursit[nick] = true
  local messageToPlayer = h.getSuspectInfo(nick, id)
  if (messageToPlayer ~= "") then
    dispatcherNotifications(messageToPlayer)
  end
  h.hangCheckpoint(id, cancellationToken)
  h.pursit[nick] = nil
end

function h.getSuspectInfo(nick, id)
  local isNear, ped = sampGetCharHandleBySampPlayerId(id)
  if (not isNear) then return "" end
  local info = string.format("–€дом подозреваемый {FFFFFF}%s{ff0066}", nick)
  local carModel = h.getPlayerCarModelByPed(ped)
  if (carModel == "") then 
    info = info .. ", передвигаетс€ {FFFFFF}пешком"
  else
    info = info .. ", передвигаетс€ на транспорте: {FFFFFF}" .. carModel
  end
  return info
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
  local carHandle = storeCarCharIsInNoSave(ped)
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