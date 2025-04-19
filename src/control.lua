local INVISIBLE_POLE_NAME = "solar-generator-hidden-pole"

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity or event.entity
    if not entity.valid then return end

    if entity.name == "fullerene_solar_panel" then
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
    if entity.name == "fullerene_solar_panel" then
        storage.links[entity.unit_number].destroy()
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity.name == "fullerene_solar_panel" then
        storage.links[entity.unit_number].destroy()
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    if not surface or surface.name ~= "heliara" then return end

    local area = event.area
    local seed = (event.area.left_top.x + 10000) * 7919 + (event.area.left_top.y + 10000) * 1543
    local rng = game.create_random_generator(seed % 4294967296)

    -- chance of a puddle on the chunk
    if rng(1, 100) > 4 then return end  -- 4% chance

    -- random position in a chunk (within the area)
    local x = rng(area.left_top.x, area.left_top.x + 31)
    local y = rng(area.left_top.y, area.left_top.y + 31)

    -- puddle size (1–3 tiles)
    local size = rng(1, 3)

    local tiles = {}
    for dx = 0, size - 1 do
        for dy = 0, size - 1 do
            table.insert(tiles, { name = "water", position = { x + dx, y + dy } })
        end
    end

    surface.set_tiles(tiles, true)
end)
