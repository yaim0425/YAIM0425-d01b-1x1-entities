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
        ["beacon"] = function(entity) end,
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

    --- Cambia la scala de la entidad
    local function change_scale(Table)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not Table then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Estructura a modificar
        if Table.layers then
            for _, layer in pairs(Table.layers) do
                layer.scale = (layer.scale or 1) * This_MOD.new_scale
                if layer.shift then
                    layer.shift[1] = layer.shift[1] * This_MOD.new_scale
                    layer.shift[2] = layer.shift[2] * This_MOD.new_scale
                end
            end
        else
            Table.scale = (Table.scale or 1) * This_MOD.new_scale
            if Table.shift then
                Table.shift[1] = Table.shift[1] * This_MOD.new_scale
                Table.shift[2] = Table.shift[2] * This_MOD.new_scale
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Crear la entidad deseada
    local function create_entity(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not space.entity then return end

        --- Duplicar la entidad
        local Entity = util.copy(space.entity)

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

        --- Calcular escala base según tamaño original
        local Collision_box = space.entity.collision_box
        local Width = Collision_box[2][1] - Collision_box[1][1]
        local Height = Collision_box[2][2] - Collision_box[1][2]
        This_MOD.new_scale = 1 / math.max(Width, Height)
        This_MOD.new_scale = This_MOD.new_scale - This_MOD.scale * This_MOD.new_scale

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Revisar todas las animaciones
        change_scale(Entity.animation)
        change_scale(Entity.idle_animation)
        change_scale(Entity.active_animation)

        --- Revisar todas las imagenes
        if Entity.graphics_set then
            change_scale(Entity.graphics_set.animation)
            change_scale(Entity.graphics_set.idle_animation)
            change_scale(Entity.graphics_set.active_animation)
            if Entity.graphics_set.working_visualisations then
                for _, vis in pairs(Entity.graphics_set.working_visualisations) do
                    change_scale(vis.animation)
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

        --- Mover las conexiones de liquidos y calor
        local Fluid_boxes = {}
        if Entity.fluid_boxes then
            table.insert(Fluid_boxes, Entity.fluid_boxes)
        end

        if Entity.fluid_boxe then
            table.insert(Fluid_boxes, Entity.fluid_boxe)
        end

        if Entity.energy_source.type == "fluid" then
            table.insert(Fluid_boxes, Entity.energy_source.fluid_box)
        end

        if Entity.energy_source.type == "heat" then
            if Entity.energy_source.connections then
                table.insert(Fluid_boxes, { pipe_connections = Entity.energy_source.connections })
            end
        end

        if #Fluid_boxes > 0 then
            for _, Box in pairs(Fluid_boxes) do
                if Box.pipe_connections then
                    for _, conn in pairs(Box.pipe_connections) do
                        if conn.position then
                            conn.position[1] = 0
                            conn.position[2] = 0
                        end
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

--- Hornos
function This_MOD.is_furnace(entity)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if entity.fluid_boxes or entity.fluid_box then return end

    --- Devolver la entidad
    return entity

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------

-- GPrefix.var_dump(This_MOD.new_entity)
-- GPrefix.var_dump(This_MOD)
-- ERROR()

if true then return end
local entities = {
    ['furnace'] = {
        ['stone-furnace'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'stone-furnace',
                ['subgroup'] = 'smelting-machine',
                ['order'] = '010',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/brick-inventory-move.ogg',
                    ['volume'] = 0.5,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/brick-inventory-pickup.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/brick-inventory-move.ogg',
                    ['volume'] = 0.5,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'stone-furnace',
                ['stack_size'] = 50,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/stone-furnace.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.stone-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.stone-furnace'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'furnace',
                ['name'] = 'stone-furnace'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'stone-furnace',
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'stone',
                        ['amount'] = 5
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'stone-furnace',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'smelting-machine',
                ['order'] = '010',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.stone-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.stone-furnace'
                    }
                }
            }
        },
        ['electric-furnace'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'electric-furnace',
                ['subgroup'] = 'smelting-machine',
                ['order'] = '030',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/electric-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/electric-large-inventory-pickup.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/electric-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'electric-furnace',
                ['stack_size'] = 50,
                ['weight'] = 20000,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/electric-furnace.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.electric-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.electric-furnace'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'furnace',
                ['name'] = 'electric-furnace'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'electric-furnace',
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 10
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'advanced-circuit',
                        ['amount'] = 5
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'stone-brick',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electric-furnace',
                        ['amount'] = 1
                    }
                },
                ['energy_required'] = 5,
                ['enabled'] = false,
                ['subgroup'] = 'smelting-machine',
                ['order'] = '030',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.electric-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.electric-furnace'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'advanced-material-processing-2',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'electric-furnace'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'advanced-material-processing',
                    [2] = 'chemical-science-pack'
                },
                ['unit'] = {
                    ['count'] = 250,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        },
                        [3] = {
                            [1] = 'chemical-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 30
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/advanced-material-processing-2.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.advanced-material-processing'
                    },
                    [3] = ' 2'
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.advanced-material-processing'
                    }
                }
            }
        },
        ['steel-furnace'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'steel-furnace',
                ['subgroup'] = 'smelting-machine',
                ['order'] = '020',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'steel-furnace',
                ['stack_size'] = 50,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/steel-furnace.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.steel-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.steel-furnace'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'furnace',
                ['name'] = 'steel-furnace'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'steel-furnace',
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 6
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'stone-brick',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-furnace',
                        ['amount'] = 1
                    }
                },
                ['energy_required'] = 3,
                ['enabled'] = false,
                ['subgroup'] = 'smelting-machine',
                ['order'] = '020',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.steel-furnace'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.steel-furnace'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'advanced-material-processing',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'steel-furnace'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'steel-processing',
                    [2] = 'logistic-science-pack'
                },
                ['unit'] = {
                    ['count'] = 75,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 30
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/advanced-material-processing.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.advanced-material-processing'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.advanced-material-processing'
                    }
                }
            }
        }
    },
    ['mining-drill'] = {
        ['burner-mining-drill'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'burner-mining-drill',
                ['subgroup'] = 'extraction-machine',
                ['order'] = '010',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-move.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-move.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'burner-mining-drill',
                ['stack_size'] = 50,
                ['random_tint_color'] = {
                    [1] = 1,
                    [2] = 0.95,
                    [3] = 0.9,
                    [4] = 1
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/burner-mining-drill.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.burner-mining-drill'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.burner-mining-drill'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'mining-drill',
                ['name'] = 'burner-mining-drill'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'burner-mining-drill',
                ['energy_required'] = 2,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 3
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'stone-furnace',
                        ['amount'] = 1
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-plate',
                        ['amount'] = 3
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'burner-mining-drill',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'extraction-machine',
                ['order'] = '010',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.burner-mining-drill'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.burner-mining-drill'
                    }
                }
            }
        },
        ['electric-mining-drill'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'electric-mining-drill',
                ['subgroup'] = 'extraction-machine',
                ['order'] = '020',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-move.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/drill-inventory-move.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'electric-mining-drill',
                ['stack_size'] = 50,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/electric-mining-drill.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.electric-mining-drill'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.electric-mining-drill'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'mining-drill',
                ['name'] = 'electric-mining-drill'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'electric-mining-drill',
                ['energy_required'] = 2,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 3
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 5
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-plate',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electric-mining-drill',
                        ['amount'] = 1
                    }
                },
                ['enabled'] = false,
                ['subgroup'] = 'extraction-machine',
                ['order'] = '020',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.electric-mining-drill'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.electric-mining-drill'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'electric-mining-drill',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'electric-mining-drill'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'automation-science-pack'
                },
                ['unit'] = {
                    ['count'] = 25,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 10
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/electric-mining-drill.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.electric-mining-drill'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.electric-mining-drill'
                    }
                }
            }
        },
        ['pumpjack'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'pumpjack',
                ['subgroup'] = 'extraction-machine',
                ['order'] = '040',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/pumpjack-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/pumpjack-inventory-pickup.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/pumpjack-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'pumpjack',
                ['stack_size'] = 20,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/pumpjack.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.pumpjack'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.pumpjack'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'mining-drill',
                ['name'] = 'pumpjack'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'pumpjack',
                ['energy_required'] = 5,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 5
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 10
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 5
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'pipe',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'pumpjack',
                        ['amount'] = 1
                    }
                },
                ['enabled'] = false,
                ['subgroup'] = 'extraction-machine',
                ['order'] = '040',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.pumpjack'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.pumpjack'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'oil-gathering',
                ['prerequisites'] = {
                    [1] = 'fluid-handling'
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'pumpjack'
                    }
                },
                ['unit'] = {
                    ['count'] = 100,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 30
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/oil-gathering.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.oil-gathering'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.oil-gathering'
                    }
                }
            }
        }
    },
    ['radar'] = {
        ['radar'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'radar',
                ['subgroup'] = 'defensive-structure',
                ['order'] = '030',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'radar',
                ['stack_size'] = 50,
                ['random_tint_color'] = {
                    [1] = 1,
                    [2] = 0.95,
                    [3] = 0.9,
                    [4] = 1
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/radar.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.radar'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.radar'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'radar',
                ['name'] = 'radar'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'radar',
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 5
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 5
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-plate',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'radar',
                        ['amount'] = 1
                    }
                },
                ['enabled'] = false,
                ['subgroup'] = 'defensive-structure',
                ['order'] = '030',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.radar'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.radar'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'radar',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'radar'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'automation-science-pack'
                },
                ['unit'] = {
                    ['count'] = 20,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 10
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/radar.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.radar'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.radar'
                    }
                }
            }
        }
    },
    ['assembling-machine'] = {
        ['assembling-machine-1'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'assembling-machine-1',
                ['subgroup'] = 'production-machine',
                ['color_hint'] = {
                    ['text'] = '1'
                },
                ['order'] = '010',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'assembling-machine-1',
                ['stack_size'] = 50,
                ['random_tint_color'] = {
                    [1] = 1,
                    [2] = 0.95,
                    [3] = 0.9,
                    [4] = 1
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/assembling-machine-1.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-1'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-1'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'assembling-machine-1'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'assembling-machine-1',
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 3
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 5
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-plate',
                        ['amount'] = 9
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'assembling-machine-1',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'production-machine',
                ['order'] = '010',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-1'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-1'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'automation',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'assembling-machine-1'
                    },
                    [2] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'long-handed-inserter'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'automation-science-pack'
                },
                ['unit'] = {
                    ['count'] = 10,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 10
                },
                ['ignore_tech_cost_multiplier'] = true,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/automation-1.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.automation'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.automation'
                    }
                }
            }
        },
        ['assembling-machine-2'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'assembling-machine-2',
                ['subgroup'] = 'production-machine',
                ['color_hint'] = {
                    ['text'] = '2'
                },
                ['order'] = '020',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'assembling-machine-2',
                ['stack_size'] = 50,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/assembling-machine-2.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-2'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-2'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'assembling-machine-2'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'assembling-machine-2',
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 2
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 3
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 5
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'assembling-machine-1',
                        ['amount'] = 1
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'assembling-machine-2',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'production-machine',
                ['order'] = '020',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-2'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-2'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'automation-2',
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.automation'
                    }
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'assembling-machine-2'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'automation',
                    [2] = 'steel-processing',
                    [3] = 'logistic-science-pack'
                },
                ['unit'] = {
                    ['count'] = 40,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 15
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/automation-2.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.automation'
                    },
                    [3] = ' 2'
                }
            }
        },
        ['assembling-machine-3'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'assembling-machine-3',
                ['subgroup'] = 'production-machine',
                ['order'] = '030',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'assembling-machine-3',
                ['stack_size'] = 50,
                ['weight'] = 40000,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/assembling-machine-3.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-3'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-3'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'assembling-machine-3'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'assembling-machine-3',
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'speed-module',
                        ['amount'] = 4
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'assembling-machine-2',
                        ['amount'] = 2
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'assembling-machine-3',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'production-machine',
                ['order'] = '030',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.assembling-machine-3'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.assembling-machine-3'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'automation-3',
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.automation'
                    }
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'assembling-machine-3'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'speed-module',
                    [2] = 'production-science-pack',
                    [3] = 'electric-engine'
                },
                ['unit'] = {
                    ['count'] = 150,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        },
                        [3] = {
                            [1] = 'chemical-science-pack',
                            [2] = 1
                        },
                        [4] = {
                            [1] = 'production-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 60
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/automation-3.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.automation'
                    },
                    [3] = ' 3'
                }
            }
        },
        ['oil-refinery'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'oil-refinery',
                ['subgroup'] = 'production-machine',
                ['order'] = '040',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-pickup.ogg',
                    ['volume'] = 0.5,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'oil-refinery',
                ['stack_size'] = 10,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/oil-refinery.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.oil-refinery'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.oil-refinery'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'oil-refinery'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'oil-refinery',
                ['energy_required'] = 8,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 15
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 10
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'stone-brick',
                        ['amount'] = 10
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 10
                    },
                    [5] = {
                        ['type'] = 'item',
                        ['name'] = 'pipe',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'oil-refinery',
                        ['amount'] = 1
                    }
                },
                ['enabled'] = false,
                ['subgroup'] = 'production-machine',
                ['order'] = '040',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.oil-refinery'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.oil-refinery'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'oil-processing',
                ['prerequisites'] = {
                    [1] = 'oil-gathering'
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'oil-refinery'
                    },
                    [2] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'chemical-plant'
                    },
                    [3] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'basic-oil-processing'
                    },
                    [4] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'solid-fuel-from-petroleum-gas'
                    }
                },
                ['research_trigger'] = {
                    ['type'] = 'mine-entity',
                    ['entity'] = 'crude-oil'
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/oil-processing.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.oil-processing'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.oil-processing'
                    }
                }
            }
        },
        ['chemical-plant'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'chemical-plant',
                ['subgroup'] = 'production-machine',
                ['order'] = '050',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-pickup.ogg',
                    ['volume'] = 0.5,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/fluid-inventory-move.ogg',
                    ['volume'] = 0.6,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'chemical-plant',
                ['stack_size'] = 10,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/chemical-plant.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.chemical-plant'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.chemical-plant'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'chemical-plant'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'chemical-plant',
                ['energy_required'] = 5,
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 5
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 5
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 5
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'pipe',
                        ['amount'] = 5
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'chemical-plant',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'production-machine',
                ['order'] = '050',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.chemical-plant'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.chemical-plant'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'oil-processing',
                ['prerequisites'] = {
                    [1] = 'oil-gathering'
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'oil-refinery'
                    },
                    [2] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'chemical-plant'
                    },
                    [3] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'basic-oil-processing'
                    },
                    [4] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'solid-fuel-from-petroleum-gas'
                    }
                },
                ['research_trigger'] = {
                    ['type'] = 'mine-entity',
                    ['entity'] = 'crude-oil'
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/oil-processing.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.oil-processing'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.oil-processing'
                    }
                }
            }
        },
        ['centrifuge'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'centrifuge',
                ['subgroup'] = 'production-machine',
                ['order'] = '060',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'centrifuge',
                ['stack_size'] = 50,
                ['random_tint_color'] = {
                    [1] = 1,
                    [2] = 0.95,
                    [3] = 0.9,
                    [4] = 1
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/centrifuge.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.centrifuge'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.centrifuge'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'assembling-machine',
                ['name'] = 'centrifuge'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'centrifuge',
                ['energy_required'] = 4,
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'concrete',
                        ['amount'] = 100
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 50
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'advanced-circuit',
                        ['amount'] = 100
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-gear-wheel',
                        ['amount'] = 100
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'centrifuge',
                        ['amount'] = 1
                    }
                },
                ['requester_paste_multiplier'] = 10,
                ['subgroup'] = 'production-machine',
                ['order'] = '060',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.centrifuge'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.centrifuge'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'uranium-processing',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'centrifuge'
                    },
                    [2] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'uranium-processing'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'uranium-mining'
                },
                ['research_trigger'] = {
                    ['type'] = 'mine-entity',
                    ['entity'] = 'uranium-ore'
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/uranium-processing.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.uranium-processing'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.uranium-processing'
                    }
                }
            }
        }
    },
    ['beacon'] = {
        ['beacon'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'beacon',
                ['subgroup'] = 'module',
                ['order'] = '0010',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/mechanical-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'beacon',
                ['stack_size'] = 20,
                ['random_tint_color'] = {
                    [1] = 1,
                    [2] = 0.95,
                    [3] = 0.9,
                    [4] = 1
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/beacon.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.beacon'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.beacon'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'beacon',
                ['name'] = 'beacon'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'beacon',
                ['enabled'] = false,
                ['energy_required'] = 15,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'electronic-circuit',
                        ['amount'] = 20
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'advanced-circuit',
                        ['amount'] = 20
                    },
                    [3] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 10
                    },
                    [4] = {
                        ['type'] = 'item',
                        ['name'] = 'copper-cable',
                        ['amount'] = 10
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'beacon',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'module',
                ['order'] = '0010',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.beacon'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.beacon'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'effect-transmission',
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'beacon'
                    }
                },
                ['prerequisites'] = {
                    [1] = 'processing-unit',
                    [2] = 'production-science-pack'
                },
                ['unit'] = {
                    ['count'] = 75,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        },
                        [3] = {
                            [1] = 'chemical-science-pack',
                            [2] = 1
                        },
                        [4] = {
                            [1] = 'production-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 30
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/effect-transmission.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.effect-transmission'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.effect-transmission'
                    }
                }
            }
        }
    },
    ['storage-tank'] = {
        ['storage-tank'] = {
            ['item'] = {
                ['type'] = 'item',
                ['name'] = 'storage-tank',
                ['subgroup'] = 'storage',
                ['order'] = '040',
                ['inventory_move_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['pick_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-pickup.ogg',
                    ['volume'] = 0.8,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['drop_sound'] = {
                    ['filename'] = '__base__/sound/item/metal-large-inventory-move.ogg',
                    ['volume'] = 0.7,
                    ['aggregation'] = {
                        ['max_count'] = 1,
                        ['remove'] = true
                    }
                },
                ['place_result'] = 'storage-tank',
                ['stack_size'] = 50,
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/icons/storage-tank.png'
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.storage-tank'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.storage-tank'
                    }
                }
            },
            ['entity'] = {
                ['type'] = 'storage-tank',
                ['name'] = 'storage-tank'
            },
            ['recipe'] = {
                ['type'] = 'recipe',
                ['name'] = 'storage-tank',
                ['energy_required'] = 3,
                ['enabled'] = false,
                ['ingredients'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'iron-plate',
                        ['amount'] = 20
                    },
                    [2] = {
                        ['type'] = 'item',
                        ['name'] = 'steel-plate',
                        ['amount'] = 5
                    }
                },
                ['results'] = {
                    [1] = {
                        ['type'] = 'item',
                        ['name'] = 'storage-tank',
                        ['amount'] = 1
                    }
                },
                ['subgroup'] = 'storage',
                ['order'] = '040',
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-name.storage-tank'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'entity-description.storage-tank'
                    }
                }
            },
            ['tech'] = {
                ['type'] = 'technology',
                ['name'] = 'fluid-handling',
                ['prerequisites'] = {
                    [1] = 'automation-2',
                    [2] = 'engine'
                },
                ['effects'] = {
                    [1] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'storage-tank'
                    },
                    [2] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'pump'
                    },
                    [3] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'barrel'
                    },
                    [4] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'water-barrel'
                    },
                    [5] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-water-barrel'
                    },
                    [6] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'sulfuric-acid-barrel'
                    },
                    [7] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-sulfuric-acid-barrel'
                    },
                    [8] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'crude-oil-barrel'
                    },
                    [9] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-crude-oil-barrel'
                    },
                    [10] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'heavy-oil-barrel'
                    },
                    [11] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-heavy-oil-barrel'
                    },
                    [12] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'light-oil-barrel'
                    },
                    [13] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-light-oil-barrel'
                    },
                    [14] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'petroleum-gas-barrel'
                    },
                    [15] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-petroleum-gas-barrel'
                    },
                    [16] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'lubricant-barrel'
                    },
                    [17] = {
                        ['type'] = 'unlock-recipe',
                        ['recipe'] = 'empty-lubricant-barrel'
                    }
                },
                ['unit'] = {
                    ['count'] = 50,
                    ['ingredients'] = {
                        [1] = {
                            [1] = 'automation-science-pack',
                            [2] = 1
                        },
                        [2] = {
                            [1] = 'logistic-science-pack',
                            [2] = 1
                        }
                    },
                    ['time'] = 15
                },
                ['icons'] = {
                    [1] = {
                        ['icon'] = '__base__/graphics/technology/fluid-handling.png',
                        ['icon_size'] = 256
                    }
                },
                ['localised_name'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-name.fluid-handling'
                    }
                },
                ['localised_description'] = {
                    [1] = '',
                    [2] = {
                        [1] = 'technology-description.fluid-handling'
                    }
                }
            }
        }
    }
}

GPrefix.var_dump(This_MOD)
ERROR()
