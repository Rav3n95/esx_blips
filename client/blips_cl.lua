local BLIPS = nil

BLIPS = {
    Add = function(self)
        
    end,
    Disable = function(self, category)
        
    end,
    DisableAll = function(self)
        
    end,
    Enable = function(self, category)
        
    end,
    SetWayPoint = function(self)
        
    end,
    Data = {}
}

-- Handlers
AddEventHandler('esx:onPlayerLogout', BLIPS.DisableAll)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource  then return end

end)
