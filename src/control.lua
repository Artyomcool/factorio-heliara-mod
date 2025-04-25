local function max(a, b)
    if a > b then
        return a
    else
        return b
    end
end

local function min(a, b)
    if a < b then
        return a
    else
        return b
    end
end

local function create_hidden_pole(burner)
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

script.on_event({ defines.events.on_research_finished, defines.events.on_research_reversed }, function(event)
    if event.research == "fullerene_pole_length" then
        for _, v in pairs(storage.links or {}) do
            local burner = v.burner
            if burner and burner.valid then
                if v.pole ~= nil then
                    v.pole.destroy()
                    v.pole = create_hidden_pole(burner)
                end
            end
        end
    end
end)

script.on_event(defines.events.on_tick, function(event)
    for _, v in pairs(storage.links or {}) do
        local burner = v.burner
        local silos = v.silos
        if v.burner and v.burner.valid then
            burner.energy = 0
            local was_active = v.panel ~= nil
            local now_active = burner.burner.currently_burning ~= nil

            if was_active then
                if not now_active then
                    v.pole.destroy()
                    v.panel.destroy()
                    v.pole = nil
                    v.panel = nil
                end
            elseif now_active then
                local surface = burner.surface
                local position = burner.position

                v.panel = surface.create_entity {
                    name = "solar-panel-hidden-panel",
                    position = burner.position,
                    force = burner.force,
                    create_build_effect_smoke = false
                }
                v.pole = create_hidden_pole(burner)
            end
        elseif silos and silos.valid then
            --fixme: reinsert modules
            if silos.get_recipe() ~= nil then
                if silos.get_recipe().name == 'solar_refractor'then
                    if silos.name ~= 'solar_refractor_silo' then
                        silos = silos.surface.create_entity {
                            name = "solar_refractor_silo",
                            position = silos.position,
                            force = silos.force,
                            create_build_effect_smoke = false,
                            auto_connect = false
                        }
                        silos.set_recipe('solar_refractor')
                        v.silos.destroy()
                        v.silos = silos
                        game.print('changed: -> solar_refractor_silo')
                    end
                    if silos.rocket then
                        if silos.launch_rocket() then
                            -- dusk -> evening = sunset process
                            -- evening -> morning = night
                            -- morning -> dawn = sunrise process (???)
                            -- dawn -> 1 = sunrise process (???)
                            -- 0 -> dusk = day
                            local step = 0.1
                            local min_distance = 0.000001
                            local surface = silos.surface
                            if surface.morning - surface.evening > min_distance * 1.5 then
                                surface.dawn = min(1, surface.dawn + step)
                                surface.morning = max(surface.evening + min_distance, surface.morning - step / 2)
                                surface.evening = min(surface.morning - min_distance, surface.morning + step / 2)
                                surface.dusk = surface.evening - (surface.dawn - surface.morning)
                            else
                                surface.dawn = min(1, surface.dawn + step)
                                surface.morning = min(surface.dawn - min_distance, surface.morning + step)
                                surface.evening = min(surface.morning - min_distance, surface.evening + step * 2)
                                surface.dusk = surface.evening - (surface.dawn - surface.morning)
                            end
                            surface.solar_power_multiplier = surface.solar_power_multiplier + 0.05
                        end
                    end
                elseif silos.get_recipe().name =='steam_cargo' then
                    if silos.name ~= 'steam_cargo_silo' then
                        silos = silos.surface.create_entity {
                            name = "steam_cargo_silo",
                            position = silos.position,
                            force = silos.force,
                            create_build_effect_smoke = false,
                            auto_connect = false
                        }
                        silos.set_recipe('steam_cargo')
                        v.silos.destroy()
                        v.silos = silos
                        game.print('changed: -> steam_cargo_silo')
                    end
                end
            end
        end
    end
end)

--fixme it works only when player builds panel
script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity or event.entity
    if not entity.valid then
        return
    end

    if entity.name == "fullerene_solar_panel" then
        storage.links = storage.links or {}
        storage.links[entity.unit_number] = { burner = entity }
    elseif entity.name == "solar_refractor_silo" then
        storage.links = storage.links or {}
        storage.links[entity.unit_number] = { silos = entity }
        entity.surface.solar_power_multiplier = entity.surface.solar_power_multiplier + 1
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.name == "fullerene_solar_panel" then
        local links = storage.links[entity.unit_number]
        if links.panel then
            links.panel.destroy()
        end
        if links.pole then
            links.pole.destroy()
        end
        storage.links[entity.unit_number] = nil
    end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity.name == "fullerene_solar_panel" then
        local links = storage.links[entity.unit_number]
        if links.panel then
            links.panel.destroy()
        end
        if links.pole then
            links.pole.destroy()
        end
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    if not surface or surface.name ~= "heliara" then
        return
    end

    local area = event.area
    local seed = (event.area.left_top.x + 10000) * 7919 + (event.area.left_top.y + 10000) * 1543
    local rng = game.create_random_generator(seed % 4294967296)

    -- chance of a puddle on the chunk
    if rng(1, 100) > 4 then
        return
    end  -- 4% chance

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
