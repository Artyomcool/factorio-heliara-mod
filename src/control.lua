local INVISIBLE_POLE_NAME = "solar-generator-hidden-pole"

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

        storage.links = storage.links or {}
        storage.links[entity.unit_number] = pole
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.name == "solar-burner" then
        storage.links[entity.unit_number].destroy()
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity.name == "solar-burner" then
        storage.links[entity.unit_number].destroy()
        storage.links[entity.unit_number] = null
    end
end)
