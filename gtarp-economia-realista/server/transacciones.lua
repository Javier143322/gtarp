-- Sistema bancario y transferencias
RegisterServerEvent('economia:transferir')
AddEventHandler('economia:transferir', function(targetId, cantidad)
    local sourcePlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if sourcePlayer and targetPlayer and sourcePlayer.getMoney() >= cantidad then
        local comision = math.floor(cantidad * 0.01) -- 1% comisión
        
        sourcePlayer.removeMoney(cantidad + comision)
        targetPlayer.addMoney(cantidad)
        
        TriggerClientEvent('esx:showNotification', source, 
            '✅ Transferencia: $' .. cantidad .. ' (Comisión: $' .. comision .. ')')
        TriggerClientEvent('esx:showNotification', targetId, 
            '💰 Recibiste: $' .. cantidad)
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Transferencia fallida')
    end
end)

-- Préstamos bancarios
RegisterServerEvent('economia:solicitarPrestamo')
AddEventHandler('economia:solicitarPrestamo', function(cantidad)
    local xPlayer = ESX.GetPlayerFromId(source)
    local intereses = cantidad * 0.15 -- 15% interés
    
    xPlayer.addMoney(cantidad)
    
    -- Registrar deuda (implementar sistema de deudas)
    TriggerClientEvent('esx:showNotification', source, 
        '🏦 Préstamo: $' .. cantidad .. ' (Interés: $' .. intereses .. ')')
end)

-- Callback para obtener propiedades del jugador
ESX.RegisterServerCallback('economia:getPlayerProperties', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local propiedades = MySQL.Sync.fetchAll(
        'SELECT * FROM user_properties WHERE identifier = @identifier',
        {['@identifier'] = xPlayer.identifier}
    )
    
    cb(propiedades)
end)
