-- Menú principal de economía
RegisterCommand('economia', function()
    ESX.UI.Menu.CloseAll()
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_economia',
    {
        title = '🏦 Sistema Económico',
        align = 'top-right',
        elements = {
            {label = '💳 Estado Cuentas', value = 'cuentas'},
            {label = '📊 Precios Actuales', value = 'precios'},
            {label = '🏠 Mis Propiedades', value = 'propiedades'},
            {label = '🏦 Transferencias', value = 'transferir'},
            {label = '📝 Préstamos', value = 'prestamo'}
        }
    }, function(data, menu)
        local action = data.current.value
        
        if action == 'propiedades' then
            AbrirMenuPropiedades()
        elseif action == 'precios' then
            MostrarPreciosActuales()
        elseif action == 'transferir' then
            AbrirTransferencia()
        end
    end, function(data, menu)
        menu.close()
    end)
end, false)

-- Menú de propiedades del jugador
function AbrirMenuPropiedades()
    ESX.TriggerServerCallback('economia:getPlayerProperties', function(propiedades)
        local elements = {}
        
        if #propiedades == 0 then
            table.insert(elements, {label = 'No tienes propiedades', value = ''})
        else
            for i = 1, #propiedades do
                local prop = propiedades[i]
                local tipo = prop.is_owned == 1 and '🏠 Propia' or '📝 Alquilada'
                local label = string.format('%s %s - %s', tipo, prop.property_type, prop.property_id)
                
                table.insert(elements, {
                    label = label,
                    value = prop.property_id,
                    propiedad = prop
                })
            end
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_propiedades',
        {
            title = '🏠 Mis Propiedades',
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            if data.current.value ~= '' then
                MenuGestionPropiedad(data.current.propiedad)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Gestión individual de propiedad
function MenuGestionPropiedad(propiedad)
    local elements = {
        {label = '📊 Estado de Cuentas', value = 'estado'},
        {label = '🔧 Mejorar Propiedad', value = 'mejorar'},
        {label = '👥 Gestionar Residentes', value = 'residentes'}
    }
    
    if propiedad.is_owned == 1 then
        table.insert(elements, {label = '💰 Vender Propiedad', value = 'vender'})
    else
        table.insert(elements, {label = '💳 Pagar Alquiler', value = 'pagar_alquiler'})
        table.insert(elements, {label = '🚫 Dejar Propiedad', value = 'dejar'})
    end
    
    table.insert(elements, {label = '💡 Pagar Servicios', value = 'pagar_servicios'})
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gestion_propiedad',
    {
        title = '🏠 Gestión: ' .. propiedad.property_id,
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        local action = data.current.value
        
        if action == 'mejorar' then
            AbrirMenuMejoras(propiedad)
        elseif action == 'vender' then
            TriggerServerEvent('economia:venderPropiedad', propiedad.property_id)
        elseif action == 'pagar_alquiler' then
            TriggerServerEvent('economia:pagarAlquilerManual', propiedad.property_id)
        elseif action == 'pagar_servicios' then
            TriggerServerEvent('economia:pagarServiciosManual', propiedad.property_id)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menú de mejoras de propiedad
function AbrirMenuMejoras(propiedad)
    local elements = {}
    local mejoras = Config.Propiedades.mejoras
    
    for tipo, listaMejoras in pairs(mejoras) do
        for i = 1, #listaMejoras do
            local mejora = listaMejoras[i]
            local label = string.format('%s - Nivel %d - $%d', mejora.nombre, mejora.nivel, mejora.precio)
            
            table.insert(elements, {
                label = label,
                value = tipo,
                nivel = mejora.nivel,
                precio = mejora.precio
            })
        end
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_mejoras',
    {
        title = '🔧 Mejorar Propiedad',
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'confirmar_mejora',
        {
            title = 'Confirmar mejora - $' .. data.current.precio
        }, function(data2, menu2)
            menu2.close()
            TriggerServerEvent('economia:mejorarPropiedad', propiedad.property_id, data.current.value, data.current.nivel)
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

-- Mostrar precios actuales
function MostrarPreciosActuales()
    local elements = {}
    
    for producto, precio in pairs(Config.Economia.productos) do
        table.insert(elements, {
            label = string.upper(producto) .. ': $' .. precio,
            value = producto
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_precios',
    {
        title = '📊 Precios Actuales',
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

-- Menú de transferencias
function AbrirTransferencia()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'transferir_id',
    {
        title = 'ID del jugador'
    }, function(data, menu)
        local targetId = tonumber(data.value)
        menu.close()
        
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'transferir_cantidad',
        {
            title = 'Cantidad a transferir'
        }, function(data2, menu2)
            local cantidad = tonumber(data2.value)
            menu2.close()
            
            if targetId and cantidad and cantidad > 0 then
                TriggerServerEvent('economia:transferir', targetId, cantidad)
            else
                ESX.ShowNotification('❌ Datos inválidos')
            end
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end
