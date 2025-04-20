local _name = "solar_refractor_silo"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/shungite.png", -- fixme
            icon_size = 500,
        },
        item = {
            stack_size = 1,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 100,
                ["concrete"] = 400,
                ["steel-plate"] = 400,
                ["iron-plate"] = 200,
                ["iron-gear-wheel"] = 100,
                ["engine-unit"] = 100,
            },
            energy_required = 10,
        },
        entity = {
            type = "rocket-silo",
            name = _name,
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            minable = { mining_time = 5, result = _name }, -- fixme automate
            max_health = 5000,
            collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
            selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            hole_clipping_box = { { -1, -1 }, { 1, 1 } },
            module_slots = 2,
            allowed_effects = { "consumption", "speed", "pollution" },
            heating_energy = "1MW",
            active_energy_usage = "0.5MW",
            lamp_energy_usage = "0W",
            energy_usage = "250kW",
            rocket_entity = "solar_refractor",
            crafting_categories = { "solar_refractors" },
            fixed_recipe = "solar_refractor",
            energy_source = {
                type = "fluid",
                fluid_box = {
                    production_type = "input",
                    filter = "steam",
                    volume = 500,
                    pipe_covers = pipecoverspictures(),
                    pipe_connections = {
                        { flow_direction = "input", direction = defines.direction.west, position = { -1, 0 } },
                        { flow_direction = "input", direction = defines.direction.east, position = { 1, 0 } },
                        { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
                        { flow_direction = "input", direction = defines.direction.south, position = { 0, 1 } }
                    }
                },
                fluid_usage_per_tick = 10,
            },
            door_back_open_offset = { 1.8, -1.8 * 0.43299225 },
            door_front_open_offset = { -1.8, 1.8 * 0.43299225 },
            silo_fade_out_start_distance = 8,
            silo_fade_out_end_distance = 15,
            times_to_blink = 1,
            light_blinking_speed = 1 / (3 * 60),
            door_opening_speed = 1 / (4.25 * 60),
            rocket_parts_required = 4,
            rocket_quick_relaunch_start_offset = -0.625,
            cargo_station_parameters = {
                hatch_definitions = {
                    {
                        hatch_graphics = nil,
                        offset = { 0, 0 },
                        pod_shadow_offset = { 0, 0 };
                        cargo_unit_entity_to_spawn = "",
                        receiving_cargo_units = {}
                    }
                },
            },

            graphics_set = {
                animation = {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                    width = 1024,
                    height = 1024,
                    frame_count = 1,
                    line_length = 1,
                    shift = { 0.0, 0.0 },
                    scale = 0.125
                }
            },
            impact_category = "metal-large",
            crafting_speed = 1,
            launch_to_space_platforms = false,
            can_launch_without_landing_pads = true
        },
    }
}