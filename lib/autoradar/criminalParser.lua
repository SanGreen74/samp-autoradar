require "lib.moonloader"

local h = {}
local key = require 'lib.vkeys'
local _wantedTextDrawInfo = {}
_wantedTextDrawInfo.firstId = 2000
_wantedTextDrawInfo.lastId = 2200

function h.bindParams(cHelper)
  h.cHelper = cHelper
end

function h.getCriminalsFromWanted()
  sampSendChat("/wanted")
  notification("Команда /wanted отправлена в чат")
  if (not h.waitExpression(3000, function() return h.getTdIdByPattern("^VEHICLE INFO$") ~= -1 end)) then
    error("Не удалось открыть /wanted лист") return nil end
  local result = {}
  while true do 
    h.textDrawParseCriminals(result) 
    local nextPageId = h.getTdIdByPattern("^>$")
    if (nextPageId == -1) then break end
    local current = h.getTdIdByPattern("^1.%s~y~~h~~h~(%w+_%w+)~w~$")
    local isTextDrawSwitched = function() return current == h.getTdIdByPattern("^1.%s~y~~h~~h~(%w+_%w+)~w~$") end
    sampSendClickTextdraw(nextPageId)
    if (not h.waitExpression(3000, isTextDrawSwitched)) then
      error("Не удалось переключиться на следующий страницу") return nil end
    wait(300)
  end
  return result
end

function h.waitExpression(timeout, expression)
  local counter = 0
  while(counter <= timeout) do
    counter = counter + 100
    if (expression()) then return true end
    wait(100)
  end
  return false
end

function h.getTdIdByPattern(pattern)
  for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
    local text = sampTextdrawGetString(i)
    if (text ~= nil and string.match(text, pattern)) then
      return i
    end
  end
  return -1
end

function h.refreshWantedList()
  lua_thread.create(function()
    local count = 0 
    if (sampTextdrawGetString(_wantedTextDrawInfo.exit) ~= "") then
      error("Необходимо закрыть текущий TextDraw") return end
    local peoplesFromWanted = h.getCriminalsFromWanted()
    if (peoplesFromWanted == nil) then return end
    for nick, crimeLvl in pairs(peoplesFromWanted) do
      h.cHelper.addCriminal(nick, crimeLvl)
      count = count + 1
    end
    notification(string.format("Количество обновленных преступников: %d", count))
    pressKey(key.VK_ESCAPE)
  end) 
end

function h.textDrawParseCriminals(result)
  for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
    local text = sampTextdrawGetString(i)
    if (text ~= nil) then
      local nick = string.match(text, "^%d+.%s~y~~h~~h~([a-zA-Z_]+)~w~$")
      if (nick ~= nil) then 
        local crimeLvl = h.cHelper.calculateCrimeLvl(sampTextdrawGetString(i + 1))
        result[nick] = crimeLvl
      end
    end
  end 
end

return h