script_name("AutoRadar for Diamond - RP")
script_author("San_Grene [Sapphire]")
script_description("The script helps to notice nearby criminals")
-- script_dependencies(, пїЅ)
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
  notification("Используйте /aradar чтобы открыть меню")   
  while true do
    wait(0) 
  end     
end 

function events.onServerMessage(color, text)
  msgHandler.handleMessage(text)
end 

function getDistanceToPlayer(data)
  local result, ped = sampGetCharHandleBySampPlayerId(data)
  if (not result) then notification("Не удалось найти игрока с ID = " .. data) return end
  local x, y, _ = getCharCoordinates(PLAYER_PED)
  local x1, y1, _ = getCharCoordinates(ped)
  local distance = getDistanceBetweenCoords2d(x, y, x1, y1)
  sampAddChatMessage(round(distance, 2), -1)    
end 

function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function updateSettings() 
  cHelper.bindParams(_wanted, _pursitsPlayer)
  msgHandler.bindParams(cHelper)
  cParser.bindParams(cHelper)  
  gui.bindParams(cParser)
  cHelper.setSettings( gui.settings)
  registerCommands()   
  startBackgroundFunction()   
end

function getCHelperSettings()
  local settings = {}
  settings.isActive = gui.settings.isWantedFinderActive
  settings.minStars = gui.settings.minStarsCount 
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
  lua_thread.create(function() cHelper.checkWantedPlayers(5000) end)  
  lua_thread.create(function() cHelper.removeOfflineUsers(30000) end)
end
 
function DEV(data)
  sampAddChatMessage(cHelper.maxDistance.v, -1)
  sampAddChatMessage(cHelper.minStars.v, -1)
  for k, v in pairs(_wanted) do
    sampAddChatMessage(k .. " " .. v, -1)
  end 
end

function test(data)
  _wanted[data] = 6                    
end

function getDistanceToPlayer(data)
  local distance = cHelper.getDistanceToPlayer(data)
  if (distance == 999999) then notification("Не удалось найти расстояние до игрока с ID = "..data) return end
  sampAddChatMessage(round(distance, 2) .. " метров", -1 )
 end 

function registerCommands()  
  sampRegisterChatCommand("dev", DEV)    
  sampRegisterChatCommand("test", test)
  sampRegisterChatCommand("tdist", getDistanceToPlayer) 
  sampRegisterChatCommand("refresh", function(notUsed) cParser.refreshWantedList() end) 
  sampRegisterChatCommand("aradar", openMainWindow)
end 