require("common")

local _name = "long_burner_inserter"

return {
    {
        common = {
            name = _name,
            icons = {
                {
                    icon = "__base__/graphics/icons/long-handed-inserter.png",
                    tint = { 0.5, 0.3, 0.4 },
                },
            },
            order = "c[long-handed-inserter]-2",
        },
        item = {
            stack_size = 50,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
            subgroup = "inserter",
            color_hint = { text = "L" },
        },
        recipe = {
            ingredients = {
                ["fast_burner_inserter"] = 1,
                ["steel-plate"] = 1,
            },
            energy_required = 0.5,
            enabled = false,
        },
        entity = {
            type = "inserter",
            flags = {"placeable-neutral", "placeable-player", "player-creation"},
            minable = {mining_time = 0.1, result = _name},
            max_health = 160,
            resistances =
            {
                {
                    type = "fire",
                    percent = 90
                }
            },
            collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
            selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
            starting_distance = 1.7,
            pickup_position = {0, -2},
            insert_position = {0, 2.2},
            energy_per_movement = "20kJ",
            energy_per_rotation = "20kJ",
            extension_speed = 0.075,
            rotation_speed = 0.03,
            filter_count = 5,
            icon_draw_specification = {scale = 0.5},
            hand_size = 1.5,
            energy_source =
            {
                type = "burner",
                fuel_categories = {"chemical"},
                initial_fuel = "wood",
                initial_fuel_percent = 0.25,
                effectivity = 1,
                fuel_inventory_size = 1,
                light_flicker = {color = {0,0,0}},
                smoke =
                {
                    {
                        name = "smoke",
                        deviation = {0.1, 0.1},
                        frequency = 9
                    }
                }
            },
            fast_replaceable_group = "long-handed-inserter",
            impact_category = "metal",
            hand_base_picture =
            {
                filename = "__heliara__/graphics/entity/" .. _name .. "/long-handed-inserter-hand-base.png",
                priority = "extra-high",
                width = 32,
                height = 136,
                scale = 0.25
            },
            hand_closed_picture =
            {
                filename = "__heliara__/graphics/entity/" .. _name .. "/long-handed-inserter-hand-closed.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            hand_open_picture =
            {
                filename = "__heliara__/graphics/entity/" .. _name .. "/long-handed-inserter-hand-open.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            hand_base_shadow =
            {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
                priority = "extra-high",
                width = 32,
                height = 132,
                scale = 0.25
            },
            hand_closed_shadow =
            {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            hand_open_shadow =
            {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            platform_picture =
            {
                sheet =
                {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/long-handed-inserter-platform.png",
                    priority = "extra-high",
                    width = 105,
                    height = 79,
                    shift = util.by_pixel(1.5, 7.5-1),
                    scale = 0.5
                }
            }
        },
    }
}