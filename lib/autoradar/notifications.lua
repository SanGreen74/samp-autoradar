require "lib.moonloader"

function error(message)
  sampAddChatMessage("[Error] ".. message, 0xff0000)
  sampfuncsLog("{ff0000}[Error]" .. message)
end

function notification(text) 
  sampAddChatMessage("[Notification] " ..text, 0xff00bb)
end

function dispatcherNotification(text)
  sampAddChatMessage("[Диспетчер] " .. text, 0xff0066)
end