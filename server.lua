lib.callback.register("elevate-nitro:installNitro", function(source, vehicle)
    local src = source
    local ped = GetPlayerPed(src)
    local vehicle = NetworkGetEntityFromNetworkId(vehicle)
    local state = Entity(vehicle).state
    local item = exports.ox_inventory:GetSlotWithItem(src, Config.nitroItem)
    if not item.metadata.nitro then TriggerClientEvent('ox_lib:notify', src, { title = "Nitro", description = "Flasken er tom!", type = "error" }) return false end
    if state.nitro and state.nitro > 0 then TriggerClientEvent('ox_lib:notify', src, { title = "Nitro", description = "Du har allerede nitro!", type = "error" }) return false end
    local count = exports.ox_inventory:GetItemCount(src, Config.nitroItem)
    if count < 1 then TriggerClientEvent('ox_lib:notify', src, { title = "Nitro", description = "Du har ikke en nitro flaske!", type = "error" }) return false end
    local success, response = exports.ox_inventory:RemoveItem(src, Config.nitroItem, 1, nil, item.slot)
    if not success then TriggerClientEvent('ox_lib:notify', src, { title = "Nitro", description = "Der skete en fejl med at bruge din nitro flaske!", type = "error" }) return false end
    Entity(vehicle).state:set("nitro", item.metadata.nitro, true)
    return true
end)


lib.callback.register("elevate-nitro:removeNitro", function(source, vehicle)
    local src = source
    local ped = GetPlayerPed(src)
    local vehicle = NetworkGetEntityFromNetworkId(vehicle)
    local state = Entity(vehicle).state
    if not state.nitro or state.nitro <= 0 then return false end
    local success, response = exports.ox_inventory:AddItem(src, Config.nitroItem, 1, {nitro = state.nitro})
    if not success then TriggerClientEvent('ox_lib:notify', src, { title = "Nitro", description = "Der skete en fejl med at fjerne din nitro flaske!", type = "error" }) return end
    Entity(vehicle).state:set("nitro", nil, true)
    return true
end)


lib.callback.register("elevate-nitro:server:registerShop", function(source, key)
    local shopInfo = Config.Shops[key]
    exports.ox_inventory:RegisterShop('shopNPC'..key, {
        name = shopInfo.shopLabel,
        inventory = shopInfo.items
    })
    return true
end)