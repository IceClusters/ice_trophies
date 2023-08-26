local currentTrophies = {}
local trophiesRecived = false

Citizen.CreateThread(function()
    TriggerServerEvent("ice_trophies:server:getCurrentTrophies")
end)

function TableLength(tabla)
    local amount = 0
    if tabla ~= nil then
        for _ in pairs(tabla) do
            amount = amount + 1
        end
    end
    return amount
end

RegisterNetEvent("ice_trophies:client:getCurrentTrophies")
AddEventHandler("ice_trophies:client:getCurrentTrophies", function(data, playerName)
    trophiesRecived = true
    currentTrophies = data
    local trophiesCategory = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0
    }
    if data ~= nil  then
        for trophieName, v in pairs(data) do 
            print(trophieName)
            trophiesCategory[Config.Trophies[trophieName]["other"]["type"]] = trophiesCategory[Config.Trophies[trophieName]["other"]["type"]] + 1
        end
    end
    SendNUIMessage({
        action = "UpdateTrophiesData",
        trophies = currentTrophies,
        trophiesAmount = TableLength(currentTrophies),
        trophiesPercentage = math.floor(((TableLength(currentTrophies) / TableLength(Config.Trophies)) * 100)),
        allTrophies = TableLength(Config.Trophies),
        trophiesCategory = trophiesCategory,
        config = Config.Trophies,
        steamName = playerName
    })
end)

function NewTrophy(id)
    if not trophiesRecived then
        return
    end
    local alreadyExist = false
    if currentTrophies ~= nil then 
        for k, v in pairs(currentTrophies) do 
            if k == id then 
                alreadyExist = true
            end
        end
    end

    -- if alreadyExist then 
    --     return
    -- end
    if currentTrophies ~= nil then 
        TriggerServerEvent("ice_trophies:server:newTrophy", id, currentTrophies)
    else
        TriggerServerEvent("ice_trophies:server:newTrophy", id, {})
    end

    SendNUIMessage({
        action = "NewTrophy",
        title = Config.Trophies[id].title,
        description = Config.Trophies[id].description,
        type = Config.Trophies[id]["other"]["type"],
        volume = Config.AchivementVolume,
        confetti = Config.Trophies[id]["other"]["confetti"],
        sound = Config.Trophies[id]["other"]["sound"]
    })
end

local isOpen = false

RegisterKeyMapping("trophyList", "Open Trophies", "keyboard", Config.OpenMenu)
RegisterCommand("trophyList", function()
    -- if not trophiesRecived then
        TriggerServerEvent("ice_trophies:server:getCurrentTrophies")
    -- end
    if(IsNuiFocused()) then 
        return
    end
    SendNUIMessage({
        action = "OpenMenu"
    })
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    isOpen = true

    disableMovementAction()
end, false)

RegisterCommand("trophy", function(source, args)
    -- if args[1] ~= nil then 
        NewTrophy("phone")
    -- end
end, false)


RegisterCommand("fixtrophy", function()
    TriggerServerEvent("ice_trophies:server:getCurrentTrophies")
end, false)

RegisterNUICallback("menuclose", function(cb)
    print("close")
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    isOpen = false
end)

RegisterCommand("settrophyvolumen", function(source, args)
    if args[1] ~= nil then 
        SendNUIMessage({
            action = "SetTrophyVolumen",
            volumen = tonumber(args[1])
        })
    end
end, false)

function disableMovementAction()
    while (isOpen) do
        Citizen.Wait(0)
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 287, true)
        DisableControlAction(0, 286, true)
        DisableControlAction(0, 18, true)
        DisableControlAction(0, 45, true)
        DisableControlAction(0, 80, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 26, true)
        DisableControlAction(0, 199, true)
    end
end
exports('NewTrophy', NewTrophy)