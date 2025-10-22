-- Sistema de nóminas
function CalcularNomina(job, horas, rendimiento)
    local salarioBase = Config.Economia.salarios[job] or Config.Economia.salarios.civil
    local inflacion = Economia.inflacion
    
    local salarioBruto = (salarioBase * horas * inflacion) * rendimiento
    local impuestos = salarioBruto * Config.Economia.impuestos.ingreso
    local salarioNeto = salarioBruto - impuestos
    
    return math.floor(salarioNeto)
end

RegisterServerEvent('economia:pagarNomina')
AddEventHandler('economia:pagarNomina', function(job, horas, rendimiento)
    local xPlayer = ESX.GetPlayerFromId(source)
    local nomina = CalcularNomina(job, horas, rendimiento)
    
    if nomina > 0 then
        xPlayer.addMoney(nomina)
        TriggerClientEvent('esx:showNotification', source, 
            '💰 Nómina: $' .. nomina .. ' (Impuestos: -' .. (Config.Economia.impuestos.ingreso*100) .. '%)')
    end
end)

-- Sistema de precios dinámicos
function ActualizarPrecios()
    for item, precioBase in pairs(Config.Economia.productos) do
        local demanda = Economia.ofertaDemanda[item] or 1.0
        local nuevoPrecio = precioBase * demanda * Economia.inflacion
        Config.Economia.productos[item] = math.floor(nuevoPrecio * 100) / 100
    end
    
    local variacion = (math.random(90, 110) / 100)
    Economia.inflacion = Economia.inflacion * variacion
    
    print('[ECONOMIA] Precios actualizados. Inflación: ' .. (Economia.inflacion*100) .. '%')
end

-- Actualizar cada 24 horas
CreateThread(function()
    while true do
        Wait(24 * 60 * 60 * 1000)
        ActualizarPrecios()
    end
end)