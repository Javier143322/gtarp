
-- Funciones utilitarias compartidas
function FormatMoney(amount)
    return "$" .. tostring(math.floor(amount))
end

function GetPropertyTypeName(tipo)
    local nombres = {
        apartamento = "Apartamento",
        casa = "Casa",
        mansion = "Mansión"
    }
    return nombres[tipo] or tipo
end

function CalculateTax(amount, taxRate)
    return math.floor(amount * taxRate)
end