require "lib.moonloader"
require "lib.autoradar.criminalHelper"

local key = require 'lib.vkeys'

local _wantedTextDrawInfo = {}
_wantedTextDrawInfo.firstId = 2000
_wantedTextDrawInfo.lastId = 2200

function getCriminalsFromWanted()
  sampSendChat("/wanted")
  notification("Команда /wanted отправлена в чат")
  if (not waitExpression(3000, function() return getTdIdByPattern("^VEHICLE INFO$") ~= -1 end)) then
    error("Не удалось открыть /wanted лист") end
  local result = {}
  while true do 
    textDrawParseCriminals(result) 
    local nextPageId = getTdIdByPattern("^>$")
    if (nextPageId == -1) then break end
    local current = getTdIdByPattern("^1.%s~y~~h~~h~(%w+_%w+)~w~$")
    local isTextDrawSwitched = function() return current == getTdIdByPattern("^1.%s~y~~h~~h~(%w+_%w+)~w~$") end
    sampSendClickTextdraw(nextPageId)
    if (not waitExpression(3000, isTextDrawSwitched)) then
      error("Не удалось переключиться на следующий страницу") return end
    wait(300)
  end
  return result
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

function getTdIdByPattern(pattern)
  for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
    local text = sampTextdrawGetString(i)
    if (text ~= nil and string.match(text, pattern)) then
      return i
    end
  end
  return -1
end

function refreshWantedList(collection)
  lua_thread.create(function()
    local count = 0 
    if (sampTextdrawGetString(_wantedTextDrawInfo.exit) ~= "") then
      error("Необходимо закрыть текущий TextDraw") return end
    for key, value in pairs(getCriminalsFromWanted()) do
      collection[key] = value
      count = count + 1
    end
    notification(string.format("Количество обновленных преступников: %d", count))
    pressKey(key.VK_ESCAPE)
  end) 
end

function textDrawParseCriminals(inCollection)
  for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
    local text = sampTextdrawGetString(i)
    if (text ~= nil) then
      local nick = string.match(text, "^%d+.%s~y~~h~~h~([a-zA-Z_]+)~w~$")
      if (nick ~= nil) then 
        local crimeLvl = calculateCrimeLvl(sampTextdrawGetString(i + 1))
        addCriminal(nick, crimeLvl, inCollection)
      end
    end
  end 
end
