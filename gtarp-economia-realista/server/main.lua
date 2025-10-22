
ESX = exports["es_extended"]:getSharedObject"]
MySQL = exports['mysql-async']

-- Inicializar tablas de la base de datos
CreateThread(function()
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `user_properties` (
            `id` INT AUTO_INCREMENT,
            `identifier` VARCHAR(60) NOT NULL,
            `property_id` VARCHAR(100) NOT NULL,
            `property_type` VARCHAR(50) NOT NULL,
            `is_owned` TINYINT(1) DEFAULT 0,
            `is_renting` TINYINT(1) DEFAULT 0,
            `rent_due` BIGINT DEFAULT NULL,
            `services_due` BIGINT DEFAULT NULL,
            `mejoras` LONGTEXT DEFAULT '{}',
            `utilities` LONGTEXT DEFAULT '{}',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    print('[ECONOMIA] Sistema de propiedades inicializado')
end)

-- Variables globales
Economia = {
    inflacion = 1.0,
    ofertaDemanda = {}
}