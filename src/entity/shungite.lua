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
            mining_time = 2,
            stage_counts = { 1500, 950, 550, 290, 130 },
            stages = {
                sheet = {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                    size = 117,
                    frame_count = 5,
                    variation_count = 5,
                    scale = 0.4
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

            stack_size = 100,
            weight = 0.01 * kg
        }
    }
}