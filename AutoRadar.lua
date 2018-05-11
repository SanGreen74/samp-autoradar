require "lib.moonloader"
local Criminal = {}

local events = require "lib.samp.events"
local _wantedTextDrawInfo = {}
local _wanted = {}

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("SUPER PUPER AIM ACTEVATED", -1)
    sampRegisterChatCommand("get", getStringFromTextDraw)
    sampRegisterChatCommand("test", parseNamesFromTDPage)
    _wantedTextDrawInfo.firstId = 2088
    _wantedTextDrawInfo.lastId = 2118
    _wantedTextDrawInfo.exit = 2086 
    getCriminalsFromTextDraw()
    while true do
        wait(-1)
    end
end

function events.onServerMessage(color, text)
    return true --todo
end

function handleMessage(text)

end

function getCriminalsFromTextDraw()
    wait(3000)
    sampSendChat("/wanted")
    if (waitOpenTextDraw(3000) == false) then logError("Не удалось открыть лист /wanted")
        return
    end
    textDrawParseCriminals(_wanted)
    local nextPageTdId = _wantedTextDrawInfo.lastId + 1 
    sampSendClickTextdraw(_wantedTextDrawInfo.lastId)
    wait(1000)
    local nextPage = ""
    repeat 
        nextPage = sampTextdrawGetString(nextPageTdId)
        local current = sampTextdrawGetString(_wantedTextDrawInfo.firstId + 2)
        sampSendClickTextdraw(nextPageTdId)
        if (not waitExpression(3000, function() return current == sampTextdrawGetString(_wantedTextDrawInfo.firstId + 2) end )) then
            logError("Не удалось переключиться на следующий страницу") return end
        textDrawParseCriminals(_wanted)
        wait(100)
    until (nextPage == "")
    sampAddChatMessage(nextPage, -1)
    local co = 1
    for i, k in pairs(_wanted) do
        sampAddChatMessage(i .. " " ..k .. " - > " .. co, 0xbbffee)
        co = co+1
    end
end

function textDrawParseCriminals(inCollection)
    for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
        local text = sampTextdrawGetString(i)
        local nick = string.match(text, "^%d+.%s~y~~h~~h~(%w+_%w+)~w~$")
        if (nick ~= nil) then 
            local crimeLvl = calculateCrimeLvl(sampTextdrawGetString(i + 1))
            addCriminal(nick, crimeLvl, inCollection)
        end
    end
end

function addCriminal(nick, crimeLvl, collection)
    if (setContains(collection, nick)) then
        collection[nick] = collection[nick] + crimeLvl
    else
        collection[nick] = crimeLvl
    end
end

function setContains(set, key)
    return set[key] ~= nil
end

function waitOpenTextDraw(timeout)
    local textDrawText = ""
    local count = 0
    while (count <= timeout) do
        count = count + 100
        textDrawText = sampTextdrawGetString(_wantedTextDrawInfo.exit)
        if (textDrawText ~= nil and textDrawText ~= "") then
            return true
        end
        wait(100)
    end
    return false
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

function calculateCrimeLvl(line)
    local _, count = string.gsub(line, "%]", "")
    return count
end

function logError(message)
    sampAddChatMessage("[Error] ".. message, 0xff00bb)
    sampfuncsLog("{ff00bb}" .. message)
end

function getStringFromTextDraw(data)
    if (data == "" or data == nil) then
        sampAddChatMessage("Incorrect input", -1)
        return
    end

    local text = sampTextdrawGetString(data)
    sampAddChatMessage(text, 0xffff00)
end

function testCorrectParse(notUsed)
    for i = _wantedTextDrawInfo.firstId, _wantedTextDrawInfo.lastId do
        local text = sampTextdrawGetString(i)
        if (text ~= nil and text ~= "") then
            local match = string.match(text, "^%d+.%s~y~~h~~h~(%w+_%w+)~w~$")
            if (match ~= nil) then 
                sampAddChatMessage(match, 0xbbffcc)
            end
        end
    end
end



function setMarker(data)
    local str = split(data, " ")
    if (str[1] == "") then
        sampAddChatMessage("Incorrect input", -1)
        return
    end
    sampAddChatMessage(str[1], -1)
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
    lua_thread.create(function() 
        wait(5500) 
        removeBlip(marker)
    end)
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end



Criminal.__index = Criminal;
function Criminal:new(nick, crimeLvl, advertiser)
    local newCriminal = {}
    setmetatable(newCriminal, Criminal)
    newCriminal.nick = nick
    newCriminal.crimeLvl = crimeLvl
    newCriminal.advertiser = advertiser
    return newCriminal
end
function Criminal:increaseCrimeLvl(amount)
    self.crimeLvl = self.crimeLvl + amount
end
function Criminal:decreaseCrimeLvl(amount)
    self.crimeLvl = self.crimeLvl - amount
end