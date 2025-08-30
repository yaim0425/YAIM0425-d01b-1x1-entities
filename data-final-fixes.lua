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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidades a afectar
    This_MOD.get_entities()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la entidad deseada
    This_MOD.create_entity()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor
    This_MOD.entities = {}

    --- Tipos a afectar
    This_MOD.types = {
        ["furnace"] = This_MOD.is_furnace,
        ["mining-drill"] = function(entity) end,
        ["assembling-machine"] = function(entity) end,
        ["radar"] = function(entity) end,
        ["storage-tank"] = function(entity) end,
        ["beacon"] = This_MOD.is_beacon,
    }

    --- Corrección en la escala
    This_MOD.scales = {
        ["furnace"] = 0.25,
        ["mining-drill"] = 1,
        ["assembling-machine"] = 1,
        ["radar"] = 1,
        ["storage-tank"] = 1,
        ["beacon"] = 0.25,
    }

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function This_MOD.get_entities()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable a usar
    local Space

    --- Buscar las entidades a afectar
    for _, entity in pairs(GPrefix.entities) do
        if This_MOD.types[entity.type] then
            Space = {}
            Space.item = GPrefix.get_item_create_entity(entity)
            if Space.item then
                --- Valores para el proceso
                Space.entity = entity
                Space.recipe = GPrefix.recipes[Space.item.name] or {}
                Space.recipe = Space.recipe[1] or nil
                Space.tech = GPrefix.get_technology(Space.recipe)

                --- Guardar la información
                This_MOD.entities[entity.type] = This_MOD.entities[entity.type] or {}
                This_MOD.entities[entity.type][entity.name] = Space
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Crear la entidad deseada
function This_MOD.create_entity()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear la entidad deseada
    local function create_entity(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not space.entity then return end

        --- Duplicar la entidad
        local Entity = util.copy(space.entity)

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Calcular escala base según tamaño original
        local Collision_box = space.entity.collision_box
        local Width = Collision_box[2][1] - Collision_box[1][1]
        local Height = Collision_box[2][2] - Collision_box[1][2]
        This_MOD.new_scale = 1 / math.max(Width, Height)
        This_MOD.new_scale =
            This_MOD.new_scale -
            This_MOD.scales[Entity.type] * This_MOD.new_scale

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Verificar si la entidad es 1x1
        local Selection_box_str =
            Entity.selection_box[1][1] .. " x " .. Entity.selection_box[1][2]
            .. "   " ..
            Entity.selection_box[2][1] .. " x " .. Entity.selection_box[2][2]
        if Selection_box_str == This_MOD.selection_box_str then return end

        --- Modificar según el tipo
        Entity = This_MOD.types[Entity.type](Entity)

        --- Validación
        if not Entity then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar algunas propiedades
        Entity.name = This_MOD.prefix .. GPrefix.delete_prefix(Entity.name)
        Entity.next_upgrade = nil
        Entity.alert_icon_shift = nil
        Entity.collision_box = This_MOD.collision_box
        Entity.selection_box = This_MOD.selection_box

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Revisar todas las animaciones
        This_MOD.change_scale(Entity.animation)
        This_MOD.change_scale(Entity.base_picture)
        This_MOD.change_scale(Entity.idle_animation)
        This_MOD.change_scale(Entity.active_animation)

        --- Revisar todas las imagenes
        if Entity.graphics_set then
            This_MOD.change_scale(Entity.graphics_set.animation)
            This_MOD.change_scale(Entity.graphics_set.idle_animation)
            This_MOD.change_scale(Entity.graphics_set.active_animation)
            This_MOD.change_scale({ layers = Entity.graphics_set.animation_list })
            if Entity.graphics_set.working_visualisations then
                for _, vis in pairs(Entity.graphics_set.working_visualisations) do
                    This_MOD.change_scale(vis.animation)
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Escalar circuit connectors
        if Entity.circuit_connector then
            for _, connector in pairs(Entity.circuit_connector) do
                if connector.sprites then
                    for _, spr in pairs(connector.sprites) do
                        if spr.scale then spr.scale = spr.scale * This_MOD.new_scale end
                        if spr.shift then
                            spr.shift[1] = spr.shift[1] * This_MOD.new_scale
                            spr.shift[2] = spr.shift[2] * This_MOD.new_scale
                        end
                    end
                end
                if connector.points then
                    for _, side in pairs(connector.points) do
                        for _, pos in pairs(side) do
                            pos[1] = pos[1] * This_MOD.new_scale
                            pos[2] = pos[2] * This_MOD.new_scale
                        end
                    end
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor
        local Connections = {}

        --- Agrupar las conexiones a mover
        if Entity.fluid_boxes then
            table.insert(Connections, Entity.fluid_boxes)
        end

        if Entity.fluid_boxe then
            table.insert(Connections, Entity.fluid_boxe)
        end

        if Entity.energy_source.type == "fluid" then
            table.insert(Connections, Entity.energy_source.fluid_box)
        end

        if Entity.energy_source.type == "heat" then
            table.insert(Connections, { pipe_connections = Entity.energy_source.connections })
        end

        --- Mover las conexiones
        for _, conns in pairs(Connections) do
            if conns.pipe_connections then
                for _, conn in pairs(conns.pipe_connections or {}) do
                    if conn.position then
                        conn.position[1] = 0
                        conn.position[2] = 0
                    end
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Agregar los indicadores del mod
        table.insert(Entity.icons, This_MOD.indicator)

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el prototipo
        GPrefix.extend(Entity)

        --- Guardar el prototipo
        This_MOD.new_entity = This_MOD.new_entity or {}
        This_MOD.new_entity[Entity.type] = This_MOD.new_entity[Entity.type] or {}
        This_MOD.new_entity[Entity.type][Entity.name] = Entity

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer las entidades filtrada
    for _, spaces in pairs(This_MOD.entities) do
        for _, space in pairs(spaces) do
            create_entity(space)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cambia la scala de la entidad
function This_MOD.change_scale(images)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if not images then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Estructura a modificar
    if images.layers then
        for _, layer in pairs(images.layers) do
            layer.scale = (layer.scale or 1) * This_MOD.new_scale
            if layer.shift then
                layer.shift[1] = layer.shift[1] * This_MOD.new_scale
                layer.shift[2] = layer.shift[2] * This_MOD.new_scale
            end
        end
    else
        images.scale = (images.scale or 1) * This_MOD.new_scale
        if images.shift then
            images.shift[1] = images.shift[1] * This_MOD.new_scale
            images.shift[2] = images.shift[2] * This_MOD.new_scale
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Hornos
function This_MOD.is_furnace(entity)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if entity.fluid_boxes or entity.fluid_box then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver la entidad
    return entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.is_beacon(entity)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if entity.fluid_boxes or entity.fluid_box then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Enlistar las imagenes
    -- local Animation = {}

    -- if entity.graphics_set and entity.graphics_set.animation_list then
    --     Animation = entity.graphics_set.animation_list
    -- end

    -- if entity.animation then
    --     table.insert(Animation, { animation = entity.animation })
    -- end

    -- if entity.base_picture then
    --     table.insert(Animation, { animation = entity.base_picture })
    -- end

    -- --- Cambiar la escala de las imagenes
    -- for _, value in pairs(Animation) do
    --     This_MOD.change_scale(value.animation)
    -- end

    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Escalar module visualisations
    -- if entity.graphics_set and entity.graphics_set.module_visualisations then
    --     for _, vis in pairs(entity.graphics_set.module_visualisations) do
    --         for _, slot in pairs(vis.slots or {}) do
    --             for _, pic in pairs(slot) do
    --                 if pic.pictures then
    --                     pic.pictures.scale = (pic.pictures.scale or 1) * This_MOD.new_scale
    --                     if pic.pictures.shift then
    --                         pic.pictures.shift = {
    --                             (pic.pictures.shift[1] or 0) * This_MOD.new_scale,
    --                             (pic.pictures.shift[2] or 0) * This_MOD.new_scale
    --                         }
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Escalar reflejo en agua
    -- if entity.water_reflection and entity.water_reflection.pictures then
    --     entity.water_reflection.pictures.scale =
    --         (entity.water_reflection.pictures.scale or 1) * This_MOD.new_scale
    --     if entity.water_reflection.pictures.shift then
    --         entity.water_reflection.pictures.shift = {
    --             (entity.water_reflection.pictures.shift[1] or 0) * This_MOD.new_scale,
    --             (entity.water_reflection.pictures.shift[2] or 0) * This_MOD.new_scale
    --         }
    --     end
    -- end

    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver la entidad
    return entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------

-- GPrefix.var_dump(This_MOD.entities)
-- GPrefix.var_dump(This_MOD.new_entity)

-- GPrefix.var_dump(This_MOD)
-- ERROR()
