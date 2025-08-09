require("common")

local _name = "carbon_coal"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
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
            map_color = { 0.08, 0.05, 0.1 },
            mining_visualisation_tint = { r = 0.1, g = 0.09, b = 0.12, a = 1.000 },
            minable =
            {
                mining_time = 1,
                results = {
                    {
                        type = "item",
                        name = "coal",
                        probability = 0.25,
                        amount_min = 1,
                        amount_max = 1,
                    },
                    {
                        type = "item",
                        name = "carbon",
                        amount_min = 1,
                        amount_max = 1,
                    },
                }
            },
        },
    },
}