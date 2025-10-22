-- Comprar propiedad
RegisterServerEvent('economia:comprarPropiedad')
AddEventHandler('economia:comprarPropiedad', function(propertyData)
    local xPlayer = ESX.GetPlayerFromId(source)
    local configProp = Config.Propiedades.tiposPropiedades[propertyData.tipo]
    local precioTotal = configProp.precioCompra
    
    if xPlayer.getMoney() >= precioTotal then
        xPlayer.removeMoney(precioTotal)
        
        MySQL.Async.execute(
            'INSERT INTO user_properties (identifier, property_id, property_type, is_owned, rent_due, services_due, mejoras, utilities) VALUES (@identifier, @property_id, @property_type, 1, @rent_due, @services_due, @mejoras, @utilities)',
            {
                ['@identifier'] = xPlayer.identifier,
                ['@property_id'] = propertyData.id,
                ['@property_type'] = propertyData.tipo,
                ['@rent_due'] = os.time() + (7 * 24 * 60 * 60),
                ['@services_due'] = os.time() + (30 * 24 * 60 * 60),
                ['@mejoras'] = json.encode({}),
                ['@utilities'] = json.encode({residents = 1})
            }
        )
        
        TriggerClientEvent('esx:showNotification', source, 
            '🏠 Propiedad comprada por $' .. precioTotal)
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Fondos insuficientes')
    end
end)

-- Alquilar propiedad
RegisterServerEvent('economia:alquilarPropiedad')
AddEventHandler('economia:alquilarPropiedad', function(propertyData)
    local xPlayer = ESX.GetPlayerFromId(source)
    local configProp = Config.Propiedades.tiposPropiedades[propertyData.tipo]
    local primerPago = configProp.alquilerBase
    
    if xPlayer.getMoney() >= primerPago then
        xPlayer.removeMoney(primerPago)
        
        MySQL.Async.execute(
            'INSERT INTO user_properties (identifier, property_id, property_type, is_renting, rent_due, services_due, mejoras, utilities) VALUES (@identifier, @property_id, @property_type, 1, @rent_due, @services_due, @mejoras, @utilities)',
            {
                ['@identifier'] = xPlayer.identifier,
                ['@property_id'] = propertyData.id,
                ['@property_type'] = propertyData.tipo,
                ['@rent_due'] = os.time() + (7 * 24 * 60 * 60),
                ['@services_due'] = os.time() + (30 * 24 * 60 * 60),
                ['@mejoras'] = json.encode({}),
                ['@utilities'] = json.encode({residents = 1})
            }
        )
        
        TriggerClientEvent('esx:showNotification', source, 
            '🏠 Propiedad alquilada. Primer pago: $' .. primerPago)
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Fondos insuficientes')
    end
end)

-- Mejorar propiedad
RegisterServerEvent('economia:mejorarPropiedad')
AddEventHandler('economia:mejorarPropiedad', function(propertyId, tipoMejora, nivel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local mejoraConfig = Config.Propiedades.mejoras[tipoMejora][nivel]
    
    if not mejoraConfig then
        TriggerClientEvent('esx:showNotification', source, '❌ Mejora no válida')
        return
    end
    
    local propiedad = MySQL.Sync.fetchAll(
        'SELECT * FROM user_properties WHERE identifier = @identifier AND property_id = @property_id',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@property_id'] = propertyId
        }
    )[1]
    
    if propiedad and xPlayer.getMoney() >= mejoraConfig.precio then
        xPlayer.removeMoney(mejoraConfig.precio)
        
        local mejoras = json.decode(propiedad.mejoras or '{}')
        mejoras[tipoMejora] = nivel
        
        MySQL.Async.execute(
            'UPDATE user_properties SET mejoras = @mejoras WHERE id = @id',
            {
                ['@mejoras'] = json.encode(mejoras),
                ['@id'] = propiedad.id
            }
        )
        
        TriggerClientEvent('esx:showNotification', source, 
            '🔧 Mejora instalada: ' .. mejoraConfig.nombre .. ' por $' .. mejoraConfig.precio)
    else
        TriggerClientEvent('esx:showNotification', source, '❌ No puedes realizar esta mejora')
    end
end)

-- Vender propiedad
RegisterServerEvent('economia:venderPropiedad')
AddEventHandler('economia:venderPropiedad', function(propertyId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local propiedad = MySQL.Sync.fetchAll(
        'SELECT * FROM user_properties WHERE identifier = @identifier AND property_id = @property_id',
        {
            ['@identifier'] = xPlayer.identifier,
            ['@property_id'] = propertyId
        }
    )[1]
    
    if propiedad and propiedad.is_owned == 1 then
        local configProp = Config.Propiedades.tiposPropiedades[propiedad.property_type]
        local precioVenta = configProp.precioCompra * 0.8 -- 80% del valor original
        local impuestos = precioVenta * Config.Economia.impuestos.venta
        local gananciaNeta = precioVenta - impuestos
        
        MySQL.Async.execute(
            'DELETE FROM user_properties WHERE id = @id',
            {['@id'] = propiedad.id}
        )
        
        xPlayer.addMoney(gananciaNeta)
        
        TriggerClientEvent('esx:showNotification', source, 
            '🏠 Propiedad vendida. Ganancia: $' .. gananciaNeta .. ' (Impuestos: -$' .. impuestos .. ')')
    else
        TriggerClientEvent('esx:showNotification', source, '❌ No puedes vender esta propiedad')
    end
end)
