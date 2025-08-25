---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Cambiar la propiedad necesaria
    This_MOD.change_property()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor
    This_MOD.entities = {}

    This_MOD.types = {
        "furnace",
        -- "mining-drill",
        "assembling-machine",
        "radar",
        "storage-tank",
        "beacon"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function This_MOD.get_entities()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Space = {}

    --- Buscar las entidades a afectar
    for key, entity in pairs(GPrefix.entities) do
        if GPrefix.get_key(This_MOD.types, key) then
            Space.item = GPrefix.get_item_create_entity(entity)
            if Space.item then
                Space.entity = entity
                Space.recipes = GPrefix.recipes[Space.item][1]
                Space.tech = GPrefix.get_technology(Space.recipes)
                This_MOD.entities[key] = Space
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cambiar la propiedad necesaria
function This_MOD.change_property()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
