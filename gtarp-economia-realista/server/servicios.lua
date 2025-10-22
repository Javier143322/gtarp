-- Calcular costos de servicios
function CalcularServicios(propertyType, days, residents, mejoras)
    local servicios = Config.Propiedades.serviciosPublicos
    local total = 0
    local desglose = {}
    local descuentoEficiencia = 1.0

    -- Aplicar descuento por mejoras de eficiencia
    if mejoras and mejoras.eficiencia then
        descuentoEficiencia = 1.0 - (mejoras.eficiencia * 0.15) -- 15% por nivel
    end

    for servicio, config in pairs(servicios) do
        local costo = config.base
        
        if config.variable then
            if servicio == 'agua' then
                costo = costo + (config.consumoPorPersona * residents * days)
            elseif servicio == 'luz' then
                costo = costo + (config.consumoPorHora * 24 * days)
            elseif servicio == 'gas' then
                costo = costo + (config.consumoPorDia * days)
            end
        end
        
        costo = costo * descuentoEficiencia * Economia.inflacion
        total = total + costo
        desglose[servicio] = math.floor(costo)
    end

    return math.floor(total), desglose
end

-- Cobro automático de servicios
function CobrarServiciosAutomaticos()
    local propiedades = MySQL.Sync.fetchAll('SELECT * FROM user_properties')
    
    for i = 1, #propiedades do
        local propiedad = propiedades[i]
        local xPlayer = ESX.GetPlayerFromIdentifier(propiedad.identifier)
        
        if xPlayer and propiedad.services_due <= os.time() then
            local mejoras = json.decode(propiedad.mejoras or '{}')
            local utilities = json.decode(propiedad.utilities or '{}')
            local residentes = utilities.residents or 1
            
            local totalServicios, desglose = CalcularServicios(
                propiedad.property_type, 30, residentes, mejoras
            )
            
            if xPlayer.getMoney() >= totalServicios then
                xPlayer.removeMoney(totalServicios)
                
                local siguienteCobro = os.time() + (30 * 24 * 60 * 60)
                MySQL.Async.execute(
                    'UPDATE user_properties SET services_due = @nuevo WHERE id = @id',
                    {['@nuevo'] = siguienteCobro, ['@id'] = propiedad.id}
                )
                
                local mensaje = '💡 Servicios pagados: $' .. totalServicios
                TriggerClientEvent('esx:showNotification', xPlayer.source, mensaje)
            else
                CortarServicios(xPlayer, propiedad)
            end
        end
    end
end

-- Cobro automático de alquiler
function CobrarAlquileresAutomaticos()
    local propiedades = MySQL.Sync.fetchAll(
        'SELECT * FROM user_properties WHERE is_renting = 1'
    )
    
    for i = 1, #propiedades do
        local propiedad = propiedades[i]
        local xPlayer = ESX.GetPlayerFromIdentifier(propiedad.identifier)
        
        if xPlayer and propiedad.rent_due <= os.time() then
            local configProp = Config.Propiedades.tiposPropiedades[propiedad.property_type]
            local alquiler = configProp.alquilerBase
            local impuestos = alquiler * configProp.impuestos
            local total = alquiler + impuestos
            
            if xPlayer.getMoney() >= total then
                xPlayer.removeMoney(total)
                
                local siguientePago = os.time() + (7 * 24 * 60 * 60)
                MySQL.Async.execute(
                    'UPDATE user_properties SET rent_due = @nuevo WHERE id = @id',
                    {['@nuevo'] = siguientePago, ['@id'] = propiedad.id}
                )
                
                TriggerClientEvent('esx:showNotification', xPlayer.source, 
                    '🏠 Alquiler pagado: $' .. total)
            else
                IniciarDesalojo(xPlayer, propiedad)
            end
        end
    end
end

-- Sistema de desalojos
function IniciarDesalojo(xPlayer, propiedad)
    local tiempoDesalojo = os.time() + (24 * 60 * 60)
    
    MySQL.Async.execute(
        'UPDATE user_properties SET rent_due = @nuevo WHERE id = @id',
        {
            ['@nuevo'] = tiempoDesalojo,
            ['@id'] = propiedad.id
        }
    )
    
    TriggerClientEvent('esx:showNotification', xPlayer.source, 
        '⚠️ Tienes 24 horas para pagar el alquiler!')
    
    SetTimeout(24 * 60 * 60 * 1000, function()
        EjecutarDesalojo(propiedad)
    end)
end

function EjecutarDesalojo(propiedad)
    MySQL.Async.execute(
        'DELETE FROM user_properties WHERE id = @id',
        {['@id'] = propiedad.id}
    )
    
    local xPlayer = ESX.GetPlayerFromIdentifier(propiedad.identifier)
    if xPlayer then
        TriggerClientEvent('esx:showNotification', xPlayer.source, 
            '🚫 Has sido desalojado por no pagar el alquiler')
    end
end

-- Cortar servicios
function CortarServicios(xPlayer, propiedad)
    MySQL.Async.execute(
        'UPDATE user_properties SET utilities = JSON_SET(utilities, "$.servicios_cortados", 1) WHERE id = @id',
        {['@id'] = propiedad.id}
    )
    
    TriggerClientEvent('esx:showNotification', xPlayer.source, 
        '🚫 Servicios cortados por falta de pago')
    TriggerClientEvent('economia:serviciosCortados', xPlayer.source, true)
end

-- Ejecutar cobros automáticos cada hora
CreateThread(function()
    while true do
        Wait(60 * 60 * 1000) -- Cada hora
        CobrarServiciosAutomaticos()
        CobrarAlquileresAutomaticos()
    end
end)
