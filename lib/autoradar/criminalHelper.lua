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