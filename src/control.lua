require("script.ui")
require("script.reflectors")
require("script.fullerene_solar_panel")
require("script.pod_crash")
require("script.storage")
require("script.steam_silo")
require("script.dyson_launcher")

script.on_event({ defines.events.on_research_finished, defines.events.on_research_reversed }, function(event)
    if event.research == "fullerene_pole_length" then
        recreate_hidden_poles();
    end
end)

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    local surface = event.cargo_pod.surface
    if not surface or not surface.planet or surface.planet.name ~= 'heliara' then
        return
    end

    pod_crash(event.cargo_pod)
end)

script.on_event(defines.events.on_surface_deleted, function(event)
    surface_storage_destroy(event.surface_index)
end)

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]

  if surface.name == "heliara" then
    -- we want a precise control here
    surface.daytime_parameters = daytime_parameters(0.2, 0.2)
    surface.solar_power_multiplier = 1
  end
end)

script.on_event(defines.events.on_tick, function(event)
    each_entity_storage(function (v)
        tick_panel_energy(v)
        tick_steam_silo(v)
        tick_dyson_launcher(v)
    end)
end)

script.on_event(
    {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
        defines.events.on_space_platform_built_entity
    }, function(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then
        return
    end

    if entity.name == "fullerene_solar_panel" then
        entity_storage(entity).burner = entity
    elseif entity.name == "solar_refractor_silo" then
        entity_storage(entity).silo = entity
    elseif entity.name == "dyson_swarm_launcher" then
        entity_storage(entity).dyson_launcher = entity
    end
end)


script.on_event(
    {
        defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_entity_died,
        defines.events.script_raised_destroy,
        defines.events.on_space_platform_mined_entity
    }, function(event)
---@diagnostic disable-next-line: undefined-field
    entity_storage_destroy(event.entity)
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity and event.entity.name == 'fullerene_solar_panel' then
        make_reflectors_ui(game.players[event.player_index], event.entity.surface)
    elseif event.entity and event.entity.name == 'dyson_swarm_launcher' then
        make_dyson_swarm_ui(game.players[event.player_index])
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity and event.entity.name == 'fullerene_solar_panel' then
        destroy_reflectors_ui(game.players[event.player_index])
    elseif event.entity and event.entity.name == 'dyson_swarm_launcher' then
        destroy_dyson_swarm_ui(game.players[event.player_index])
    end
end)

script.on_event(defines.events.on_forces_merging, function (event)
    force_storage_destroy(event.source)
end)