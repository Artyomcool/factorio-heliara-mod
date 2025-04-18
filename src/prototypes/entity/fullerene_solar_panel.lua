data:extend({
    {
        type = "item",
        name = "solar-burner",
        icon = "__heliara__/graphics/icons/shungite.png",
        subgroup = "energy",
        order = "solar-burner",
        place_result = "solar-burner",
        stack_size = 50,
        random_tint_color = item_tints.iron_rust,
        --ingredient_to_weight_coefficient = 1,
        default_import_location = "heliara",
    },
    {
        type = "recipe",
        name = "solar-burner",
        category = "crafting",
        icon = "__heliara__/graphics/icons/shungite.png",
        enabled = true,
        ingredients = {

            { type = "item", name = "shungite", amount = 1 },
        },

        energy_required = 7,
        results = {
            { type = "item", name = "solar-burner", amount = 1 },
        },
        allow_productivity = false,
        main_product = "solar-burner",

    },
    {
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
    },
    {
        type = "electric-energy-interface",
        name = "solar-burner",
        icon = "__heliara__/graphics/icons/shungite.png",
        flags = { "placeable-neutral", "player-creation" },
        max_health = 300,
        corpse = "medium-remnants",
        collision_box = { { -5, -5 }, { 5, 5 } },
        selection_box = { { -5, -5 }, { 5, 5 } },
        energy_source = {
            type = "electric",
            buffer_capacity = "2MJ",
            usage_priority = "primary-output",
            input_flow_limit = "0W",
            output_flow_limit = "1MW"
        },
        minable = {mining_time = 0.5, result = "solar-burner"},
        energy_production = "500kW",
        energy_usage = "0kW",

        picture = { filename = "__heliara__/graphics/entity/fullerene_solar_panel/fullerene_solar_panel.png", width = 256, height = 256, shift = { 0.0, 0.0 }, }
    }
})