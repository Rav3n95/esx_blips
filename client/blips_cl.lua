local BLIPS = nil

BLIPS = {
    Add = function(self, id, coords, category, label, sprite, size, color)

        if not id then
            print("[^1ERROR^7] ^5ESX Blips^7 ID missing!")
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
        SetBlipAlpha(blip, 255)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandSetBlipName(blip)

        BLIPS.Data[category][id] = {
            blip = blip,
            coords = coords
        }
    end,
    Disable = function(self, category)
        
    end,
    DisableAll = function(self)
        
    end,
    Enable = function(self, category)
        
    end,
    EnableAll = function(self)
        
    end,
    SetWayPoint = function(self)
        
    end,
    Data = {}
}

-- Handlers
AddEventHandler('esx:onPlayerLogout', BLIPS.DisableAll)

AddEventHandler('esx:playerLoaded', BLIPS.EnableAll)