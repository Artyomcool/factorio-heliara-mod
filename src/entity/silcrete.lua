require("common")

local _name = "silcrete"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 64,
        },
        resource = {
            flags = { "placeable-neutral" },
            selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
            mining_time = 0.75,
            stage_counts = { 1500, 1200, 950, 550, 290, 130, 50 },
            stages = {
                sheet = {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name ..  ".png",
                    size = 128,
                    frame_count = 8,
                    variation_count = 8,
                    scale = 0.5,
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

            stack_size = 50
        },
        recipe = {
            category = "smelting",
            energy_required = 5,
            enabled = false,
            ingredients = {
                [_name] = 10,
            },
            results = {
                concrete = 10
            },
            allow_productivity = true,
            main_product = "concrete"
        }
    },
}