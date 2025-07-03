require("script.storage")

---@param burner LuaEntity
---@return LuaEntity | nil
function create_hidden_pole(burner)
    local force = burner.force
    local tech = force.technologies["advanced-character-distance"]
    local level = 1
    if tech and tech.enabled then
        level = level + tech.level
    end
    return burner.surface.create_entity {
        name = "solar-panel-hidden-pole-" .. level,
        position = burner.position,
        force = burner.force,
        create_build_effect_smoke = false,
        auto_connect = false
    }
end

---@param wrapper EntityStorage
function tick_panel_energy(wrapper)
    if wrapper.burner and wrapper.burner.valid then
        wrapper.burner.energy = 0
        local was_active = wrapper.panel ~= nil
        local now_active = wrapper.burner.burner.currently_burning ~= nil

        if was_active then
            if not now_active then
                wrapper.pole.destroy()
                wrapper.panel.destroy()
                wrapper.pole = nil
                wrapper.panel = nil
            end
        elseif now_active then
            local surface = wrapper.burner.surface
            local position = wrapper.burner.position

            wrapper.panel = surface.create_entity {
                name = "solar-panel-hidden-panel",
                position = position,
                force = wrapper.burner.force,
                create_build_effect_smoke = false
            }
            wrapper.pole = create_hidden_pole(wrapper.burner)
        end
    end
end

function recreate_hidden_poles()
    each_entity_storage(function (v)
        if v.burner and v.burner.valid and v.pole and v.pole.valid then
            v.pole.destroy()
            v.pole = create_hidden_pole(v.burner)
        end
    end)
end