-- Crear marcadores de propiedades
CreateThread(function()
    while true do
        local wait = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for i = 1, #Config.MarcadoresPropiedades do
            local propiedad = Config.MarcadoresPropiedades[i]
            local distance = #(playerCoords - vector3(propiedad.x, propiedad.y, propiedad.z))
            
            if distance < 20.0 then
                wait = 0
                DrawMarker(2, propiedad.x, propiedad.y, propiedad.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                if distance < 1.5 then
                    ESX.ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para interactuar con la propiedad')
                    
                    if IsControlJustReleased(0, 38) then -- Tecla E
                        AbrirMenuPropiedadDisponible(propiedad)
                    end
                end
            end
        end
        
        Wait(wait)
    end
end)

-- Menú para propiedades disponibles
function AbrirMenuPropiedadDisponible(propiedadData)
    local elements = {
        {label = 'Comprar: $' .. propiedadData.precio, value = 'comprar'},
        {label = 'Alquilar: $' .. (propiedadData.precio * 0.006), value = 'alquilar'},
        {label = 'Información', value = 'info'}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'propiedad_disponible',
    {
        title = '🏠 ' .. propiedadData.tipo .. ' - ' .. propiedadData.id,
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'comprar' then
            TriggerServerEvent('economia:comprarPropiedad', propiedadData)
            menu.close()
        elseif data.current.value == 'alquilar' then
            TriggerServerEvent('economia:alquilarPropiedad', propiedadData)
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Efectos de servicios cortados
RegisterNetEvent('economia:serviciosCortados')
AddEventHandler('economia:serviciosCortados', function(cortados)
    if cortados then
        -- Efectos visuales cuando los servicios están cortados
        SetLightsCutoffDistance(5.0) -- Reducir visibilidad
    else
        SetLightsCutoffDistance(20.0) -- Visibilidad normal
    end
end)
