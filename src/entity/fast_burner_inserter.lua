require("common")

local _name = "fast_burner_inserter"

return {
    {
        common = {
            name = _name,
            icons = {
                {
                    icon = "__base__/graphics/icons/inserter.png",
                    tint = { 0.6, 0.4, 0.4 },
                },
            },
            order = "a[burner-inserter]-2",
        },
        item = {
            stack_size = 50,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
            subgroup = "inserter",
            color_hint = { text = "B" },
        },
        recipe = {
            ingredients = {
                ["burner-inserter"] = 1,
                ["graphite_circuit"] = 1,
            },
            energy_required = 0.5,
            enabled = false,
        },
        entity = {
            type = "inserter",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            minable = { mining_time = 0.1, result = "fast_burner_inserter" },
            max_health = 100,
            -- todo corpse = "burner-inserter-remnants",
            -- todo dying_explosion = "burner-inserter-explosion",
            resistances = {
                {
                    type = "fire",
                    percent = 90
                }
            },
            collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } },
            selection_box = { { -0.4, -0.35 }, { 0.4, 0.45 } },
            energy_per_movement = "15kJ",
            energy_per_rotation = "15kJ",
            energy_source = {
                type = "burner",
                fuel_categories = { "chemical" },
                initial_fuel = "wood",
                initial_fuel_percent = 0.25,
                effectivity = 1,
                fuel_inventory_size = 1,
                light_flicker = { color = { 0, 0, 0 } },
                smoke = {
                    {
                        name = "smoke",
                        deviation = { 0.1, 0.1 },
                        frequency = 9
                    }
                }
            },
            extension_speed = 0.1,
            rotation_speed = 0.04,
            filter_count = 5,
            icon_draw_specification = { scale = 0.5 },
            fast_replaceable_group = "inserter",
            impact_category = "metal",
            hand_base_picture = {
                filename = "__base__/graphics/entity/inserter/inserter-hand-base.png",
                priority = "extra-high",
                width = 32,
                height = 136,
                scale = 0.25,
                tint = { 0.6, 0.4, 0.4 },
            },
            hand_closed_picture = {
                filename = "__base__/graphics/entity/inserter/inserter-hand-closed.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25,
                tint = { 0.6, 0.4, 0.4 },
            },
            hand_open_picture = {
                filename = "__base__/graphics/entity/inserter/inserter-hand-open.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25,
                tint = { 0.6, 0.4, 0.4 },
            },
            hand_base_shadow = {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
                priority = "extra-high",
                width = 32,
                height = 132,
                scale = 0.25
            },
            hand_closed_shadow = {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            hand_open_shadow = {
                filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
                priority = "extra-high",
                width = 72,
                height = 164,
                scale = 0.25
            },
            pickup_position = { 0, -1 },
            insert_position = { 0, 1.2 },
            platform_picture = {
                sheet = {
                    filename = "__base__/graphics/entity/inserter/inserter-platform.png",
                    priority = "extra-high",
                    width = 105,
                    height = 79,
                    shift = util.by_pixel(1.5, 7.5 - 1),
                    scale = 0.5,
                    tint = { 0.6, 0.4, 0.4 },
                }
            },
        },
    }
}