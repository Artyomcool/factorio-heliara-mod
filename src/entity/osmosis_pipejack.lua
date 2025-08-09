require("common")

local _name = "osmosis_pipejack"

return {
    {
        common = {
            name = _name,
            icon = "__base__/graphics/icons/offshore-pump.png",    -- fixme
            icon_size = 64,
            icon_draw_specification = { shift = { 0, -0.3 } },
        },
        item = {
            subgroup = "production-machine",
            color_hint = { text = "2" }, -- ??
            order = "d[assembling-machine-heliara]",
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["steel-plate"] = 5,
                ["iron-gear-wheel"] = 10,
                ["graphite_circuit"] = 10,
                ["pipe"] = 10,
            },
            energy_required = 1,
            enabled = false,
        },
        entity = {
            type = "mining-drill",
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.2, result = _name},
            resource_categories = {"osmosis-fluid"},
            max_health = 200,
            fluid_source_offset = {0, -1},
            collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
            selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
            damaged_trigger_effect = hit_effects.entity(),
            drawing_box_vertical_extension = 1,
            output_fluid_box = {
                volume = 80,
                pipe_covers = pipecoverspictures(),
                production_type = "output",
                pipe_connections = {
                    {
                        position = {0, 1},
                        direction = defines.direction.south,
                        flow_direction = "output"
                    }
                }
            },
            energy_usage = "10kW",
            mining_speed = 1,
            resource_searching_radius = 0.49,
            vector_to_place_result = {0, 0},
            radius_visualisation_picture = {
                filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
                width = 12,
                height = 12
            },
            monitor_visualization_tint = {78, 173, 255},

            graphics_set = {
                animation = {
                    north = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/osmosis_pump/base.png",
                                priority = "high",
                                width = 192,
                                height = 256,
                                shift = {0, -0.5},
                                scale = 0.5,
                                repeat_count = 32
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 90,
                                height = 162,
                                shift = util.by_pixel(-1, -15 + 32),
                                scale = 0.5,
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 150,
                                height = 134,
                                shift = util.by_pixel(13, -7 + 32),
                                draw_as_shadow = true,
                                scale = 0.5
                            }
                        }
                    },
                    east = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/osmosis_pump/base.png",
                                priority = "high",
                                width = 192,
                                height = 256,
                                shift = {0, -0.5},
                                scale = 0.5,
                                repeat_count = 32
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 124,
                                height = 102,
                                shift = util.by_pixel(15 - 32, -2),
                                scale = 0.5,
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 180,
                                height = 66,
                                shift = util.by_pixel(27 - 32, 8),
                                draw_as_shadow = true,
                                scale = 0.5
                            }
                        }
                    },
                    south = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/osmosis_pump/base.png",
                                priority = "high",
                                width = 192,
                                height = 256,
                                shift = {0, -0.5},
                                scale = 0.5,
                                repeat_count = 32
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 92,
                                height = 192,
                                shift = util.by_pixel(-1, 0 - 32),
                                scale = 0.5,
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 164,
                                height = 128,
                                shift = util.by_pixel(15, 23 - 32),
                                draw_as_shadow = true,
                                scale = 0.5
                            }
                        }
                    },
                    west = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/osmosis_pump/base.png",
                                priority = "high",
                                width = 192,
                                height = 256,
                                shift = {0, -0.5},
                                scale = 0.5,
                                repeat_count = 32
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 124,
                                height = 102,
                                shift = util.by_pixel(-15 + 32, -2),
                                scale = 0.5,
                            },
                            {
                                filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png",
                                priority = "high",
                                line_length = 8,
                                frame_count = 32,
                                animation_speed = 0.25,
                                width = 172,
                                height = 66,
                                shift = util.by_pixel(-3 + 32, 8),
                                draw_as_shadow = true,
                                scale = 0.5
                            }
                        }
                    }
                },
            },
            open_sound = {filename = "__base__/sound/open-close/pumpjack-open.ogg", volume = 0.5},
            close_sound = {filename = "__base__/sound/open-close/pumpjack-close.ogg", volume = 0.5},
            working_sound = {
                sound = {
                    filename = "__base__/sound/offshore-pump.ogg",
                    volume = 0.5,
                    modifiers = volume_multiplier("tips-and-tricks", 1.1),
                    audible_distance_modifier = 0.7,
                },
                match_volume_to_activity = true,
                max_sounds_per_prototype = 3,
                fade_in_ticks = 4,
                fade_out_ticks = 20
            },
            perceived_performance = {minimum = 0.5},
            always_draw_fluid = true,

            energy_source = {
                type = "burner",
                fuel_categories = {"osmosis"},
                effectivity = 1,
                fuel_inventory_size = 2,
                emissions_per_minute = { pollution = 35 },
                light_flicker =
                {
                    color = {0,0,0},
                    minimum_intensity = 0.6,
                    maximum_intensity = 0.95
                },
                smoke =
                {
                    {
                        name = "smoke",
                        north_position = util.by_pixel(-38, -47.5 + 32),
                        south_position = util.by_pixel(38.5, -32 + 32),
                        east_position = util.by_pixel(20 - 32, -70 + 32),
                        west_position = util.by_pixel(-19 + 32, -8.5),
                        frequency = 15,
                        starting_vertical_speed = 0.0,
                        starting_frame_deviation = 60
                    }
                }
            },
        }
    },
    {
        common = {
            name = "osmosis_filter",
            icon = "__heliara__/graphics/icons/osmosis_filter.png",
            icon_size = 64,
            icon_draw_specification = { shift = { 0, -0.3 } },
        },
        item = {
            order = "b[circuits]-d[graphite-circuit]",
            color_hint = { text = "T" },
            subgroup = "intermediate-product",

            stack_size = 40,
            ingredient_to_weight_coefficient = 0.28,
            fuel_value = "5MJ",
            fuel_category = "osmosis",
        },
        recipe = {
            ingredients = {
                ["calcite"] = 16,
                ["graphite"] = 8,
                ["carbon"] = 8,
                ["iron-ore"] = 1,
                ["iron-plate"] = 1,
            },
            fluid_ingredients = {
                ["water"] = 40,
            },
            energy_required = 1,
            enabled = false,
            category = "crafting-with-fluid",
        },
    },
    {
        common = {
            name = "brackish_vent",
            icon = "__heliara__/graphics/icons/default.png",    --fixme
        },
        resource = {
            flags = { "placeable-neutral" },
            collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            mining_time = 1,
            autoplace = {
                order = "c",
                probability_expression = 0,
            },
            category = "osmosis-fluid",
            subgroup = "mineable-fluids",
            resource_patch_search_radius = 16,
            infinite = true,
            highlight = true,
            minimum = 1000000,
            normal = 1000000,
            infinite_depletion_amount = 0,
            map_color = { 0.08, 0.05, 0.9 },
            --mining_visualisation_tint = { r = 0.1, g = 0.09, b = 0.9, a = 1.000 },
            minable = {
                mining_time = 1,
                results = {
                    {
                        type = "fluid",
                        name = "water",
                        amount_min = 200,
                        amount_max = 250,
                        probability = 0.9
                    }
                }
            },
            stage_counts = {0},
            stages = {
                layers = {
                    {
                        filename = "__heliara__/graphics/entity/brackish_vent/brackish_vent.png",
                        priority = "extra-high",
                        frame_count = 5,
                        width = 192,
                        height = 192,
                        scale = 0.5,
                    }
                }
            },
        },
        raw = {
            {
                type = "fuel-category",
                name = "osmosis"
            },
            {
                type = "resource-category",
                name = "osmosis-fluid"
            },
        },
    },
}
