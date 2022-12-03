exports("Add",function(playerId, ...)
    TriggerClientEvent('esx_blips:Add', playerId, ...)
end)

exports("AddCircle",function(playerId, ...)
    TriggerClientEvent('esx_blips:AddCircle', playerId, ...)
end)

exports("Remove",function(playerId, ...)
    TriggerClientEvent('esx_blips:Remove', playerId, ...)
end)

exports("DisableCategory",function(playerId, ...)
    TriggerClientEvent('esx_blips:DisableCategory', playerId, ...)
end)

exports("DisableAll",function(playerId)
    TriggerClientEvent('esx_blips:DisableAll', playerId)
end)

exports("EnableCategory",function(playerId, ...)
    TriggerClientEvent('esx_blips:EnableCategory', playerId, ...)
end)

exports("EnableAll",function(playerId)
    TriggerClientEvent('esx_blips:EnableAll', playerId)
end)

exports("SetWayPoint",function(playerId, ...)
    TriggerClientEvent('esx_blips:SetWayPoint', playerId, ...)
end)