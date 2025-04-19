local _name = "fullerene_solar_panel"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/shungite.png",   -- fixme
            icon_size = 500,
        },
        item = {
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                stone = 1
            },
            energy_required = 4,
        },
        entity = {
            type = "burner-generator",
            flags = { "placeable-neutral", "player-creation" },
            minable = { mining_time = 0.75, result = _name },    -- fixme automate
            collision_box = { { -1.99, -1.99 }, { 1.99, 1.99 } },
            selection_box = { { -1.99, -1.99 }, { 1.99, 1.99 } },
            energy_source = {
                type = "electric",
                buffer_capacity = "500kJ",
                usage_priority = "solar",
                input_flow_limit = "500kW",
                output_flow_limit = "500kW",
                render_no_power_icon = false,
                render_no_network_icon = false,
            },
            burner = {
                type = "burner",
                fuel_inventory_size = 1,
                fuel_categories = {"solar_fuel"},
                render_no_power_icon = false,
                render_no_network_icon = false,
                effectivity = 500
            },
            max_power_output = "500kW",

            animation = {
                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                width = 256,
                height = 341,
                frame_count = 1,
                line_length = 1,
                scale = 0.5,
                shift = { 0.0, 0.0 },
            }
        }
    },
    {
        entity = {
            type = "solar-panel",
            name = "solar-panel-hidden-panel",
            flags = { "not-on-map", "placeable-off-grid" },
            selectable_in_game = false,
            hidden = true,
            collision_box = { { 0, 0 }, { 0, 0 } },
            selection_box = { { 0, 0 }, { 0, 0 } },
            energy_source = {
                type = "electric",
                usage_priority = "solar",
                render_no_power_icon = false,
                render_no_network_icon = false,
            },
            production = "500kW",

            pictures = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1,
                direction_count = 1
            },
        }
    },
    {
        entity = {
            type = "electric-pole",
            name = "solar-panel-hidden-pole",
            icon = "__core__/graphics/empty.png",
            icon_size = 1,
            flags = { "not-on-map", "placeable-off-grid" },
            selectable_in_game = false,
            hidden = true,
            collision_box = { { 0, 0 }, { 0, 0 } },
            selection_box = { { 0, 0 }, { 0, 0 } },
            maximum_wire_distance = 0,
            supply_area_distance = 2.5,
            pictures = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1,
                direction_count = 1
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