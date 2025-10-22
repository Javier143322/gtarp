fx_version 'cerulean'
game 'gta5'

author 'TuNombre'
description 'Sistema Completo de Economía Realista y Propiedades'
version '2.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/main.lua',
    'server/economia.lua',
    'server/propiedades.lua',
    'server/servicios.lua',
    'server/transacciones.lua'
}

client_scripts {
    'config.lua',
    'client/menus.lua',
    'client/marcadores.lua'
}

shared_scripts {
    'shared/funciones.lua'
}

dependencies {
    'es_extended',
    'mysql-async'
}
