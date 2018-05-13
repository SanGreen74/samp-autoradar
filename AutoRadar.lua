require "lib.moonloader"
require "lib.autoradar.onMessageHandler" 
require "lib.autoradar.criminalParser"
require "lib.autoradar.criminalHelper"
require "lib.autoradar.notifications"
require "lib.autoradar.cars"

local imgui = require 'imgui'
local events = require "lib.samp.events"
local key = require 'lib.vkeys' 

_wanted = {} 
local _pursitsPlayer = {}
local main_window_state = imgui.ImBool(false) 

function main() 
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  sampAddChatMessage("Script activated", -1)
  sampRegisterChatCommand("set", setStringFromTextDraw) 
  sampRegisterChatCommand("wr", wr) 
  sampRegisterChatCommand("refresh", refreshWantedList)
  lua_thread.create(function() checkWantedPlayers(_wanted, _pursitsPlayer, 5000) end)
  lua_thread.create(function()
    while true do 
      local tmp = removeOfflineUsers(copyTable(_wanted))
      for key, _ in pairs(tmp) do
        _wanted[key] = nil
        sampAddChatMessage("ѕользователь вышел из игры " .. key, 0xff0000) --todo
      end
      wait(30000)
    end
  end)
  while true do
    wait(0) 
    if wasKeyPressed(key.VK_X) then
      main_window_state.v = not main_window_state.v 
    end
    imgui.Process = main_window_state.v
  end
end

function events.onServerMessage(color, text)
  handleMessage(text, _wanted) 
end

function copyTable(table)
  local newTable = {}
  for key,value in pairs(table) do
    newTable[key] = value
  end
  return newTable 
end 

function wr(data)
  for i, k in pairs(_wanted) do
    sampAddChatMessage(i .. " " ..k, -1)
  end
end

function imgui.OnDrawFrame()
  if main_window_state.v then 
    imgui.SetNextWindowSize(imgui.ImVec2(150, 200), imgui.Cond.FirstUseEver) -- мен€ем размер

    imgui.Begin('My window', main_window_state)
    imgui.Text('Hello world')
    if imgui.Button('Press me') then
      refreshWantedList(_wanted)
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
  local name = sampGetPlayerNickname(data)
  _wanted[name] = 6
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end