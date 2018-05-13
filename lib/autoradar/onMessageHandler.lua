require 'lib.moonloader'
require "lib.autoradar.criminalHelper"


function handleMessage(text, wantedCollection)
  if (handleCriminalInString(text, wantedCollection)) then return end
  handlePayDayInString(text, wantedCollection)
end

function handleCriminalInString(text, wantedCollection)
  local nick, starsCount = string.match(text, "^%[��������%]%s(%w+_%w+)%s��������%s�%s������%s%(?%+(%d)%(?")
  if (nick ~= nil and starsCount ~= nil) then 
    increaseCrimeLvl(nick, starsCount, wantedCollection) 
    return true 
  end

  local nick = string.match(text, "%w+_%w+ ���� ������ (%w+_%w+)$")
  if (nick ~= nil) then 
    removeCriminal(nick, wantedCollection) 
    return true 
  end

  local nick = string.match(text, "%w+_%w+%s[�������������|������]+%s�����������%s'(%w+_%w+)'$")
  if (nick ~= nil) then
    removeCriminal(nick, wantedCollection) 
    return true 
  end
  return false
end

function handlePayDayInString(text, wantedCollection)
  if (string.match(text, "SAPD:{FFFFFF} ������� ������������ � ����� �������� {FF0000}%d.%d")) then
    sampAddChatMessage("DECREASE LVL", 0xFFFF00)
    for key, _ in pairs(wantedCollection) do
      decreaseCrimeLvl(key, 1, wantedCollection)
    end
  end
end