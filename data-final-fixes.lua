---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
table.insert(GMOD.MODs, This_MOD)

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, Spaces in pairs(This_MOD.to_be_processed) do
        for _, Space in pairs(Spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(Space)
            This_MOD.create_entity(Space)
            This_MOD.create_recipe(Space)
            This_MOD.create_tech(Space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Recorrer los MODs activados
    if GMOD.MODs[#GMOD.MODs] == This_MOD then
        for _, That_MOD in pairs(GMOD.MODs) do
            if That_MOD ~= This_MOD then
                That_MOD.start()
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar las opciones en setting-final-fixes.lua
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Indicador del mod
    This_MOD.graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"

    This_MOD.indicator = {
        icon = This_MOD.graphics .. "indicator.png",
        scale = 0.25,
        icon_size = 192,
        tint = { r = 0, g = 1, b = 0 }
    }

    This_MOD.indicator_tech = GMOD.copy(This_MOD.indicator)
    This_MOD.indicator_tech.scale = 1

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Tipos a afectar
    This_MOD.types = {
        ["accumulator"] = true,
        ["ammo-turret"] = true,
        ["assembling-machine"] = true,
        ["beacon"] = true,
        ["boiler"] = true,
        ["electric-turret"] = true,
        ["furnace"] = true,
        ["generator"] = true,
        ["mining-drill"] = true,
        ["radar"] = true,
        ["reactor"] = true,
        ["solar-panel"] = true,
        ["storage-tank"] = true
    }

    --- Corrección en la escala
    This_MOD.scale = 0.25

    --- Cajas a 1x1
    This_MOD.collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } }
    This_MOD.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }

    --- Caja de selection_box en string para evitar las entidades 1x1
    This_MOD.selection_box_str =
        This_MOD.selection_box[1][1] .. " x " .. This_MOD.selection_box[1][2]
        .. "   " ..
        This_MOD.selection_box[2][1] .. " x " .. This_MOD.selection_box[2][2]

    --- Prioridad (Inversa → Derecha → Izquierda)
    This_MOD.priority = {
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

    --- Rutas donde buscar las imagenes
    This_MOD.image_path = {
        "active_animation",
        "animation",
        "base_picture",
        "chargable_graphics",
        "connection_patches_connected",
        "connection_patches_disconnected",
        "folded_animation",
        "folding_animation",
        "graphics_set",
        "heat_buffer",
        "heat_connection_patches_connected",
        "heat_connection_patches_disconnected",
        "heat_lower_layer_picture",
        "horizontal_animation",
        "idle_animation",
        "integration_patch",
        "lower_layer_picture",
        "overlay",
        "picture",
        "pictures",
        "vertical_animation",
        "water_reflection",
        "wet_mining_graphics_set",
        "working_light_picture"
    }

    --- Propiedades de Entity.pictures a eliminar
    This_MOD.delete_pictures = {
        "fluid_background",
        "window_background",
        "flow_sprite",
        "gas_flow"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end

        --- Validar el tipo
        if not This_MOD.types[entity.type] then return end

        --- Evitar las entidades 1x1
        local Selection_box_str =
            entity.selection_box[1][1] .. " x " .. entity.selection_box[1][2]
            .. "   " ..
            entity.selection_box[2][1] .. " x " .. entity.selection_box[2][2]
        if Selection_box_str == This_MOD.selection_box_str then return end

        --- Validar si ya fue procesado
        local That_MOD =
            GMOD.get_id_and_name(entity.name) or
            { ids = "-", name = entity.name }

        local Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            That_MOD.name

        if GMOD.entities[Name] ~= nil then return end
        if GMOD.has_id(entity.name, This_MOD.id) then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Conexiones externas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Agrupar las conexiones
        local Connections = GMOD.get_tables(entity, "pipe_connections", nil) or {}

        --- Agregar las conexiones de calor
        if entity.energy_source then
            if entity.energy_source.type == "heat" then
                table.insert(Connections, { pipe_connections = entity.energy_source.connections })
            end
        end

        --- Agregar las conexiones de buffer de calor
        if entity.heat_buffer then
            table.insert(Connections, { pipe_connections = entity.heat_buffer.connections })
        end

        --- Validación de las conexiones (4 máximo)
        local Count = 0
        for _, t in pairs(Connections) do
            for _, _ in pairs(t.pipe_connections or {}) do
                if Count == 4 then return end
                Count = Count + 1
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity
        Space.name = Name

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.tech = GMOD.get_technology(Space.recipe)
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Preparar los datos a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for item_name, entity in pairs(GMOD.entities) do
        validate_entity(GMOD.items[item_name], entity)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end
    if GMOD.items[space.name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = space.name

    --- Apodo y descripción
    Item.localised_name = GMOD.copy(space.entity.localised_name)
    Item.localised_description = GMOD.copy(space.entity.localised_description)

    --- Entidad a crear
    Item.place_result = Item.name

    --- Agregar indicador del MOD
    table.insert(Item.icons, This_MOD.indicator)

    --- Actualizar Order
    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end
    if GMOD.entities[space.name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Información importante
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a usar
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
    --- Salida de la producción
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
    --- Mover el area afectada
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

    --- Nombre
    Entity.name = space.name

    --- Elimnar propiedades inecesarias
    Entity.alert_icon_shift = nil
    Entity.icons_positioning = nil
    Entity.icon_draw_specification = nil

    --- Cajas de colisión y selección
    Entity.collision_box = This_MOD.collision_box
    Entity.selection_box = This_MOD.selection_box

    --- Cambiar icono
    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator)

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = Entity.name,
        amount = 1
    } }

    --- Siguiente tier
    Entity.next_upgrade = (function(name)
        --- Validación
        if not name then return end

        --- Procesar el nombre
        local That_MOD =
            GMOD.get_id_and_name(name) or
            { ids = "-", name = name }

        --- Nombre despues de aplicar el MOD
        local New_name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            That_MOD.name

        --- La entidad ya existe
        if GMOD.entities[New_name] ~= nil then
            return New_name
        end

        --- La entidad existirá
        for _, Spaces in pairs(This_MOD.to_be_processed) do
            for _, Space in pairs(Spaces) do
                if Space.entity.name == name then
                    return New_name
                end
            end
        end
    end)(Entity.next_upgrade)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Escalar las imagenes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Elimnar lo inecesario
    if Entity.pictures then
        for _, value in pairs(This_MOD.delete_pictures) do
            Entity.pictures[value] = nil
        end
    end

    --- Buscar en cada propiedad
    for _, Property in pairs(This_MOD.image_path) do
        local Value = Entity[Property]

        --- Escalar las imagenes
        for _, value in pairs(GMOD.get_tables(Value, "filename", nil) or {}) do
            value.scale = (value.scale or 1) * This_MOD.new_scale
            if value.shift then
                value.shift[1] = value.shift[1] * This_MOD.new_scale
                value.shift[2] = value.shift[2] * This_MOD.new_scale
            end
        end

        --- Ajustar los puntos
        local Points = Value and Value.working_visualisations
        local Waypoints = Value and Value.shift_animation_waypoints
        for dir, _ in pairs((Waypoints or Points) and util.direction_vectors or {}) do
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
    for _, value in pairs(GMOD.get_tables(Entity.circuit_connector, "filename", nil) or {}) do
        if value.scale then
            value.scale = value.scale * This_MOD.new_scale
        end
        if value.shift then
            value.shift[1] = value.shift[1] * This_MOD.new_scale
            value.shift[2] = value.shift[2] * This_MOD.new_scale
        end
    end

    --- Escalar los puntos
    for _, value in pairs(GMOD.get_tables(Entity.circuit_connector, "points", nil) or {}) do
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
    local Connections = GMOD.get_tables(Entity, "pipe_connections", nil) or {}

    if Entity.energy_source then
        if Entity.energy_source.type == "heat" then
            table.insert(Connections, { pipe_connections = Entity.energy_source.connections })
        end
    end

    if Entity.heat_buffer then
        table.insert(Connections, { pipe_connections = Entity.heat_buffer.connections })
    end

    --- Direcciones ocupadas
    local Used = {}

    --- Ajustar conexiones
    for _, conns in pairs(Connections) do
        for _, conn in pairs(conns.pipe_connections or {}) do
            local Dir = conn.direction or defines.direction.north

            if not Used[Dir] then
                -- Usar la dirección original
                Used[Dir] = true
                conn.direction = Dir
            else
                -- Buscar alternativa
                for _, alt in ipairs(This_MOD.priority[Dir]) do
                    if not Used[alt] then
                        Used[alt] = true
                        conn.direction = alt
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
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end
    if data.raw.recipe[space.name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = space.name

    --- Apodo y descripción
    Recipe.localised_name = GMOD.copy(space.entity.localised_name)
    Recipe.localised_description = GMOD.copy(space.entity.localised_description)

    --- Tiempo de fabricación
    Recipe.energy_required = 3 * (Recipe.energy_required or 0.5)

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Productividad
    Recipe.allow_productivity = true
    Recipe.maximum_productivity = 1000000

    --- Cambiar icono
    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator)

    --- Habilitar la receta
    Recipe.enabled = space.tech == nil

    --- Actualizar Order
    local Order = tonumber(Recipe.order) + 1
    Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

    --- Ingredientes
    Recipe.ingredients = { {
        type = "item",
        name = space.item.name,
        amount = 1
    } }

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = Recipe.name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end
    if data.raw.technology[space.name .. "-tech"] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = GMOD.copy(space.tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Tech.name = space.name .. "-tech"

    --- Apodo y descripción
    Tech.localised_name = GMOD.copy(space.entity.localised_name)
    Tech.localised_description = GMOD.copy(space.entity.localised_description)

    --- Cambiar icono
    Tech.icons = GMOD.copy(space.item.icons)
    table.insert(Tech.icons, This_MOD.indicator_tech)

    --- Tech previas
    Tech.prerequisites = { space.tech.name }

    --- Efecto de la tech
    Tech.effects = { {
        type = "unlock-recipe",
        recipe = space.name
    } }

    --- Tech se activa con una fabricación
    if Tech.research_trigger then
        Tech.research_trigger = {
            type = "craft-item",
            item = space.item.name,
            count = 1
        }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
