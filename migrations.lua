---------------------------------------------------------------------------------------------------
---[ migrations.lua ]---
---------------------------------------------------------------------------------------------------

--- Actualizar las recetas habilitadas
for _, force in pairs(game.forces) do
    for _, technology in pairs(force.technologies) do
        for _, effect in pairs(technology.prototype.effects) do
            if effect.type == "unlock-recipe" then
                force.recipes[effect.recipe].enabled = technology.researched
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
