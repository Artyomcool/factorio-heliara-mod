local _name = "fullerene_solar_panel"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/fullerene.png",
            icon_size = 500,
        },
        item = {
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
        },
        recipe = {
            ingredients = {
                fullerene = 1
            },
            energy_required = 10,
        },
        entity = {
            type = "electric-energy-interface",
            flags = { "placeable-neutral", "player-creation" },
            max_health = 300,
            collision_box = { { -4, -3 }, { 4, 5 } },
            selection_box = { { -4, -3 }, { 4, 5 } },
            energy_source = {
                type = "electric",
                buffer_capacity = "500kJ",
                usage_priority = "primary-output",
                input_flow_limit = "0W",
                output_flow_limit = "500kW"
            },
            energy_production = "500kW",
            energy_usage = "0kW",

            animation = {
                filename = "__heliara__/graphics/entity/fullerene_solar_panel/fullerene_solar_panel.png",
                width = 256,
                height = 341,
                frame_count = 1,
                line_length = 1,
                shift = { 1, 0.0 },
            }
        }
    },
    {
        entity = {
            type = "electric-pole",
            name = "solar-generator-hidden-pole",
            icon = "__core__/graphics/empty.png",
            icon_size = 1,
            flags = { "not-on-map", "placeable-off-grid" },
            selectable_in_game = false,
            collision_box = { { 0, 0 }, { 0, 0 } },
            selection_box = { { 0, 0 }, { 0, 0 } },
            maximum_wire_distance = 0,
            supply_area_distance = 9,
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