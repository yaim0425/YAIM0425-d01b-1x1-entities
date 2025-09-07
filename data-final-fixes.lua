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
                    Space.recipe = GMOD.recipes[Space.item.name]
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
    --- Información importante
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a usar
    local Entity = GMOD.copy(space.entity)
    local Collision_box = space.entity.collision_box
    local Width = Collision_box[2][1] - Collision_box[1][1]
    local Height = Collision_box[2][2] - Collision_box[1][2]
    local Factor = { 1 / Width, 1 / Height }

    --- Calcular escala base según tamaño original
    This_MOD.new_scale = 1 / math.max(Width, Height)
    This_MOD.new_scale =
        This_MOD.new_scale -
        This_MOD.scale * This_MOD.new_scale

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Evitar las entidades 1x1
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Selection_box_str =
        Entity.selection_box[1][1] .. " x " .. Entity.selection_box[1][2]
        .. "   " ..
        Entity.selection_box[2][1] .. " x " .. Entity.selection_box[2][2]
    if Selection_box_str == This_MOD.selection_box_str then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Salida de la prodicción
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Mover el are afectada
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.name = This_MOD.prefix .. GMOD.delete_prefix(Entity.name)
    Entity.next_upgrade = nil
    Entity.alert_icon_shift = nil
    Entity.icons_positioning = nil
    Entity.icon_draw_specification = nil
    Entity.collision_box = This_MOD.collision_box
    Entity.selection_box = This_MOD.selection_box

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Escalar las imagenes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Elimnar lo inecesario
    if Entity.pictures then
        for _, value in pairs({ "fluid_background", "window_background", "flow_sprite", "gas_flow" }) do
            Entity.pictures[value] = nil
        end
    end

    --- Buscar en cada propiedad
    for _, Property in pairs({
        "overlay",
        "picture",
        "pictures",
        "animation",
        "heat_buffer",
        "base_picture",
        "graphics_set",
        "idle_animation",
        "active_animation",
        "water_reflection",
        "integration_patch",
        "chargable_graphics",
        "vertical_animation",
        "lower_layer_picture",
        "horizontal_animation",
        "working_light_picture",
        "wet_mining_graphics_set",
        "heat_lower_layer_picture",
        "connection_patches_connected",
        "connection_patches_disconnected",
        "heat_connection_patches_connected",
        "heat_connection_patches_disconnected"
    }) do
        local Value = Entity[Property]

        --- Escalar las imagenes
        for _, value in pairs(GMOD.get_tables(Value, "filename", nil, true) or {}) do
            value.scale = (value.scale or 1) * This_MOD.new_scale
            if value.shift then
                value.shift[1] = value.shift[1] * This_MOD.new_scale
                value.shift[2] = value.shift[2] * This_MOD.new_scale
            end
        end

        --- Ajustar los puntos
        local Points = Value and Value.working_visualisations
        local Waypoints = Value and Value.shift_animation_waypoints
        for _, dir in pairs((Waypoints or Points) and { "north", "east", "south", "west" } or {}) do
            for _, value in pairs((Waypoints and Waypoints[dir]) and Waypoints[dir] or {}) do
                value[1] = value[1] * Factor[1]
                value[2] = value[2] * Factor[2]
            end

            local Key = dir .. "_position"
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Conexiones de circuitos logicos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Escalar circuit connectors
    for _, value in pairs(GMOD.get_tables(Entity.circuit_connector, "filename", nil, true) or {}) do
        if value.scale then
            value.scale = value.scale * This_MOD.new_scale
        end
        if value.shift then
            value.shift[1] = value.shift[1] * This_MOD.new_scale
            value.shift[2] = value.shift[2] * This_MOD.new_scale
        end
    end

    --- Escalar los puntos
    for _, value in pairs(GMOD.get_tables(Entity.circuit_connector, "points", nil, true) or {}) do
        for _, point in pairs(value.points) do
            for _, pos in pairs(point) do
                pos[1] = pos[1] * This_MOD.new_scale
                pos[2] = pos[2] * This_MOD.new_scale
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Conexiones externa
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agrupar las conexiones a mover
    local Connections = GMOD.get_tables(Entity, "pipe_connections", nil, true) or {}

    if Entity.energy_source then
        if Entity.energy_source.type == "heat" then
            table.insert(Connections, { pipe_connections = Entity.energy_source.connections })
        end
    end

    if Entity.heat_buffer then
        table.insert(Connections, { pipe_connections = Entity.heat_buffer.connections })
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Icono del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar los indicadores del mod
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el prototipo
    GMOD.extend(Entity)

    --- Guardar el prototipo
    This_MOD.new_entity = This_MOD.new_entity or {}
    This_MOD.new_entity[Entity.type] = This_MOD.new_entity[Entity.type] or {}
    This_MOD.new_entity[Entity.type][Entity.name] = Entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------
