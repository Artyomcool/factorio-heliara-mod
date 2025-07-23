require("script.ui")
require("script.reflectors")
require("script.pod_crash")
require("script.storage")
require("script.steam_silo")
require("script.dyson_launcher")
require("script.event_handlers")

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

create_heliara_for_player = nil

-- remove on release
commands.add_command("re", nil, function(command)
    if game.surfaces["heliara"] then
        create_heliara_for_player = game.get_player(command.player_index)
        game.delete_surface("heliara")
    else
        game.planets["heliara"].create_surface()
        game.players[command.player_index].teleport({0,0}, "heliara")
    end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
    if create_heliara_for_player ~= nil then
        game.planets["heliara"].create_surface()
        create_heliara_for_player.teleport({0,0}, "heliara")
        create_heliara_for_player = nil
    end
end)

script.on_event(defines.events.on_tick, function(event)
    each_entity_storage(function (v)
        tick_steam_silo(v)
        tick_dyson_launcher(v)
    end)
    local t = next_tick
    if t then
        next_tick = nil
        for _, value in ipairs(t) do
            value()
        end
    end
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
    local f = entity_events.on_build[entity.name]
    if f then f() end
end)


script.on_event(
    {
        defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_entity_died,
        defines.events.script_raised_destroy,
        defines.events.on_space_platform_mined_entity
    }, function(event)
    local f = entity_events.on_destroy[event.entity.name]
    if f then f() end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity then
        local f = entity_events.on_gui_opened[event.entity.name]
        if f then f(game.players[event.player_index], event.entity) end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity then
        local f = entity_events.on_gui_destroy[event.entity.name]
        if f then f(game.players[event.player_index], event.entity) end
    end
end)

script.on_event(defines.events.on_forces_merging, function (event)
    force_storage_destroy(event.source)
end)