require "lib.moonloader"
local imgui = require 'imgui'
local events = require "lib.samp.events"
local key = require 'lib.vkeys'

local _wantedTextDrawInfo = {}
local _wanted = {} 
local main_window_state = imgui.ImBool(false)

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  sampAddChatMessage("Script activated", -1)
  sampRegisterChatCommand("get", getStringFromTextDraw)
  sampRegisterChatCommand("set", setStringFromTextDraw)
  sampRegisterChatCommand("refresh", refreshWantedList)
  _wantedTextDrawInfo.firstId = 2088
  _wantedTextDrawInfo.lastId = 2118
  _wantedTextDrawInfo.exit = 2086 
  while true do
    wait(0)
    if wasKeyPressed(key.VK_X) then 
      main_window_state.v = not main_window_state.v 
    end
    imgui.Process = main_window_state.v
  end
end

function events.onServerMessage(color, text)
  handleMessage(text)
end

function handleMessage(text)
  if (handleCriminalInString(text)) then return end
  handlePayDayInString(text)
end

function handleCriminalInString(text)
  local nick, starsCount = string.match(text, "^%[Внимание%]%s(%w+_%w+)%sобъявлен%sв%sрозыск%s%(?%+(%d)%(?")
  if (nick ~= nil and starsCount ~= nil) then 
    increaseCrimeLvl(nick, starsCount, _wanted) 
    return true 
  end
    
  local nick = string.match(text, "%w+_%w+ снял розыск (%w+_%w+)$")
  if (nick ~= nil) then
    removeCriminal(nick, _wanted) 
    return true 
  end

  local nick = string.match(text, "%w+_%w+%s[нейтрализовал|поймал]+%sпреступника%s'(%w+_%w+)'$")
  if (nick ~= nil) then
    removeCriminal(nick, _wanted) 
    return true 
  end
  return false
end

function handlePayDayInString(text)
  local patterns = {"Вы не получили PayDay, потому что не отыграли 25 минут",
  "Вы не получили PayDay, потому что не отыграли 25 минут"}
end

function refreshWantedList(notUsed)
  lua_thread.create(function()
    local count = 0 
    if (sampTextdrawGetString(_wantedTextDrawInfo.exit) ~= "") then
      error("Необходимо закрыть текущий TextDraw") return end
    for key, value in pairs(getCriminalsFromWanted()) do
      _wanted[key] = value
      count = count + 1
    end
    notification(string.format("Количество обновленных преступников: %d", count))
    pressKey(key.VK_ESCAPE)
  end)
end

function getCriminalsFromWanted()
  sampSendChat("/wanted")
  if (waitOpenTextDraw(3000) == false) then 
    error("Не удалось открыть лист /wanted") return end
  local nextPageId = _wantedTextDrawInfo.lastId
  local shift = 1
  local result = {}
  while true do 
    textDrawParseCriminals(result) 
    nextPage = sampTextdrawGetString(nextPageId)
    if (nextPage == "") then 
      break end
    local current = sampTextdrawGetString(_wantedTextDrawInfo.firstId + shift)
    local isTextDrawSwitched = function() return current ~= sampTextdrawGetString(_wantedTextDrawInfo.firstId + shift) end
    sampSendClickTextdraw(nextPageId)
    if (not waitExpression(3000, isTextDrawSwitched)) then
      error("Не удалось переключиться на следующий страницу") return end
    nextPageId = _wantedTextDrawInfo.lastId + 1
    if (shift ~= 2) then shift = shift + 1 end
    wait(300)
  end
  return result
end

function textDrawParseCriminals(inCollection)
  for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
    local text = sampTextdrawGetString(i)
    local nick = string.match(text, "^%d+.%s~y~~h~~h~(%w+_%w+)~w~$")
    if (nick ~= nil) then 
      local crimeLvl = calculateCrimeLvl(sampTextdrawGetString(i + 1))
      addCriminal(nick, crimeLvl, inCollection)
    end
  end 
end

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

function removeCriminal(nick, collection)
  if (setContainsKey(collection, nick)) then
    collection[nick] = nil end
end

function setContainsKey(set, key)
  return set[key] ~= nil
end

function waitOpenTextDraw(timeout)
  local textDrawText = ""
  local count = 0
  while (count <= timeout) do
    count = count + 100
    textDrawText = sampTextdrawGetString(_wantedTextDrawInfo.exit)
    if (textDrawText ~= nil and textDrawText ~= "") then
      return true
    end
    wait(100)
  end
  return false
end

function waitExpression(timeout, expression)
  local counter = 0
  while(counter <= timeout) do
    counter = counter + 100
    if (expression()) then return true end
    wait(100)
  end
  return false
end

function calculateCrimeLvl(line)
  local _, count = string.gsub(line, "%]", "")
  return count
end

function error(message)
  sampAddChatMessage("[Error] ".. message, 0xff0000)
  sampfuncsLog("{ff0000}[Error]" .. message)
end

function notification(text) 
  sampAddChatMessage("[Notification] " ..text, 0xff00bb)
end

function pressKey(k)
  setCharKeyDown(k, true)
  wait(20)
  setCharKeyDown(k, false)
end

function getTableLength(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

function imgui.OnDrawFrame()
  if main_window_state.v then 
    imgui.SetNextWindowSize(imgui.ImVec2(150, 200), imgui.Cond.FirstUseEver) -- меняем размер

    imgui.Begin('My window', main_window_state)
    imgui.Text('Hello world')
    if imgui.Button('Press me') then
      refreshWantedList(nil)
    end
    imgui.End()
  end
end


function getStringFromTextDraw(data)
  if (data == "" or data == nil) then
    sampAddChatMessage("Incorrect input", -1)
    return
  end

  local text = sampTextdrawGetString(data)
  sampAddChatMessage(text, 0xffff00)
end

function setStringFromTextDraw(data)
    for nick, starsCount in pairs(_wanted) do
      sampAddChatMessage(string.format("Nick: %s. Звезды: %s", nick, starsCount), -1)
    end
end

function testCorrectParse(notUsed)
    for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
        local text = sampTextdrawGetString(i)
        if (text ~= nil and text ~= "") then
            local match = string.match(text, "^%d+.%s~y~~h~~h~(%w+_%w+)~w~$")
            if (match ~= nil) then 
                sampAddChatMessage(match, 0xbbffcc)
            end
        end
    end
end

function setMarker(data)
    local str = split(data, " ")
    if (str[1] == "") then
        sampAddChatMessage("Incorrect input", -1)
        return
    end
    sampAddChatMessage(str[1], -1)
    local isSuccesGetPlayerPed, ped = sampGetCharHandleBySampPlayerId(str[1])
    if (isSuccesGetPlayerPed ~= true) then
        sampAddChatMessage("Can't getting player ped", -1)
        return
    end
    
    local car = storeCarCharIsInNoSave(ped)

    if (car > 0) then
        local nameofcar = getNameOfVehicleModel(getCarModel(car))
        local color = getCarColours(car)
        sampAddChatMessage(nameofcar .. " color " .. color  , -1)
    end

    local isSuccesGetPlayerPed, ped = sampGetCharHandleBySampPlayerId(str[1])
    
    if (isSuccesGetPlayerPed ~= true) then
        sampAddChatMessage("Can't getting player ped", -1)
        return
    end 

    local marker = addBlipForChar(ped)
    changeBlipColour(marker, str[2])
    lua_thread.create(function() 
        wait(5500) 
        removeBlip(marker)
    end)
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end