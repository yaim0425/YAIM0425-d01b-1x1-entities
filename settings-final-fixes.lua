---------------------------------------------------------------------------
---[ settings-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar las funciones de GMOD ]---
---------------------------------------------------------------------------

require("__" .. "YAIM0425-i5MOD50-core" .. "__.settings-final-fixes")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Opciones ]---
---------------------------------------------------------------------------

--- Opciones
This_MOD.setting = {}

--- Opcion: armor_base
table.insert(This_MOD.setting, {
    type = "int",
    name = "time",
    localised_name = { "description.crafting-time" },
    localised_description = "Min. 1 [ 1seg ] \nMax. 65k [ 18h ] \nDef. 300 [5min]\n\n 5min * 60seg = 300seg",
    minimum_value = 1,     --- 1 segundo
    maximum_value = 65000, --- 18 horas
    default_value = 300    --- 5 minutos
})

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Completar las opciones ]---
---------------------------------------------------------------------------

--- Información adicional
for order, setting in pairs(This_MOD.setting) do
    setting.type = setting.type .. "-setting"
    setting.name = This_MOD.prefix .. setting.name
    setting.order = GMOD.pad_left_zeros(GMOD.digit_count(order), order)
    setting.setting_type = "startup"
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
--- Cargar la configuración ---
---------------------------------------------------------------------------

data:extend(This_MOD.setting)

---------------------------------------------------------------------------
