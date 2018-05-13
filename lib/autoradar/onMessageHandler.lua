require 'lib.moonloader'

function handleMessage(text)
  if (handleCriminalInString(text)) then return end
  handlePayDayInString(text)
end

function handleCriminalInString(text)
  local nick, starsCount = string.match(text, "^%[��������%]%s(%w+_%w+)%s��������%s�%s������%s%(?%+(%d)%(?")
  if (nick ~= nil and starsCount ~= nil) then 
    increaseCrimeLvl(nick, starsCount, _wanted) 
    return true 
  end
  
  local nick = string.match(text, "%w+_%w+ ���� ������ (%w+_%w+)$")
  if (nick ~= nil) then
    removeCriminal(nick, _wanted) 
    sampAddChatMessage(string.format("%s ������", nick), 0xbbffcc)--todo
    return true 
  end

  local nick = string.match(text, "%w+_%w+%s[�������������|������]+%s�����������%s'(%w+_%w+)'$")
  if (nick ~= nil) then
    removeCriminal(nick, _wanted) 
    return true 
  end
  return false
end

function handlePayDayInString(text)
  if (string.match(text, "SAPD:{FFFFFF} ������� ������������ � ����� �������� {FF0000}%d.%d")) then
    sampAddChatMessage("DECREASE LVL", 0xFFFF00)
    for key, _ in pairs(_wanted) do
      decreaseCrimeLvl(key, 1, _wanted)
    end
  end
end