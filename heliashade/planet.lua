local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

local planet_catalogue_aquilo = require("__space-age__.prototypes.planet.procession-catalogue-aquilo")
local planet_map_gen = require("planet-map-gen")

data:extend({
    {
        type = "planet",
        name = "heliashade",
        icon = "__heliashade__/graphics/icons/default.png",
        icon_size = 128,
        starmap_icon = "__heliashade__/graphics/icons/default.png",
        starmap_icon_size = 128,
        gravity_pull = 10,
        distance = 65,
        orientation = 0.24,
        magnitude = 1,
        label_orientation = 0.9,
        order = "heliashade",
        subgroup = "planets",
        map_gen_settings = planet_map_gen.heliashade(),
        pollutant_type = nil,
        solar_power_in_space = 1,
        platform_procession_set = {
            arrival = { "planet-to-platform-b" },
            departure = { "platform-to-planet-a" }
        },
        planet_procession_set = {
            arrival = { "platform-to-planet-b" },
            departure = { "planet-to-platform-a" }
        },
        procession_graphic_catalogue = planet_catalogue_aquilo,

        surface_properties = {
            ["day-night-cycle"] = 30 * minute,
            ["magnetic-field"] = 15,
            ["solar-power"] = 1,
            pressure = 3,
            gravity = 0.8,
        },
        asteroid_spawn_influence = 1,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus, 0.9),
        surface_render_parameters = {
            terrain_tint_effect = {
                noise_texture = {
                    filename = "__space-age__/graphics/terrain/vulcanus/tint-noise.png",
                    size = 4096
                },

                offset = { 0, 0, 0, 0.8 },
                intensity = { 0.1, 0.1, 0.1, 1.0 },
                scale_u = { 3, 1, 1, 1 },
                scale_v = { 1, 1, 1, 1 },

                global_intensity = 0.3,
                global_scale = 0.1,
                zoom_factor = 3,
                zoom_intensity = 0.6
            }
        },
        auto_save_on_first_trip = false,
    },
    {
        type = "space-connection",
        name = "heliara-heliashade",
        subgroup = "planet-connections",
        from = "heliara",
        to = "heliashade",
        order = "h9a",
        length = 56000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus)
    },
})
