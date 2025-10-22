
Config = {}

-- Configuración económica principal
Config.Economia = {
    inflacion = 1.0,
    impuestos = {
        ingreso = 0.15,
        propiedad = 0.03,
        venta = 0.10
    },
    
    salarios = {
        policia = 650, mecanico = 550, camionero = 480,
        taxista = 420, medico = 700, civil = 350
    },
    
    productos = {
        pan = 15, leche = 12, gasolina = 8.5, reparacion = 75
    }
}

-- Configuración de propiedades
Config.Propiedades = {
    impuestos = {
        tasaBase = 0.03,
        frecuencia = 7,
    },

    serviciosPublicos = {
        agua = { base = 85, consumoPorPersona = 15, variable = true },
        luz = { base = 120, consumoPorHora = 2, variable = true },
        gas = { base = 65, consumoPorDia = 8, variable = true },
        internet = { base = 45, variable = false }
    },

    tiposPropiedades = {
        apartamento = { 
            precioCompra = 75000, 
            alquilerBase = 450, 
            impuestos = 0.02,
            maxResidentes = 2
        },
        casa = { 
            precioCompra = 150000, 
            alquilerBase = 750, 
            impuestos = 0.03,
            maxResidentes = 4
        },
        mansion = { 
            precioCompra = 500000, 
            alquilerBase = 1500, 
            impuestos = 0.05,
            maxResidentes = 6
        }
    },

    mejoras = {
        seguridad = {
            { nombre = "Alarma Básica", precio = 5000, nivel = 1 },
            { nombre = "Sistema Seguridad", precio = 15000, nivel = 2 },
            { nombre = "Seguridad Avanzada", precio = 35000, nivel = 3 }
        },
        comodidad = {
            { nombre = "Decoración Básica", precio = 3000, nivel = 1 },
            { nombre = "Muebles Calidad", precio = 12000, nivel = 2 },
            { nombre = "Lujo Completo", precio = 45000, nivel = 3 }
        },
        eficiencia = {
            { nombre = "Aislamiento", precio = 8000, nivel = 1 },
            { nombre = "Paneles Solares", precio = 25000, nivel = 2 },
            { nombre = "Casa Autosuficiente", precio = 60000, nivel = 3 }
        }
    }
}

-- Marcadores de propiedades (ejemplos)
Config.MarcadoresPropiedades = {
    { x = -814.89, y = 183.28, z = 72.15, tipo = "apartamento", precio = 75000, id = "prop_001" },
    { x = -784.72, y = 459.61, z = 100.38, tipo = "casa", precio = 150000, id = "prop_002" },
    { x = -1286.04, y = 440.13, z = 97.58, tipo = "mansion", precio = 500000, id = "prop_003" }
}