require("common.storage")
require("script.ui")
require("script.reflectors")

require("common.events")(require("entities"))

script.on_event(defines.events.on_surface_deleted, function(event)
    surface_storage_destroy(event.surface_index)
end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]

    if surface.name == "heliara" then
        surface.daytime_parameters = daytime_parameters(0.2, 0.2)
        surface.solar_power_multiplier = 1
    end
end)

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    local cargo_pod = event.cargo_pod
    if cargo_pod.name == "cargo-pod-no-payload" then
        cargo_pod.destroy()
    end
end)

script.on_event(defines.events.on_forces_merging, function(event)
    force_storage_destroy(event.source)
end)
