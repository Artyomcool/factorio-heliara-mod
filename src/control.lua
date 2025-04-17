local INVISIBLE_POLE_NAME = "solar-generator-hidden-pole"

local solars_to_poles = {}

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity or event.entity
    if not entity.valid then return end

    if entity.name == "solar-burner" then
        local surface = entity.surface
        local position = entity.position

        -- создаём невидимый столб в том же месте
        local pole = surface.create_entity{
            name = INVISIBLE_POLE_NAME,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false
        }

        -- связываем для удаления
        solars_to_poles[entity.unit_number] = pole
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.name == "solar-burner" then
        solars_to_poles[entity.unit_number].destroy()
        solars_to_poles[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity.name == "solar-burner" then
        solars_to_poles[entity.unit_number].destroy()
        solars_to_poles[entity.unit_number] = null
    end
end)
