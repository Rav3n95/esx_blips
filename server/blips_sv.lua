local BLIPS = nil

-- #TODO: Ha nincs id, generáljunk eggyet resource_..math.random(1,1000) stb

BLIPS = {
    Add = function(self, resource, coords, category, label, colour, scale, sprite, id)
        if not BLIPS.Data[resource] then BLIPS.Data[resource] = {} end
        if not BLIPS.Data[resource][category] then BLIPS.Data[resource][category] = {enabled = true} end
        if not BLIPS.Data[resource][category]['temp'] then BLIPS.Data[resource][category]['temp'] = {} end
        
        if not id then
            BLIPS.Data[resource][category][#BLIPS.Data[resource][category]+1] = {
                coords = coords,
                category = category,
                label = label,
                colour = colour,
                scale = scale,
                sprite = sprite
            }
        else
            if not BLIPS.Data[resource][category]['temp'][id] then BLIPS.Data[resource][category]['temp'][id] = {} end
            BLIPS.Data[resource][category]['temp'][id] = {
                coords = coords,
                category = category,
                label = label,
                colour = colour,
                scale = scale,
                sprite = sprite
            }
        end

        BLIPS:Update()
    end,
    Remove = function(self, resource, id, category)
        if id and not category then
            print("[^1ERROR^7] ^5ESX Blips^7 missing category!")
            return
        end

        if not id then
            BLIPS.Data[resource] = nil
        else
            BLIPS.Data[resource][category]['temp'][id] = nil
        end
        BLIPS:Update()
    end,
    Update = function(self)
        TriggerClientEvent('esx_blips:Collector', -1, BLIPS.Data)
    end,
    Exist = function(self, resource, id, category)
        if BLIPS.Data[resource][category]['temp'][id] then return true end
        return false
    end,
    Validate = function(self, coords, category, label, colour, scale, sprite, id)
        local resource = GetInvokingResource()

        if coords == nil then
            print("[^1ERROR^7] ^5ESX Blips^7 missing coords!")
            return
        end

        if id == nil then id = false end
        if category ~= nil then category = BLIPS:ValidateCategory(category) end
        if category == nil then category = 'default' end
        if label == nil then label = 'Unnamed' end
        if colour == nil then colour = 0 end
        if scale == nil then scale = 1.0 end
        if sprite == nil then sprite = 1 end

        if id and BLIPS:Exist(resource, id, category) then
            print("[^1ERROR^7] ^5ESX Blips^7 blip already exist!")
            return
        end

        BLIPS:Add(resource, coords, category, label, colour, scale, sprite, id)
    end,
    ValidateCategory = function(self, category)
        for i = 1, #Config.Categories do
            if Config.Categories[i] == category then return category end
        end
        return nil
    end,
    Data = {}
}

-- Handlers
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    TriggerClientEvent('esx_blips:Collector', playerId, BLIPS.Data)
end)

AddEventHandler('onResourceStop', function(resource)
    if BLIPS.Data[resource] then
        BLIPS:Remove(resource)
    end
    if GetCurrentResourceName() == resource then
        TriggerClientEvent('esx_blips:RemoveAll', -1)
    end
end)

RegisterNetEvent('esx_blips:Add', function(coords, category, label, colour, scale, sprite, id)
    BLIPS:Validate(coords, category, label, colour, scale, sprite, id)
end)

RegisterNetEvent('esx_blips:Remove', function(id, category)
    local resource = GetInvokingResource()
    BLIPS:Remove(resource, id, category)
end)

RegisterCommand('blip', function(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local temp = false
    TriggerEvent('esx_blips:Add', coords, 'police')
    TriggerEvent('esx_blips:Add', coords, 'ambulance', '1')
    TriggerEvent('esx_blips:Add', coords, 'ambulance', '2')
end)