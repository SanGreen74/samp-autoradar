require "lib.moonloader"
require "lib.autoradar.notifications"
require "lib.autoradar.cars"
WHITE_LIST = {}

local cHelper = require 'lib.autoradar.criminalHelper'
local msgHandler = require 'lib.autoradar.onMessageHandler'
local cParser = require "lib.autoradar.criminalParser"
local gui = require 'lib.autoradar.gameGui'
            
local events = require "lib.samp.events"
local key = require 'lib.vkeys' 
local _wanted = {} 
local _pursitsPlayer = {}

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  updateSettings()  
  sampAddChatMessage("Script activated", -1)
  while true do
    wait(0) 
  end  
end

function events.onServerMessage(color, text)
  msgHandler.handleMessage(text)
end 

function wr(data)
  for i, k in pairs(_wanted) do
    sampAddChatMessage(i .. " " ..k, -1)
  end
end

function setStringFromTextDraw(data)
  local name = sampGetPlayerNickname(data)
  if (setContainsKey(_wanted, name)) then 
  _wanted[name] = nil 
  return end     
  _wanted[name] = 5
end

function updateSettings() 
  local settings = {}
  cHelper.bindParams(_wanted, _pursitsPlayer, getCHelperSettings())
  msgHandler.bindParams(cHelper)
  cParser.bindParams(cHelper)  
  gui.bindParams(cParser)
  registerCommands() 
  startBackgroundFunction()
end

function getCHelperSettings()
  local settings = {}
  settings.isActive = gui.isWantedFinderActive
  settings.minStars = gui.minStarsCount
  return settings
end

function openMainWindow(params)
  if (canOpenImguiWindow()) then
    gui.changeMainWindowsState()
  end     
end

function canOpenImguiWindow()
  return (not sampIsDialogActive())
end
 
function startBackgroundFunction()
  lua_thread.create(function() cHelper.checkWantedPlayers(5000, gui.isWantedFinderActive) end) 
  lua_thread.create(function() cHelper.removeOfflineUsers(30000) end)
end

function registerCommands()
  sampRegisterChatCommand("set", setStringFromTextDraw) 
  sampRegisterChatCommand("wr", wr)
  sampRegisterChatCommand("refresh", function(notUsed) cParser.refreshWantedList() end) 
  sampRegisterChatCommand("aradar", openMainWindow)
end