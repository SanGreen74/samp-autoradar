require "lib.moonloader"
require "lib.autoradar.criminalParser"
require "lib.autoradar.onMessageHandler" 
require "lib.autoradar.criminalHelper"
require "lib.autoradar.notifications"

local imgui = require 'imgui'
local events = require "lib.samp.events"
local key = require 'lib.vkeys' 

local _wanted = {} 
local _pursitsPlayer = {}
local main_window_state = imgui.ImBool(false) 

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  sampAddChatMessage("Script activated", -1)
  sampRegisterChatCommand("get", setMarker)
  sampRegisterChatCommand("set", setStringFromTextDraw)
  sampRegisterChatCommand("refresh", refreshWantedList)
  lua_thread.create(function() checkWantedPlayers(wantedCollection, pursitCollection) end)
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
  handleMessage(text)
end

function checkWantedPlayers(wantedCollection, pursitCollection)
  while true do
    wait(10000)
    for id = 0, sampGetMaxPlayerId(false) do
      if (sampIsPlayerConnected(id)) then
        local name = sampGetPlayerNickname(id)
        if (setContainsKey(wantedCollection, name) and not setContainsKey(pursitCollection, name)) then -- and not setContainsKey(_pursitsPlayer, name)
          local result, ped = sampGetCharHandleBySampPlayerId(id) 
          if (result) then 
            setMarker(id .. " " .. "236")
          end
        end
      end
    end
  end
end

function getTableLength(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

function copyTable(table)
  local newTable = {}
  for key,value in pairs(table) do
    newTable[key] = value
  end
  return newTable
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
    -- local tmp = removeOfflineUsers(copyTable(_wanted))
    -- for key, _ in pairs(tmp) do
    --   _wanted[key] = nil
    -- end
    
    local car = storeCarCharIsInNoSave(PLAYER_PED)

    if (car > 0) then
        local nameofcar = getNameOfVehicleModel(getCarModel(car))
        local color = getCarColours(car)
        local _, id = sampGetVehicleIdByCarHandle(car)
        sampAddChatMessage(nameofcar .. " color " .. getCarModel(car)  , -1)
    end

    -- for key, value in pairs(_wanted) do
    --   sampAddChatMessage(key .. " " .. value , -1)
    -- end
end

function setMarker(data)
    local str = split(data, " ")
    if (str[1] == "") then
        sampAddChatMessage("Incorrect input", -1)
        return
    end
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
    local name = sampGetPlayerNickname(str[1])
    sampAddChatMessage(name .. " -> " ..str[1], 0xff0000)
    _pursitsPlayer[name] = true
    lua_thread.create(function() 
        wait(10000) 
        removeBlip(marker)
        _pursitsPlayer[name] = nil
    end)
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end