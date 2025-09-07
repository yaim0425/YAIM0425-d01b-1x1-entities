---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Contenedor de este archivo <---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Inicio del MOD <---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for iKey, spaces in pairs(This_MOD.to_be_prosecuted) do
        for jKey, space in pairs(spaces) do
            if
                not This_MOD.prosecuted[iKey] or
                (
                    This_MOD.prosecuted[iKey] and
                    not This_MOD.prosecuted[iKey][jKey]
                )
            then
                --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                --- Marcar como procesado
                This_MOD.prosecuted[iKey] = This_MOD.prosecuted[iKey] or {}
                This_MOD.prosecuted[iKey][jKey] = true

                --- Crear los elementos
                This_MOD.create_recipe(space)
                This_MOD.create_item(space)
                This_MOD.create_entity(space)

                --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Valores de la referencia <---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficó o modificará
    This_MOD.to_be_prosecuted = {}
    This_MOD.prosecuted = {}

    --- Tipos a afectar
    This_MOD.types = {
        ["accumulator"] = true,
        ["assembling-machine"] = true,
        ["beacon"] = true,
        ["boiler"] = true,
        ["furnace"] = true,
        -- ["fusion-generator"] = true, --- No tengo el DLC
        -- ["fusion-reactor"] = true, --- No tengo el DLC
        ["generator"] = true,
        ["mining-drill"] = true,
        ["radar"] = true,
        ["reactor"] = true,
        ["solar-panel"] = true,
        ["storage-tank"] = true,
    }

    --- Corrección en la escala
    This_MOD.scale = 0.25

    --- Cajas a 1x1
    This_MOD.collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } }
    This_MOD.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }

    This_MOD.selection_box_str =
        This_MOD.selection_box[1][1] .. " x " .. This_MOD.selection_box[1][2]
        .. "   " ..
        This_MOD.selection_box[2][1] .. " x " .. This_MOD.selection_box[2][2]

    --- Indicador del mod
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"
    This_MOD.indicator = {
        icon = This_MOD.graphics .. "indicator.png",
        scale = 0.25,
        icon_size = 192,
        tint = { r = 0, g = 1, b = 0 }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Funciones locales <---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar las entidades a afectar
    for _, entity in pairs(GMOD.entities) do
        if This_MOD.types[entity.type] then
            local Space = {}
            Space.item = GMOD.get_item_create_entity(entity)
            if Space.item then
                if
                    not This_MOD.prosecuted[entity] or
                    (
                        This_MOD.prosecuted[entity] and
                        not This_MOD.prosecuted[entity][Space.item.name]
                    )
                then
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    --- Valores para el proceso
                    Space.entity = entity
                    Space.recipe = GMOD.recipes[Space.item.name] or nil
                    Space.tech = GMOD.get_technology(Space.recipe)

                    --- Guardar la información
                    This_MOD.to_be_prosecuted[entity.type] = This_MOD.to_be_prosecuted[entity.type] or {}
                    This_MOD.to_be_prosecuted[entity.type][entity.name] = Space

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------
