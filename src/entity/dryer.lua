require("common")

local _name = "dryer"

return {
    {
        common = {
            name = _name,
            icon = "__base__/graphics/icons/boiler.png",    -- fixme
            icon_size = 64,
            icon_draw_specification = { shift = { 0, -0.3 } },
        },
        item = {
            subgroup = "production-machine",
            color_hint = { text = "2" }, -- ??
            order = "d[assembling-machine-heliara]",
            --inventory_move_sound = item_sounds.mechanical_inventory_move,
            --pick_sound = item_sounds.mechanical_inventory_pickup,
            --drop_sound = item_sounds.mechanical_inventory_move,
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["boiler"] = 1,
                ["iron-plate"] = 2,
            },
            energy_required = 1,
            enabled = false,
        },
        entity = {
            type = "furnace",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            selection_priority = 40,
            minable = { mining_time = 0.2, result = _name },
            max_health = 300,
            resistances = {
                {
                    type = "fire",
                    percent = 90
                },
                {
                    type = "explosion",
                    percent = 30
                },
                {
                    type = "impact",
                    percent = 30
                }
            },
            corpse = "boiler-remnants",
            dying_explosion = "boiler-explosion",
            impact_category = "metal-large",
            collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
            selection_box = {{-1.5, -1}, {1.5, 1}},
            damaged_trigger_effect = hit_effects.entity(),
            ingredient_count = 1,
            crafting_categories = { "dry" },
            crafting_speed = 1,

            fluid_boxes = {
                {
                    production_type = "output",
                    pipe_covers = pipecoverspictures(),
                    volume = 1500,
                    pipe_connections = {{flow_direction = "output", direction = defines.direction.north, position = {0, -0.5}}},
                    secondary_draw_orders = { north = -1 }
                },
            },
            fluid_boxes_off_when_no_fluid_recipe = false,

            graphics_set = {
                animation = {
                    north = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                                priority = "extra-high",
                                x = 512 - 269,
                                y = 512 - 221,
                                width = 269,
                                height = 221,
                                shift = util.by_pixel(-1.25, 5.25),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
                                priority = "extra-high",
                                width = 274,
                                height = 164,
                                scale = 0.5,
                                shift = util.by_pixel(20.5, 9),
                                draw_as_shadow = true
                            }
                        }
                    },
                    east = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                                priority = "extra-high",
                                x = 0,
                                y = 512 - 301,
                                width = 216,
                                height = 301,
                                shift = util.by_pixel(-3, 1.25),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
                                priority = "extra-high",
                                width = 184,
                                height = 194,
                                scale = 0.5,
                                shift = util.by_pixel(30, 9.5),
                                draw_as_shadow = true
                            }
                        }
                    },
                    south = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                                priority = "extra-high",
                                x = 0,
                                y = 0,
                                width = 260,
                                height = 192,
                                shift = util.by_pixel(4, 13),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
                                priority = "extra-high",
                                width = 311,
                                height = 131,
                                scale = 0.5,
                                shift = util.by_pixel(29.75, 15.75),
                                draw_as_shadow = true
                            }
                        },
                    },
                    west = {
                        layers = {
                            {
                                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                                priority = "extra-high",
                                x = 512 - 196,
                                y = 0,
                                width = 196,
                                height = 273,
                                shift = util.by_pixel(1.5, 7.75),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
                                priority = "extra-high",
                                width = 206,
                                height = 218,
                                scale = 0.5,
                                shift = util.by_pixel(19.5, 6.5),
                                draw_as_shadow = true
                            }
                        },
                    },
                },
                working_visualisations = {{
                    fadeout = true,
                    effect = "flicker",
                    north_animation = {
                        layers = {
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-N-fire.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                frame_count = 64,
                                line_length = 8,
                                width = 26,
                                height = 26,
                                animation_speed = 0.5,
                                shift = util.by_pixel(0, -8.5),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-N-light.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                repeat_count = 64,
                                width = 200,
                                height = 173,
                                shift = util.by_pixel(-1, -6.75),
                                blend_mode = "additive",
                                scale = 0.5
                            }
                        }
                    },
                    east_animation = {
                        layers = {
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-E-fire.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                frame_count = 64,
                                line_length = 8,
                                width = 28,
                                height = 28,
                                animation_speed = 0.5,
                                shift = util.by_pixel(-9.5, -22),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-E-light.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                repeat_count = 64,
                                width = 139,
                                height = 244,
                                shift = util.by_pixel(0.25, -13),
                                blend_mode = "additive",
                                scale = 0.5
                            },
                        }
                    },
                    south_animation = {
                        layers = {
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-S-fire.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                frame_count = 64,
                                line_length = 8,
                                width = 26,
                                height = 16,
                                animation_speed = 0.5,
                                shift = util.by_pixel(-1, -26.5),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-S-light.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                repeat_count = 64,
                                width = 200,
                                height = 162,
                                shift = util.by_pixel(1, 5.5),
                                blend_mode = "additive",
                                scale = 0.5
                            },
                        },
                    },
                    west_animation = {
                        layers = {
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-W-fire.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                frame_count = 64,
                                line_length = 8,
                                width = 30,
                                height = 29,
                                animation_speed = 0.5,
                                shift = util.by_pixel(13, -23.25),
                                scale = 0.5
                            },
                            {
                                filename = "__base__/graphics/entity/boiler/boiler-W-light.png",
                                draw_as_glow = true,
                                priority = "extra-high",
                                repeat_count = 64,
                                width = 136,
                                height = 217,
                                shift = util.by_pixel(2, -6.25),
                                blend_mode = "additive",
                                scale = 0.5
                            },
                        },
                    },
                }},
            },

            source_inventory_size = 1,
            result_inventory_size = 3,
            energy_source = {
                type = "burner",
                fuel_categories = {"chemical"},
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
                        north_position = util.by_pixel(-38, -47.5),
                        south_position = util.by_pixel(38.5, -32),
                        east_position = util.by_pixel(20, -70),
                        west_position = util.by_pixel(-19, -8.5),
                        frequency = 15,
                        starting_vertical_speed = 0.0,
                        starting_frame_deviation = 60
                    }
                }
            },
            energy_usage = "1MW",

            working_sound =
            {
                sound = {filename = "__base__/sound/boiler.ogg", volume = 0.7, audible_distance_modifier = 0.3},
                fade_in_ticks = 4,
                fade_out_ticks = 20
            },
        }
    },
    {
        recipe = {
            name = "water-from-concrete",
            hidden = true,
            ingredients = {
                ["silcrete"] = 50,
            },
            results = {
                ["stone"] = {10,20},
                ["stone-brick"] = {5,10},
                ["iron-ore"] = {1,2},
            },
            fluid_results = {
                water = 345
            },
            energy_required = 30,
            enabled = true,
            main_product = "water",
            category = "dry",
        },
        raw = {
            {
                type = "recipe-category",
                name = "dry"
            }
        }
    },
}