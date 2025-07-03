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

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    local cargo_pod = event.cargo_pod
    local force = cargo_pod.force

    if cargo_pod.name == "cargo-pod-no-payload" then
        cargo_pod.destroy()
        return
    end

    if cargo_pod.name == "cargo-dyson_swarm_element" then
        -- todo translation
        force.print('dyson!')

        cargo_pod.destroy()
        return
    end

    if cargo_pod.get_passenger() ~= nil then
        return
    end

    if force.technologies["heliara_navigation"].researched then
        return
    end

    local surface = cargo_pod.surface
    if not surface or not surface.planet or surface.planet.name ~= 'heliara' then
        return
    end

    local position = cargo_pod.position
    surface.create_entity({
        name = "collapsing-cargo-pod-container",
        position = position,
        force = cargo_pod.force,
        create_build_effect_smoke = true,
    })
    surface.create_entity {
        name = "big-explosion",
        position = position,
        force = game.forces.enemy
    }
    surface.create_entity {
        name = "fire-flame",
        position = position,
        force = game.forces.enemy
    }
    cargo_pod.destroy()
    -- todo translation
    force.print('Pod crashed because of navigation failure')
end)

---@param surface LuaSurface
local function surface_storage(surface)
    local index = surface.index

    if not storage.surfaces then
        storage.surfaces = {}
    end
    local result = storage.surfaces[index]
    if not result then
        result = {}
        storage.surfaces[index] = result
    end
    return result
end

script.on_event(defines.events.on_surface_deleted, function(event)
    if storage.surfaces then
        storage.surfaces[event.surface_index] = nil
    end
end)

local function daytime_parameters(day_duration, night_duration)
    local min_distance = 0.000001
    local dusk_dawn_duration = (1 - night_duration - day_duration) / 2
    
    -- 0 -> dusk = day
    -- dusk -> evening = sunset process
    -- evening -> morning = night
    -- morning -> dawn = sunrise process (???)
    -- dawn -> 1 = sunrise process (???)

    return {
        dusk = day_duration - min_distance * 3,
        evening = day_duration + dusk_dawn_duration - min_distance * 2,
        morning = day_duration + dusk_dawn_duration + night_duration - min_distance,
        dawn = 1,
    }
end

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]

  if surface.name == "heliara" then
    -- we want a precise control here
    surface.daytime_parameters = daytime_parameters(0.2, 0.2)
    surface.solar_power_multiplier = 1
  end
end)


local function interpolate(from, to, current)
    if current >= 1 then
        return to
    end
    
    return from + (to - from) * current
end

local function day_duration(reflectors_count)
    local count_to_make_it_always_day = 1000
    return interpolate(0.2, 1, reflectors_count / count_to_make_it_always_day)
end

local function night_duration(reflectors_count)
    local count_to_make_it_never_night = 500
    return interpolate(0.2, 0, reflectors_count / count_to_make_it_never_night)
end

---@param surface LuaSurface
---@param delta int32
local function add_reflectors(surface, delta)

    local surface_storage = surface_storage(surface)
    local prev_count = surface_storage.reflectors_count or 0
    local now_count = max(0, prev_count + delta)

    if now_count == prev_count then
        return
    end

    surface_storage.reflectors_count = now_count
    surface.solar_power_multiplier = 1 + math.pow(now_count, 0.5) * 0.05


    surface.daytime_parameters = daytime_parameters(day_duration(now_count), night_duration(now_count))
end

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
            if silos.get_recipe() ~= nil then
                if silos.get_recipe().name == 'dyson_swarm_element' then
                    if silos.rocket then
                        if silos.launch_rocket() then
                            for _, vv in pairs(silos.force.platforms or {}) do
                                local surface = vv.surface
                                surface.solar_power_multiplier = surface.solar_power_multiplier + 0.05
                                game.print('changed surface.solar_power_multiplier: -> ' .. surface.solar_power_multiplier)
                            end
                        end
                    end
                elseif silos.get_recipe().name == 'solar_refractor' then
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
                            add_reflectors(silos.surface, 1)
                        end
                    end
                elseif silos.get_recipe().name == 'steam_cargo' then
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
    elseif entity.name == "solar_refractor_silo" or entity.name == 'dyson_swarm_launcher' then
        storage.links = storage.links or {}
        storage.links[entity.unit_number] = { silos = entity }
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    local links = storage.links[entity.unit_number]
    if links then
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

---@param player LuaPlayer
---@param surface LuaSurface
local function create_ui(player, surface)
    add_reflectors(surface, 1)   -- fixme
    local existed = player.gui.relative['heliara_HALLLO']
    if existed then
        existed.destroy();  -- for debug ony
        -- return existed
    end

    local reflectors_count = surface_storage(surface).reflectors_count or 0

    local anchor = {gui=defines.relative_gui_type.entity_with_energy_source_gui, position=defines.relative_gui_position.right}
    local frame = player.gui.relative.add{type="frame", anchor=anchor, name='heliara_HALLLO', caption='[item=solar_refractor] Reflectors Info'}
    local flow = frame.add{type="flow", direction="vertical"}

    flow.add{type="label", caption='Count in atmosphere - ' .. reflectors_count}
    flow.add{type="label", caption='Electicity bonus - ' .. string.format("%.1f", (surface.solar_power_multiplier - 1) * 100) .. '%'}
    flow.add{type="label", caption='Day duration - ' .. string.format("%.1f", day_duration(reflectors_count) * 100) .. '%'}
    flow.add{type="label", caption='Night duration - ' .. string.format("%.1f", night_duration(reflectors_count) * 100) .. '%'}

    return frame
end

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity and event.entity.name == 'fullerene_solar_panel' then
        local g = create_ui(game.players[event.player_index], event.entity.surface)
        g.visible = true
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity and event.entity.name == 'fullerene_solar_panel' then
        local g = create_ui(game.players[event.player_index], event.entity.surface)
        g.visible = false
    end
end)
