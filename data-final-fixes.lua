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

    --- Recorrer las entidades filtrada
    for _, spaces in pairs(This_MOD.entities) do
        for _, space in pairs(spaces) do
            This_MOD.create_entity(space)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor
    This_MOD.entities = {}

    --- Tipos a afectar
    This_MOD.types = {
        ["radar"] = true,
        ["beacon"] = true,
        ["furnace"] = true,
        ["storage-tank"] = true,
        ["mining-drill"] = true,
        ["assembling-machine"] = true
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function This_MOD.get_entities()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar las entidades a afectar
    for _, entity in pairs(GPrefix.entities) do
        if This_MOD.types[entity.type] then
            local Space = {}
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
function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Información importante
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a usar
    local Entity = GPrefix.copy(space.entity)
    local Collision_box = space.entity.collision_box
    local Width = Collision_box[2][1] - Collision_box[1][1]
    local Height = Collision_box[2][2] - Collision_box[1][2]
    local Factor = { 1 / Width, 1 / Height }

    --- Calcular escala base según tamaño original
    This_MOD.new_scale = 1 / math.max(Width, Height)
    This_MOD.new_scale =
        This_MOD.new_scale -
        This_MOD.scale * This_MOD.new_scale

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Evitar las entidades 1x1
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Selection_box_str =
        Entity.selection_box[1][1] .. " x " .. Entity.selection_box[1][2]
        .. "   " ..
        Entity.selection_box[2][1] .. " x " .. Entity.selection_box[2][2]
    if Selection_box_str == This_MOD.selection_box_str then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Salida de la prodicción
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Entity.vector_to_place_result then
        local X = Entity.vector_to_place_result[1]
        local Y = Entity.vector_to_place_result[2]

        -- Determinar hacia dónde apunta según el vector
        if math.abs(X) > math.abs(Y) then
            -- Horizontal
            if X > 0 then
                Entity.vector_to_place_result = { 0.7, 0 }
            else
                Entity.vector_to_place_result = { -0.7, 0 }
            end
        else
            -- Vertical
            if Y > 0 then
                Entity.vector_to_place_result = { 0, 0.7 }
            else
                Entity.vector_to_place_result = { 0, -0.7 }
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Mover el are afectada
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Entity.radius_visualisation_specification then
        --- Valores a usar
        local spec = Entity.radius_visualisation_specification
        local dir = Entity.place_direction or defines.direction.north

        --- Mover el area
        if dir == defines.direction.north then
            spec.offset = { 0, -spec.distance }
        elseif dir == defines.direction.south then
            spec.offset = { 0, spec.distance }
        elseif dir == defines.direction.east then
            spec.offset = { spec.distance, 0 }
        elseif dir == defines.direction.west then
            spec.offset = { -spec.distance, 0 }
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.name = This_MOD.prefix .. GPrefix.delete_prefix(Entity.name)
    Entity.next_upgrade = nil
    Entity.alert_icon_shift = nil
    Entity.icons_positioning = nil
    Entity.icon_draw_specification = nil
    Entity.collision_box = This_MOD.collision_box
    Entity.selection_box = This_MOD.selection_box

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Escalar las imagenes
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Elimnar lo inecesario
    if Entity.pictures then
        for _, value in pairs({ "fluid_background", "window_background", "flow_sprite", "gas_flow" }) do
            Entity.pictures[value] = nil
        end
    end

    --- Tablas raiz
    local Properties = {
        "picture",
        "pictures",
        "animation",
        "base_picture",
        "graphics_set",
        "idle_animation",
        "active_animation",
        "water_reflection",
        "integration_patch",
        "wet_mining_graphics_set",
    }

    --- Escalar las imagenes
    for _, Property in pairs(Properties) do
        for _, value in pairs(GPrefix.get_tables(Entity[Property], "filename") or {}) do
            value.scale = (value.scale or 1) * This_MOD.new_scale
            if value.shift then
                value.shift[1] = value.shift[1] * This_MOD.new_scale
                value.shift[2] = value.shift[2] * This_MOD.new_scale
            end
        end
    end

    --- Corrección en los puntos
    for _, graphics_set in pairs({ Entity.graphics_set, Entity.wet_mining_graphics_set }) do
        for _, dir in pairs({ "north", "east", "south", "west" }) do
            local Points = graphics_set.shift_animation_waypoints
            for _, value in pairs(Points and Points[dir] or {}) do
                value[1] = value[1] * Factor[1]
                value[2] = value[2] * Factor[2]
            end

            local Key = dir .. "_position"
            Points = graphics_set.working_visualisations
            for _, value in pairs(Points or {}) do
                if value[Key] then
                    if value[Key][1] == 0 and value[Key][2] == 0 then
                        value[Key] = nil
                    else
                        value[Key] = {
                            value[Key][1] * Factor[1],
                            value[Key][2] * Factor[2]
                        }
                    end
                end
            end
        end
    end

    -- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Conexiones de circuitos
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



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Conexiones externa
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agrupar las conexiones a mover
    local Connections = GPrefix.get_tables(Entity, "pipe_connections") or {}

    if Entity.energy_source then
        if Entity.energy_source.type == "heat" then
            table.insert(Connections, { pipe_connections = Entity.energy_source.connections })
        end
    end

    --- Prioridad (Inversa → Derecha → Izquierda)
    local Priority = {
        [defines.direction.north] = {
            defines.direction.south,
            defines.direction.east,
            defines.direction.west
        },
        [defines.direction.south] = {
            defines.direction.north,
            defines.direction.west,
            defines.direction.east
        },
        [defines.direction.east] = {
            defines.direction.west,
            defines.direction.south,
            defines.direction.north
        },
        [defines.direction.west] = {
            defines.direction.east,
            defines.direction.north,
            defines.direction.south
        }
    }

    --- Variables a usar
    local Used = {} --- Direcciones ocupadas
    local Count = 1 --- Contador de conexiones válidas

    --- Ajustar conexiones
    for _, conns in pairs(Connections) do
        for _, conn in pairs(conns.pipe_connections or {}) do
            if Count > 4 then return end
            local Dir = conn.direction or defines.direction.north

            if not Used[Dir] then
                -- Usar la dirección original
                Used[Dir] = true
                conn.direction = Dir
                Count = Count + 1
            else
                -- Buscar alternativa
                for _, alt in ipairs(Priority[Dir]) do
                    if not Used[alt] then
                        Used[alt] = true
                        conn.direction = alt
                        Count = Count + 1
                        break
                    end
                end
            end

            -- siempre centrar en la tile
            conn.position = { 0, 0 }
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Icono del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar los indicadores del mod
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el prototipo
    GPrefix.extend(Entity)

    --- Guardar el prototipo
    This_MOD.new_entity = This_MOD.new_entity or {}
    This_MOD.new_entity[Entity.type] = This_MOD.new_entity[Entity.type] or {}
    This_MOD.new_entity[Entity.type][Entity.name] = Entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
