-- #TODO: Events, ServerExports, Circle Blips, Nui, Nui backend

local BLIPS = nil
local PlayerLoaded = false

BLIPS = {
    Add = function(self, id, coords, label, sprite, size, color, category, temporary)
        if not id then print("[^1ERROR^7] ^5ESX Blips^7 ID missing!") return end

        if type(id) == 'table' then
            for _, data in pairs(id) do
                BLIPS:Add(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8])
            end

            return
        end

        if BLIPS:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip whit this ID already exist!", id) return end

        if not coords then print("[^1ERROR^7] ^5ESX Blips^7 coords missing!") return end

        if not coords.z then coords = vec3(coords.x, coords.y, 0.0) end

        if not category then category = 'default' end

        if not label then label = 'unknown '..id end

        local alpha = PlayerLoaded and 255 or 0

        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, sprite or 1)
        SetBlipScale(blip, size or 0.7)
        SetBlipColour(blip, color or 1)
        SetBlipAlpha(blip, alpha)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandSetBlipName(blip)

        BLIPS.Data[id] = {
            blip = blip,
            coords = coords,
            category = category,
            temporary = temporary
        }

        if temporary then BLIPS:Temp(id, temporary) end
        TriggerEvent('esx_blips:Added', id)
        return id
    end,
    AddCircle = function (self, id, coords, range, color, category)
        -- #TODO
    end,
    Remove = function(self, id)
        if type(id) == 'table' then
            for _, data in pairs(id) do
                if not BLIPS:Exist(data[1]) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
                BLIPS:Remove(data[1])
            end

            return
        end

        if not BLIPS:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
        RemoveBlip(BLIPS.Data[id].blip)
        BLIPS.Data[id] = nil

        TriggerEvent('esx_blips:Removed', id)
        return id
    end,
    DisableCategory = function(self, category)
        for k, v in pairs(BLIPS.Data) do
            if v.category == category then
                SetBlipAlpha(v.blip, 0)
            end
        end

        TriggerEvent('esx_blips:CategoryDisabled', category)
        return category
    end,
    DisableAll = function(self)
        for k, v in pairs(BLIPS.Data) do
            SetBlipAlpha(v.blip, 0)
        end
        TriggerEvent('esx_blips:AllDisabled')
    end,
    EnableCategory = function(self, category)
        for k, v in pairs(BLIPS.Data) do
            if v.category == category then
                SetBlipAlpha(v.blip, 255)
            end
        end

        TriggerEvent('esx_blips:CategoryEnabled', category)
        return category
    end,
    EnableAll = function(self)
        for k, v in pairs(BLIPS.Data) do
            SetBlipAlpha(v.blip, 255)
        end
        TriggerEvent('esx_blips:AllEnabled')
    end,
    SetWayPoint = function(self, id)
        if not BLIPS:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
        SetNewWaypoint(BLIPS.Data[id].coords.x, BLIPS.Data[id].coords.y)

        TriggerEvent('esx_blips:WayPointSet', id)
        return id
    end,
    Exist = function(self, id)
        if BLIPS.Data[id] then return true end
        return false
    end,
    Temp = function(self, id, temporary)
        CreateThread(function()
            while temporary ~= 0 do
                temporary = temporary-1
                if temporary <= 2550 then
                    local alpha = math.floor(temporary / 10)
                    SetBlipAlpha(BLIPS.Data[id].blip, alpha)
                end
                Wait(1)
            end
            BLIPS:Remove(id)
        end)
    end,
    Data = {}
}

-- Exports
exports("Add",function(...)
    BLIPS:Add(...)
end)

exports("Remove",function(...)
    BLIPS:Remove(...)
end)

exports("DisableCategory",function(...)
    BLIPS:DisableCategory(...)
end)

exports("DisableAll",function()
    BLIPS:DisableAll()
end)

exports("EnableCategory",function(...)
    BLIPS:EnableCategory(...)
end)

exports("EnableAll",function()
    BLIPS:EnableAll()
end)

exports("SetWayPoint",function(...)
    BLIPS:SetWayPoint(...)
end)

-- Handlers
AddEventHandler('esx:onPlayerLogout', function()
    PlayerLoaded = false
    BLIPS:DisableAll()

    for id, data in pairs(BLIPS.Data) do 
        if data.temporary then
            BLIPS.Remove(id)
        end
    end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    PlayerLoaded = true
    BLIPS:EnableAll()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    PlayerLoaded = ESX.PlayerLoaded
    -- #TODO: Request all data from scripts where export called? Is it possible?
end)