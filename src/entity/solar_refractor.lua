local _name = "solar_refractor"

require("util")

local rocket_shift = 48

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 1024,
        },
        recipe = {
            ingredients = {
                fullerene = 50,
                graphite_circuit = 2,
                ["iron-plate"] = 2
            },
            energy_required = 3,
            category = "steam_rockets",
            enabled = false
        },
        item = {
            order = "a-b-c",
            color_hint = { text = "T" },
            subgroup = "raw-material",

            stack_size = 4,
            weight = 2 * kg
        },
        entity = {
            type = "rocket-silo-rocket",
            flags = { "not-on-map" },
            hidden = true,
            collision_mask = { layers = {}, not_colliding_with_itself = true },
            collision_box = { { -2, -7 }, { 2, 4 } },
            selection_box = { { 0, 0 }, { 0, 0 } },
            dying_explosion = "massive-explosion",
            shadow_slave_entity = "rocket-silo-rocket-shadow",
            inventory_size = 0,
            rising_speed = 1 / (2 * 60),
            engine_starting_speed = 1 / (1 * 60),
            flying_speed = 1 / (2.5 * 60),
            flying_acceleration = -0.0001,
            icon_draw_specification = { render_layer = "air-entity-info-icon" },
            glow_light = {
                intensity = 1,
                size = 30,
                shift = { 0, 1.5 },
                color = { 1, 1, 1 }
            },
            cargo_pod_entity = "cargo-pod-no-payload",
            rocket_sprite = {
                filename = "__heliara__/graphics/entity/" .. _name .. "/rocket-static-pod.png",
                width = 308,
                height = 752,
                scale = 0.125
            },
            rocket_flame_left_rotation = 0.0611,
            rocket_flame_right_rotation = 0.952,
            rocket_initial_offset = { 0, 3 },
            rocket_rise_offset = { 0, -0.9 },
            rocket_launch_offset = { 0, -64 },
            cargo_attachment_offset = util.by_pixel(0, -63.4),
            rocket_render_layer_switch_distance = 9.5,
            full_render_layer_switch_distance = 11,
            effects_fade_in_start_distance = 4.5,
            effects_fade_in_end_distance = 7.5,
            shadow_fade_out_start_ratio = 0.25,
            shadow_fade_out_end_ratio = 0.75,
            rocket_visible_distance_from_center = 0.4,
            rocket_above_wires_slice_offset_from_center = -3,
            rocket_air_object_slice_offset_from_center = -6,

            flying_sound = {
                filename = "__base__/sound/silo-rocket.ogg",
                volume = 1.0,
                modifiers = volume_multiplier("main-menu", 0.6),
                audible_distance_modifier = 6,
                aggregation = { max_count = 3, remove = true, count_already_playing = true, priority = "oldest" }
            }
        },
    },
    {
        entity = {
            type = "cargo-pod",
            name = "cargo-pod-no-payload",
            icon = "__base__/graphics/icons/cargo-pod.png",
            flags = {"not-on-map"},
            order = "c[cargo-pod]2",
            collision_mask = {layers = {}},
            collision_box = {{0, 0},{0, 0}},
            selection_box = {{-0.5, -1}, {0.5, 0.5}},
            inventory_size = 0,
            icon_draw_specification = {render_layer = "air-entity-info-icon", scale = 1.0},
            spawned_container = "cargo-pod-container",
            shadow_slave_entity = "rocket-silo-rocket-shadow",
        },
    }
}