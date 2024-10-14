
local isQB = GetResourceState('qb-core'):match('start')
local isESX = GetResourceState('es_extended'):match('start')
local framework = isQB and exports['qb-core']:GetCoreObject() or isESX and exports['es_extended']:getSharedObject() or {}

local version = "1.2"

function GetLicense(id) 
    return (isESX and framework.GetIdentifier(id) or (isQB) and framework.Functions.GetIdentifier(id, "license:") or (function()
        for _, v in pairs(GetPlayerIdentifiers(id)) do
            if string.find(v, "license") then
                return v
            end
        end
    end)())
end

RegisterServerEvent("ictrophies:server:getCurrentTrophies")
AddEventHandler("ictrophies:server:getCurrentTrophies", function()
    local src = source
    local license = GetLicense(src)
    local steamName = GetPlayerName(src)
    if Config.Mysql == "oxmysql" then
        local trophiesData = exports.oxmysql:query_async("SELECT trophies FROM players_trophies WHERE license = @license", {["@license"] = license})
        if #trophiesData ~= 0 then 
            trophiesData = json.decode(trophiesData[1]["trophies"])
        else
            trophiesData = {}
        end
        TriggerClientEvent("ictrophies:client:getCurrentTrophies", src, trophiesData, steamName)
    elseif Config.Mysql == "icemysql" then
        local trophiesData = exports["ice_mysql"]:MakeQuery(1, "SELECT trophies FROM players_trophies WHERE license = ?", {license})
        if #trophiesData ~= 0 then 
            trophiesData = json.decode(trophiesData[1]["trophies"])
        else
            trophiesData = {}
        end
        TriggerClientEvent("ictrophies:client:getCurrentTrophies", src, trophiesData, steamName)
    else
        print("Can't find mysql system")
    end
end)

RegisterServerEvent("ictrophies:server:newTrophy")
AddEventHandler("ictrophies:server:newTrophy", function(id, currentTrophies)
    currentTrophies[id] = os.date("%d/%m/%Y %H:%M")
    local src = source
    local license = GetLicense(src)
    local count = 0
    for k,v in pairs(currentTrophies) do 
        count = count + 1
    end
    if Config.Mysql == "oxmysql" then
        if count == 1 then 
            exports.oxmysql:insert("INSERT INTO players_trophies (license, trophies) VALUES (@license, @trophies)", {["@license"] = license,["@trophies"] = json.encode(currentTrophies)})
        else
            exports.oxmysql:update("UPDATE players_trophies SET trophies = @trophies WHERE license = @license", {["@license"] = license,["@trophies"] = json.encode(currentTrophies)})
        end
        TriggerClientEvent("ictrophies:client:getCurrentTrophies", src, currentTrophies)
    elseif Config.Mysql == "icemysql" then
        if count == 1 then 
            exports["ice_mysql"]:MakeQuery(1, "INSERT INTO players_trophies (license, trophies) VALUES (?, ?)", {license,json.encode(currentTrophies)})
        else
            local result = exports["ice_mysql"]:MakeQuery(1, "UPDATE players_trophies SET trophies = ? WHERE license = ?", {json.encode(currentTrophies), license})
        end
        TriggerClientEvent("ictrophies:client:getCurrentTrophies", src, currentTrophies)
    else 
        print("Can't find mysql system")
    end
end)

RegisterNetEvent("ictrophies:server:giveMoney", function(amount)
    local src = source
    local Player = isQB and framework.Functions.GetPlayer(src) or framework.GetPlayerFromId(src)
    return isQB and Player.Functions.AddMoney('cash', amount) or isESX and Player.addAccountMoney('money', amount) or (function()
        /* your own framework functionality*/
    end)()
end)

RegisterNetEvent("ictrophies:server:giveItem", function(item, amount)
    local src = source
    local Player = isQB and framework.Functions.GetPlayer(src) or framework.GetPlayerFromId(src)
    return isQB and Player.Functions.AddItem(src, item, amount) or isESX and Player.addInventoryItem(item, amount) or (function()
        /* your own framework functionality*/
    end)()
end)

function NewTrophy(src, id)
    TriggerClientEvent('ictrophies:client:sendTrophies',src, id)
end


CreateThread(function()
    local name = "[^ictrophies^7]"
    local checkVersion = function(error, latestVersion, headers)
        local currentVersion = version
        if currentVersion ~= latestVersion then
            print(name .. " ^1is outdated.\nCurrent version: ^8" .. currentVersion .. "\nNewest version: ^2" .. latestVersion .. "\n^3Update^7: https://github.com/IceClusters/ictrophies")
        end
    end
    PerformHttpRequest("https://raw.githubusercontent.com/IceClusters/IceVersions/develop/ictrophies.version", checkVersion, "GET")
end)

exports('NewTrophy', NewTrophy)

exports('HasTrophy', function(playerId, trophy)
    local license = GetLicense(playerId)
    local trophiesData = exports.oxmysql:query_async("SELECT trophies FROM players_trophies WHERE license = @license", {["@license"] = license})
    if #trophiesData ~= 0 then 
        trophiesData = json.decode(trophiesData[1]["trophies"])
    else
        trophiesData = {}
    end
    if trophiesData[trophy] then
        return true
    else
        return false
    end
end)
