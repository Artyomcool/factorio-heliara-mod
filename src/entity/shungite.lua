require("common")

local _name = "shungite"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 500,
        },
        resource = {
            flags = { "placeable-neutral" },
            selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
            mining_time = 0.75,
            stage_counts = { 1500, 1200, 950, 550, 290, 130, 50 },
            stages = {
                sheet = {
                    filename = "__base__/graphics/entity/stone/stone.png",
                    size = 128,
                    frame_count = 8,
                    variation_count = 8,
                    scale = 0.5,
                    tint = { r = .43, g = .42, b = .49 },
                }
            },
            autoplace = {
                order = "c",
                probability_expression = 0,
            },
            map_color = { 0.05, 0.1, 0.2 },
            mining_visualisation_tint = { r = 0.77, g = 0.77, b = 0.9, a = 1.000 }
        },
        item = {
            order = "a-b-c",
            --subgroup = "heliara",
            color_hint = { text = "T" },
            subgroup = "raw-material",

            stack_size = 100,
            weight = 1 * kg
        }
    },
    {
        recipe = {
            icon = "__heliara__/graphics/icons/carbon_from_shungite.png",
            name = "carbon-from-shungite",
            ingredients = {
                shungite = 100,
            },
            fluid_ingredients = {
                water = 200,
            },
            results = {
                carbon = 40,
                ["iron-ore"] = 5,
            },
            energy_required = 5,
            category = "fullerene-chemistry",
            enabled = false,
            main_product = "carbon",
        },
    },
}