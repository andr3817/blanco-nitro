local nitroCooldown = nil
local nitroUIActive = false

lib.onCache('vehicle', function(vehicle)
    if vehicle and Entity(vehicle).state.nitro and (Entity(vehicle).state.nitro > 0) then
        if not nitroUIActive then
            nitroUIActive = true
            SendNUIMessage({
                type = 'showUI',
                show = true
            })
            SendNUIMessage({
                type = 'updateNitro',
                percentage = Entity(vehicle).state.nitro
            })
        end
    else
        if nitroUIActive then
            nitroUIActive = false
            SendNUIMessage({
                type = 'showUI',
                show = false
            })
        end
    end
end)

-- Target interaction
CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            icon = "fa-solid fa-gas-pump",
            label = "Install Nitro",
            items = "nitro",
            onSelect = function(data)
                local vehicle = data.entity
                if Config.vehicles and next(Config.vehicles) and not Config.vehicles[GetEntityModel(vehicle)] then return lib.notify({ title = "Nitro", description = "Denne bil kan ikke have nitro!", type = "error" }) end
                if not Entity(vehicle).state.nitro or Entity(vehicle).state.nitro <= 0 then
                    local install = lib.callback.await('elevate-nitro:installNitro', false, NetworkGetNetworkIdFromEntity(vehicle))
                    if install then
                        lib.notify({ title = "Nitro", description = "Du har installeret nitro!", type = "success" })
                    end
                end
            end,
            canInteract = function(entity)
                if not entity then return false end
                if Entity(entity).state.nitro and Entity(entity).state.nitro > 0 then return false end
                return true
            end
        },
        {
            icon = "fa-solid fa-gas-pump",
            label = "Remove Nitro",
            onSelect = function(data)
                local vehicle = data.entity
                if Entity(vehicle).state.nitro and Entity(vehicle).state.nitro > 0 then
                    local remove = lib.callback.await('elevate-nitro:removeNitro', false, NetworkGetNetworkIdFromEntity(vehicle))
                    if remove then
                        lib.notify({ title = "Nitro", description = "Du har fjernet nitro!", type = "success" })
                    else
                        lib.notify({ title = "Nitro", description = "Der er ikke nitro i bilen!", type = "error" })
                    end
                end
            end,
            canInteract = function(entity)
                if not entity then return false end
                if not Entity(entity).state.nitro or Entity(entity).state.nitro <= 0 then return false end
                return true
            end
        },
    })
end)

-- Keybind
local nitroKeybind = lib.addKeybind({
    name = 'nitro',
    description = 'press CTRL to use nitro',
    defaultKey = 'LCONTROL',
    onPressed = function(self)
        local vehicle = cache.vehicle
        if not vehicle then return end
        if cache.seat ~= -1 then return end
        if not Entity(vehicle).state.nitro or Entity(vehicle).state.nitro <= 0 then return end
        if not nitroCooldown or GetGameTimer() - nitroCooldown >= Config.cooldownDuration then
            SetNitroBoostScreenEffectsEnabled(true)
            Entity(vehicle).state:set("usingNitro", true, true)
            CreateThread(function()
                while self.isPressed and (Entity(vehicle).state.nitro and Entity(vehicle).state.nitro > 0) do
                    local vehicle = cache.vehicle
                    if not vehicle then return end
                    local vehicleModel = GetEntityModel(vehicle)
                    local currentSpeed = GetEntitySpeed(vehicle)
                    local maximumSpeed = GetVehicleModelMaxSpeed(vehicleModel)
                    local multiplier = Config.torqueMultiplier * maximumSpeed / currentSpeed
                    SetVehicleCheatPowerIncrease(vehicle, multiplier)
                    Wait(5)
                end
                
                nitroCooldown = GetGameTimer()
            end)
            useNitro()
        end
    end,
    onReleased = function(self)
        SetNitroBoostScreenEffectsEnabled(false)
        local vehicle = cache.vehicle
        if not vehicle then return end
        local ent = Entity(vehicle)
        if not ent or type(ent) ~= "table" or not ent.state then return end
        ent.state:set("usingNitro", false, true)
    end
})


AddStateBagChangeHandler("usingNitro", nil, function(bagName, key, value) 
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end
    if value then
        startBoostLoop(entity)
    end
end)

AddStateBagChangeHandler("nitro", nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    local ped = PlayerPedId()
    local pedVehicle = GetVehiclePedIsIn(ped, false)
    if entity == 0 then return end
    if pedVehicle ~= entity then return end
    if Entity(entity).state.nitro and (Entity(entity).state.nitro > 0) then
        SendNUIMessage({
            type = 'updateNitro',
            percentage = value
        })
    end
end)

function startBoostLoop(vehicle)
    CreateThread(function()
        while Entity(vehicle).state.usingNitro and Entity(vehicle).state.nitro and (Entity(vehicle).state.nitro > 0) do
            if not IsVehicleStopped(vehicle) then
                SetVehicleBoostActive(vehicle, true)
                CreateVehicleExhaustBackfire(vehicle, 1.25)
                -- CreateVehicleLightTrail(vehicle, "exhaust", 1.25)
            end
            Wait(50)
        end
    end)
end

function useNitro()
    CreateThread(function()
        while nitroKeybind:isControlPressed() and (Entity(cache.vehicle).state.nitro and Entity(cache.vehicle).state.nitro > 0) do
            local vehicle = cache.vehicle
            if not vehicle then return end
            if Entity(vehicle).state.nitro then
                if Entity(vehicle).state.nitro > 0 then
                    Entity(vehicle).state:set("nitro", Entity(vehicle).state.nitro - 4, true)
                else
                    Entity(vehicle).state:set("nitro", nil, true)
                    nitroUIActive = false
                    SendNUIMessage({
                        type = 'showUI',
                        show = false
                    })
                    SendNUIMessage({
                        type = 'updateNitro',
                        percentage = 0
                    })
                    break
                end
            end
            Wait(Config.nitroUsageInterval)
        end
    end)
end

local shopNPC = {}
if next(Config.Shops) then
    CreateThread(function()
        for k, v in pairs(Config.Shops) do
            local pedModel = GetHashKey(v.pedModel)

            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do
                Wait(50)
            end
            SetInterval(function()
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, v.coords.x, v.coords.y, v.coords.z)
                
                if distance < 150 then
                    if not DoesEntityExist(shopNPC[k]) then
                        shopNPC[k] = CreatePed(4, pedModel, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, false)
                        FreezeEntityPosition(shopNPC[k], true)
                        SetEntityInvincible(shopNPC[k], true)
                        TaskStartScenarioInPlace(shopNPC[k], "WORLD_HUMAN_GUARD_STAND", 0, true)
                        SetBlockingOfNonTemporaryEvents(shopNPC[k], true)

                        exports['ox_target']:addLocalEntity(shopNPC[k], {
                            {
                                name = 'shopNPC'..k,
                                label = 'Nitrous Shop',
                                icon = 'fas fa-box',
                                distance = 3,
                                onSelect = function(entity)
                                    local shopCreated = lib.callback.await("elevate-nitro:server:registerShop", false, k)
                                    if shopCreated then
                                        exports.ox_inventory:openInventory('shop', { type = 'shopNPC'..k })
                                    end
                                end,
                                canInteract = function()
                                    local xPlayer = ESX.GetPlayerData()
                                    return k == xPlayer.job.name and (xPlayer.job.grade >= v.minGrade)
                                end
                            },
                        })
                    end
                else
                    if DoesEntityExist(shopNPC[k]) then
                        exports['ox_target']:removeLocalEntity(shopNPC[k])
                        DeleteEntity(shopNPC[k])
                    end
                end
            end, 3000)
        end
    end)
end

exports.ox_inventory:displayMetadata({
    nitro = 'Nitro'
})