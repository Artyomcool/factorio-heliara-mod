local item_tints = require("__base__.prototypes.item-tints")

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
            energy_required = 2,
            enabled = false
        },
        entity = {
            type = "electric-pole",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            maximum_wire_distance = 1,
            supply_area_distance = 0.95,
            minable = { mining_time = 0.2, result = _name },
            draw_copper_wires = false,
            light =
            {
                minimum_darkness = 0,
                intensity = 0.75,
                size = 3,
                color = {r=0.5, g=0.8, b=1.0},
                flicker_interval = 1,
                flicker_min_modifier = 0.1,
                flicker_max_modifier = 1.1,
                offset_flicker = true,
                shift = { 0, -1.2 }
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
                        width = 93,
                        height = 106,
                        frame_count = 1,
                        line_length = 1,
                        shift = util.by_pixel( 0, -16),
                        scale = 0.5,
                        direction_count = 1,
                    },
                    {
                        filename = "__heliara__/graphics/entity/" .. _name .. "/lights.png",
                        width = 64*4,
                        height = 64*4,
                        frame_count = 16,
                        line_length = 4,
                        scale = 0.5/4,
                        direction_count = 1,
                    }
                }
            },
            connection_points = {
                {
                    shadow = { copper = { 0, 0 } },
                    wire = { copper = { 0, 0 } }
                }
            }
        }
    },
}