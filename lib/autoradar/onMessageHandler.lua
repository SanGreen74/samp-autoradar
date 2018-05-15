require 'lib.moonloader'

local h = {}

function h.bindParams(cHelper)
  h.cHelper = cHelper
end

function h.handleMessage(text)
  if (h.handleCriminalInString(text)) then return end
  h.handlePayDayInString(text)
end

function h.handleCriminalInString(text)
  local nick, starsCount = string.match(text, "^%[¬нимание%]%s(%w+_%w+)%sобъ€влен%sв%sрозыск%s%(?%+(%d)%(?")
  if (nick ~= nil and starsCount ~= nil) then 
    h.cHelper.increaseCrimeLvl(nick, starsCount) 
    return true 
  end

  local nick = string.match(text, "%w+_%w+ сн€л розыск (%w+_%w+)$")
  if (nick ~= nil) then 
    h.cHelper.removeCriminal(nick) 
    return true 
  end

  local nick = string.match(text, "%w+_%w+%s[нейтрализовал|поймал]+%sпреступника%s'(%w+_%w+)'$")
  if (nick ~= nil) then
    h.cHelper.removeCriminal(nick) 
    return true 
  end
  return false
end

function h.handlePayDayInString(text)
  if (string.match(text, "SAPD:{FFFFFF} ”ровень преступности в штате составил {FF0000}%d.%d")) then
    h.cHelper.decreaseCrimeLvlAll()
  end
end

return h