require("common")

local _name = "wireless_pole"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/default.png",    -- todo
        },
        item = {
            stack_size = 50,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["steel-plate"] = 4,
                ["iron-plate"] = 8,
                ["iron-gear-wheel"] = 2,
                ["fullerene"] = 4,
                ["graphite"] = 12,
            },
            energy_required = 4,
            enabled = false
        },
        entity = {
            type = "electric-pole",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
            maximum_wire_distance = 0.1,
            supply_area_distance = 1.4,
            minable = { mining_time = 0.2, result = _name },
            damaged_trigger_effect = hit_effects.entity({{-0.5, -2.5}, {0.5, 0.5}}),
            drawing_box_vertical_extension = 2,
            draw_copper_wires = false,
            light =
            {
                minimum_darkness = 0,
                intensity = 0.85,
                size = 5,
                color = {r=0.5, g=0.8, b=1.0},
                flicker_interval = 1,
                flicker_min_modifier = 0.1,
                flicker_max_modifier = 1.1,
                offset_flicker = true,
                shift = { 0, -1.2 }
            },
            impact_category = "metal",
            --open_sound = sounds.electric_network_open,
            --close_sound = sounds.electric_network_close,
            working_sound = {
                sound = {
                    filename = "__base__/sound/substation.ogg",
                    volume = 0.4,
                    audible_distance_modifier = 0.32,
                },
                max_sounds_per_prototype = 3,
                fade_in_ticks = 30,
                fade_out_ticks = 40,
                use_doppler_shift = false
            },
            radius_visualisation_picture =
            {
                filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
                width = 12,
                height = 12,
                priority = "extra-high-no-scale"
            },
            pictures =
            {
                layers =
                {
                    {
                        filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                        width = 256,
                        height = 256,
                        frame_count = 1,
                        line_length = 1,
                        shift = util.by_pixel(0, -14),
                        scale = 0.5,
                        direction_count = 1,
                    }
                }
            },
            connection_points = {
                {
                    shadow = { copper = { 0, 0 } },
                    wire = { copper = { 0, 0 } }
                }
            },
            bound_entities = {
                {
                    type = "electric-energy-interface",
                    name = "wireless_pole_hidden_drain",
                    flags = { "not-on-map", "placeable-off-grid" },
                    icon = "__heliara__/graphics/icons/default.png",    -- todo
                    selectable_in_game = false,
                    hidden = true,
                    energy_source = {
                        type = "electric",
                        buffer_capacity = "75kJ",
                        usage_priority = "primary-input",
                        input_flow_limit = "75kW",
                        output_flow_limit = "75kW",
                        drain = "75kW"
                    },
                    gui_mode = "none",

                    picture = {
                        filename = "__core__/graphics/empty.png",
                        width = 1,
                        height = 1,
                        direction_count = 1
                    },
                }
            }
        }
    },
    {
        common = {
            name = "effective_wireless_pole",
            icon = "__heliara__/graphics/icons/default.png",    -- todo
        },
        item = {
            stack_size = 50,
            random_tint_color = item_tints.iron_rust,
            place_result = "effective_wireless_pole",
        },
        recipe = {
            ingredients = {
                ["wireless_pole"] = 2,
                ["steel-plate"] = 2,
                ["iron-plate"] = 2,
                ["graphite_circuit"] = 8,
            },
            energy_required = 4,
            enabled = false
        },
        entity = {
            type = "electric-pole",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
            selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
            maximum_wire_distance = 0.1,
            supply_area_distance = 32,
            minable = { mining_time = 0.2, result = "effective_wireless_pole" },
            damaged_trigger_effect = hit_effects.entity({{-0.5, -2.5}, {0.5, 0.5}}),
            drawing_box_vertical_extension = 2,
            draw_copper_wires = false,
            light =
            {
                minimum_darkness = 0,
                intensity = 0.85,
                size = 5,
                color = {r=1.0, g=0.8, b=0.5},
                flicker_interval = 1,
                flicker_min_modifier = 0.1,
                flicker_max_modifier = 1.1,
                offset_flicker = true,
                shift = { 0, -1.2 }
            },
            impact_category = "metal",
            --open_sound = sounds.electric_network_open,
            --close_sound = sounds.electric_network_close,
            working_sound = {
                sound = {
                    filename = "__base__/sound/substation.ogg",
                    volume = 0.4,
                    audible_distance_modifier = 0.32,
                },
                max_sounds_per_prototype = 3,
                fade_in_ticks = 30,
                fade_out_ticks = 40,
                use_doppler_shift = false
            },
            radius_visualisation_picture =
            {
                filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
                width = 12,
                height = 12,
                priority = "extra-high-no-scale"
            },
            pictures =
            {
                layers =
                {
                    {
                        filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                        width = 256,
                        height = 256,
                        frame_count = 1,
                        line_length = 1,
                        shift = util.by_pixel(0, -14),
                        scale = 0.5,
                        direction_count = 1,
                        tint = {1, 0.5, 0.25},
                    }
                }
            },
            connection_points = {
                {
                    shadow = { copper = { 0, 0 } },
                    wire = { copper = { 0, 0 } }
                }
            },
            bound_entities = {
                {
                    type = "electric-energy-interface",
                    name = "wireless_pole_hidden_drain",
                    flags = { "not-on-map", "placeable-off-grid" },
                    icon = "__heliara__/graphics/icons/default.png",    -- todo
                    selectable_in_game = false,
                    hidden = true,
                    energy_source = {
                        type = "electric",
                        buffer_capacity = "150kJ",
                        usage_priority = "primary-input",
                        input_flow_limit = "150kW",
                        output_flow_limit = "150kW",
                        drain = "150kW"
                    },
                    gui_mode = "none",

                    picture = {
                        filename = "__core__/graphics/empty.png",
                        width = 1,
                        height = 1,
                        direction_count = 1
                    },
                }
            }
        }
    },
}