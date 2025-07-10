---@param v EntityStorage
function tick_steam_silo(v)
    local silo = v.silo
    if not silo or not silo.valid then
        return
    end

    local recipe = silo.get_recipe()
    if not recipe then
        return
    end

    if recipe.name == 'solar_refractor' then
        if silo.name ~= 'solar_refractor_silo' then
            ---@type LuaEntity
            ---@diagnostic disable-next-line: assign-type-mismatch
            local new_silo = silo.surface.create_entity {
                name = "solar_refractor_silo",
                position = silo.position,
                force = silo.force,
                create_build_effect_smoke = false,
                auto_connect = false
            }
            new_silo.set_recipe('solar_refractor')
            v.silo.destroy()
            v.silo = new_silo
        end
        if silo.rocket then
            if silo.launch_rocket() then
                add_reflectors(silo.surface, 1)
            end
        end
    elseif recipe.name == 'steam_cargo' then
        if silo.name ~= 'steam_cargo_silo' then
            ---@type LuaEntity
            ---@diagnostic disable-next-line: assign-type-mismatch
            silo = silo.surface.create_entity {
                name = "steam_cargo_silo",
                position = silo.position,
                force = silo.force,
                create_build_effect_smoke = false,
                auto_connect = false
            }
            silo.set_recipe('steam_cargo')
            v.silo.destroy()
            v.silo = silo
        end
    end
end