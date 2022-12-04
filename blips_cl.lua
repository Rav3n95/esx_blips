local BLIPS = nil
local PlayerLoaded, menuActivated, keyPressed = false, false, false
local Categories = {Translate('default')}
BLIPS = {
    Add = function(self, id, coords, label, sprite, size, color, category, temporary)
        local valid = false
        if type(id) == 'table' then
            for _, data in pairs(id) do
                self:Add(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8])
            end

            return
        end

        valid, coords, category = self:Validate(id, coords, category)
        if not valid then return end

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

        if temporary then self:Temp(id, temporary) end
        TriggerEvent('esx_blips:Added', id)
        return id
    end,
    AddCircle = function (self, id, coords, range, color, category, temporary)
        local valid = false
        if type(id) == 'table' then
            for _, data in pairs(id) do
                self:AddCircle(data[1], data[2], data[3], data[4], data[5], data[6])
            end

            return
        end

        valid, coords, category = self:Validate(id, coords, category)
        if not valid then return end

        local alpha = PlayerLoaded and 255 or 0
        local blip = AddBlipForRadius(coords.x, coords.y, coords.z, range or 1)
        SetBlipColour(blip, color or 1)
        SetBlipAlpha(blip, alpha)

        BLIPS.Data[id] = {
            blip = blip,
            coords = coords,
            category = category,
            temporary = temporary
        }

        if temporary then self:Temp(id, temporary) end
        TriggerEvent('esx_blips:Added', id)
        return id
    end,
    Remove = function(self, id)
        if type(id) == 'table' then
            for _, data in pairs(id) do
                if not self:Exist(data[1]) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
                self:Remove(data[1])
            end

            return
        end

        if not self:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
        RemoveBlip(BLIPS.Data[id].blip)
        BLIPS.Data[id] = nil

        TriggerEvent('esx_blips:Removed', id)
        return id
    end,
    ChangeAllState = function(self, state)
        for k, v in pairs(BLIPS.Data) do
            SetBlipAlpha(v.blip, state and 255 or 0)
            SendNUIMessage({type = "updateCategoryState", cat = k, value = state})
        end
        TriggerEvent('esx_blips:ChangeAllStateSet')
    end,
    ChangeCategoryState = function(self, category, state)
        for k, v in pairs(BLIPS.Data) do
            if not v.temporary and v.category == category then
                SetBlipAlpha(v.blip, state and 255 or 0)
                SendNUIMessage({type = "updateCategoryState", cat = category, value = state})
            end
        end

        TriggerEvent('esx_blips:ChangeCategoryStateSet', category, state)
        return category, state
    end,
    SetWayPoint = function(self, id)
        if not self:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip not even exist!", id) return end
        SetNewWaypoint(BLIPS.Data[id].coords.x, BLIPS.Data[id].coords.y)

        TriggerEvent('esx_blips:WayPointSet', id)
        return id
    end,
    SortCategories = function(self, category)
        local tempTable = {}
        
        for i = 1, #Categories do
            Categories[#Categories+1] = category
        end
        table.sort(Categories)

        for k,v in pairs(Categories) do
            if v ~= Categories[k+1] then
                table.insert(tempTable, v)
            end
        end

        Categories = tempTable
        SendNUIMessage({type = "updateData", title = Translate('title'), value = Categories})
    end,
    Validate = function(self, id, coords, category)
        if not id then print("[^1ERROR^7] ^5ESX Blips^7 ID missing!") return false end
        if self:Exist(id) then print("[^1ERROR^7] ^5ESX Blips^7 blip whit this ID already exist!", id) return false end
        if not coords then print("[^1ERROR^7] ^5ESX Blips^7 coords missing!") return false end

        if not coords.z then coords = vec3(coords.x, coords.y, 0.0) end

        if not category then category = Translate('default') end
        if category ~= Translate('default') then self:SortCategories(category) end

        return true, coords, category
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
            self:Remove(id)
        end)
    end,
    MapChecker = function(self)
        CreateThread(function()
            while true do
                if not menuActivated and IsPauseMenuActive() then
                    menuActivated = true
                    SendNUIMessage({type = "showNotify", value = true, text = Translate("reminder")})
                    self:KeyPress()
                elseif menuActivated and not IsPauseMenuActive() then
                    menuActivated, keyPressed = false, false
                    SendNUIMessage({type = "showNotify", value = false})
                end
                Wait(200)
            end
        end)
    end,
    KeyPress = function(self)
        CreateThread(function()
            while menuActivated and not keyPressed do
                if IsDisabledControlJustReleased(2, 73) then
                    keyPressed = true
                    SendNUIMessage({type = "showNotify", value = false})
                    SendNUIMessage({type = "showMenu", value = true})
                    SetNuiFocus(true, true)
                end
                Wait(0)
            end
        end)
    end,
    Data = {}
}

-- Exports
exports("Add",function(...)
    BLIPS:Add(...)
end)

exports("AddCircle",function(...)
    BLIPS:AddCircle(...)
end)

exports("Remove",function(...)
    BLIPS:Remove(...)
end)

exports("ChangeAllState",function(...)
    BLIPS:ChangeAllState(...)
end)

exports("ChangeCategoryState",function(...)
    BLIPS:ChangeCategoryState(...)
end)

exports("SetWayPoint",function(...)
    BLIPS:SetWayPoint(...)
end)

-- Events
RegisterNetEvent('esx_blips:Add', function(...)
    BLIPS:Add(...)
end)

RegisterNetEvent('esx_blips:AddCircle', function(...)
    BLIPS:AddCircle(...)
end)

RegisterNetEvent('esx_blips:Remove', function(...)
    BLIPS:Remove(...)
end)

RegisterNetEvent('esx_blips:ChangeAllState', function(...)
    BLIPS:ChangeAllState(...)
end)

RegisterNetEvent('esx_blips:ChangeCategoryState', function(...)
    BLIPS:ChangeCategoryState(...)
end)

-- NuiCallbacks
RegisterNUICallback('documentReady', function(data, cb)
    cb({title = Translate('title'), value = Categories})
end)

RegisterNUICallback('action', function(data)
    local category = data.target
    local value = data.checked
    BLIPS:ChangeCategoryState(category, value)
end)

RegisterNUICallback('close', function()
    SendNUIMessage({type = "showMenu", value = false})
    SetNuiFocus(false, false)
end)

-- Handlers
AddEventHandler('esx:onPlayerLogout', function()
    PlayerLoaded = false
    BLIPS:ChangeAllState(false)

    for id, data in pairs(BLIPS.Data) do
        if data.temporary then
            BLIPS.Remove(id)
        end
    end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    PlayerLoaded = true
    BLIPS:ChangeAllState(true)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    PlayerLoaded = ESX.PlayerLoaded
    BLIPS:MapChecker()
end)