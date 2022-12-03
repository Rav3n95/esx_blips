local BLIPS = nil

BLIPS = {
    Add = function(self, id, coords, category, label, sprite, size, color)

        if not id then
            print("[^1ERROR^7] ^5ESX Blips^7 ID missing!")
            return
        end

        if type(id) == 'table' then
            for _, data in ipairs(id) do
                BLIPS:Add(data.id, data.coords, data.category, data.label, data.sprite, data.size, data.color)
            end

            return
        end

        if BLIPS.Exist(id) then
            print("[^1ERROR^7] ^5ESX Blips^7 blip whit this ID already exist!", id)
            return
        end

        if not coords then
            print("[^1ERROR^7] ^5ESX Blips^7 coords missing!")
            return
        end

        if not category then category = 'default' end

        if not label then
            label = 'unknown'..id
        end

        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, sprite or 1)
        SetBlipScale(blip, size or 0.7)
        SetBlipColour(blip, color or 1)
        SetBlipAlpha(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandSetBlipName(blip)

        BLIPS.Data[id] = {
            blip = blip,
            coords = coords,
            category = category
        }
    end,
    Remove = function(self, id)
        if not BLIPS:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end

        if type(id) == 'table' then
            for _, data in ipairs(id) do
                BLIPS:Remove(data)
            end

            return
        end

        RemoveBlip(BLIPS.Data[id].blip)
        BLIPS.Data[id] = nil
    end,
    Disable = function(self, category)
        for k, v in pairs(BLIPS.Data) do
            if v.category == category then
                SetBlipAlpha(v.blip, 0)
            end
        end
    end,
    DisableAll = function(self)
        for k, v in pairs(BLIPS.Data) do
            SetBlipAlpha(v.blip, 0)
        end
    end,
    Enable = function(self, category)
        for k, v in pairs(BLIPS.Data) do
            if v.category == category then
                SetBlipAlpha(v.blip, 255)
            end
        end
    end,
    EnableAll = function(self)
        for k, v in pairs(BLIPS.Data) do
            SetBlipAlpha(v.blip, 255)
        end
    end,
    SetWayPoint = function(self, id)
        if not BLIPS:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
        SetNewWaypoint(BLIPS.Data[id].coords.x, BLIPS.Data[id].coords.y)
    end,
    Exist = function(self, id)
        if BLIPS.Data[id] then return true end
        return false
    end,
    Data = {}
}

-- Handlers
AddEventHandler('esx:onPlayerLogout', BLIPS.DisableAll)

AddEventHandler('esx:onPlayerSpawn', BLIPS.EnableAll)