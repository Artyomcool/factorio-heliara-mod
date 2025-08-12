require("common")

local _name = "big_space_platform_hub"

local make_tile_area = function(area, name)
    local result = {}
    local left_top = area[1]
    local right_bottom = area[2]
    for x = left_top[1], right_bottom[1] do
        for y = left_top[2], right_bottom[2] do
            table.insert(result,
                    {
                        position = {x, y},
                        tile = name
                    })
        end
    end
    return result
end

return {
    {
        common = {
            name = _name,
            icon = "__space-age__/graphics/icons/space-platform-starter-pack.png",    -- fixme
            icon_size = 64,
        },
        entity = {
            type = "space-platform-hub",
            flags = {"player-creation", "not-deconstructable"},
            subgroup = "space-platform",
            order = "b[space-platform-hub-big]",
            collision_box = {{-7.7, -7.9}, {7.9, 7.9}},
            selection_box = {{-8, -8}, {8, 8}},
            max_health = 10000,
            weight = 400000,
            inventory_size = 250,
            dump_container = "crash-site-chest-1",
            circuit_wire_max_distance = default_circuit_wire_max_distance,
            circuit_connector = circuit_connector_definitions["space-platform-hub"],
            default_speed_signal = {type = "virtual", name = "signal-V"},
            default_damage_taken_signal = {type = "virtual", name = "signal-D"},
            platform_repair_speed_modifier = 0.5,
            open_sound = sounds.metal_large_open,
            close_sound = sounds.metal_large_close,
            surface_conditions =
            {
                {
                    property = "pressure",
                    min = 0,
                    max = 0
                }
            },
            graphics_set =
            {
                connections = require("__space-age__.graphics.entity.cargo-hubs.connections.platform-connections"),
                picture =
                {
                    {
                        render_layer = "lower-object-above-shadow",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-0-A",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-0-B",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-0-C",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-0-D",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    })
                        }
                    },
                    {
                        render_layer = "lower-object-overlay",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-1-A",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-1-B",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-1-C",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    })
                        }
                    },
                    {
                        render_layer = "object-under",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-2",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    })
                        }
                    },
                    {
                        render_layer = "object",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-3",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-shadow",
                                    {
                                        scale = 0.5,
                                        shift = {8, 0},
                                        draw_as_shadow = true
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-emission-A",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1},
                                        draw_as_glow = true,
                                        blend_mode = "additive"
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-emission-B",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1},
                                        draw_as_glow = true,
                                        blend_mode = "additive"
                                    }),
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-emission-C",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1},
                                        draw_as_glow = true,
                                        blend_mode = "additive"
                                    }),
                        }
                    },
                    {
                        render_layer = "cargo-hatch",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-lower-hatch-occluder",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    })
                        }
                    },
                    {
                        render_layer = "above-inserters",
                        layers =
                        {
                            util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-upper-hatch-occluder",
                                    {
                                        scale = 0.5,
                                        shift = {0, -1}
                                    })
                        }
                    }
                },
                animation = cockpit_animation()
            },
            cargo_station_parameters =
            {
                hatch_definitions =
                {
                    platform_upper_hatch({0.5, -3.5} , 2.25, 3, -0.5, procession_graphic_catalogue_types.hatch_emission_in_1),
                    platform_upper_hatch({2, -3.5}   , 2.25, 3, -0.5, procession_graphic_catalogue_types.hatch_emission_in_2),
                    platform_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.hatch_emission_in_3),
                    platform_lower_hatch({-1.75, 0}  , 2   , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_1),
                    platform_lower_hatch({-0.5, 0.5} , 1.5 , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_2),
                    platform_lower_hatch({-2, 1}     , 1   , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_3),
                },
                giga_hatch_definitions =
                {
                    platform_upper_giga_hatch({0,1,2}),
                    platform_lower_giga_hatch({3,4,5}),
                }
            },
            persistent_ambient_sounds =
            {
                base_ambience = { filename = "__space-age__/sound/wind/base-wind-space-platform.ogg", volume = 0.8 },
                wind = { filename = "__space-age__/sound/wind/wind-space-platform.ogg", volume = 0.8 },
                crossfade =
                {
                    order = { "wind", "base_ambience" },
                    curve_type = "cosine",
                    from = { control = 0.35, volume_percentage = 0.0 },
                    to = { control = 2, volume_percentage = 100.0 }
                }
            },
            surface_render_parameters =
            {
                shadow_opacity = 0.5,
                space_dust_background =
                {
                    animation_speed = 1,
                    noise_texture =
                    {
                        filename = "__space-age__/graphics/space/dustTrailSpeckDust.png",
                        size = 4096,
                        premul_alpha = false
                    },
                    asteroid_texture =
                    {
                        filename = "__space-age__/graphics/space/asteroidTexture.png",
                        size = 1024
                    },
                    asteroid_normal_texture =
                    {
                        filename = "__space-age__/graphics/space/asteroidNormalTexture.png",
                        size = 1024
                    },
                },
                space_dust_foreground =
                {
                    animation_speed = 1,
                    noise_texture =
                    {
                        filename = "__space-age__/graphics/space/dustTrailSpeckDust.png",
                        size = 4096,
                        premul_alpha = false
                    },
                    asteroid_texture =
                    {
                        filename = "__space-age__/graphics/space/asteroidTexture.png",
                        size = 1024
                    },
                    asteroid_normal_texture =
                    {
                        filename = "__space-age__/graphics/space/asteroidNormalTexture.png",
                        size = 1024
                    },
                },
            }
        },
        raw = {
            {
                type = "space-platform-starter-pack",
                name = _name,
                icon = "__space-age__/graphics/icons/space-platform-starter-pack.png",    -- fixme
                icon_size = 64,
                subgroup = "space-rocket",
                order = "b[space-platform-starter-pack-big]",
                inventory_move_sound = item_sounds.mechanical_large_inventory_move,
                pick_sound = item_sounds.mechanical_large_inventory_pickup,
                drop_sound = item_sounds.mechanical_large_inventory_move,
                stack_size = 1,
                weight = 1*tons,
                surface = "space-platform",
                trigger =
                {
                    {
                        type = "direct",
                        action_delivery =
                        {
                            type = "instant",
                            source_effects =
                            {
                                {
                                    type = "create-entity",
                                    entity_name = _name
                                }
                            }
                        }
                    }
                },
                tiles = make_tile_area({{-15, -15}, {14, 14}}, "space-platform-foundation"),
                initial_items = {{type = "item", name = "space-platform-foundation", amount = 100}},
                create_electric_network = true,
            }
        },
        recipe = {
            ingredients = {
                ["space-platform-foundation"] = 1000,
                ["tungsten-plate"] = 10,
                ["low-density-structure"] = 40,
                ["processing-unit"] = 20,
                ["graphite_circuit"] = 20,
                ["carbon-fiber"] = 20,
            },
            energy_required = 200,
            enabled = true,
        },
    },
}