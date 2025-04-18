local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "resource",
        name = "shungite",
        icon = "__heliara__/graphics/icons/shungite.png",
        flags = { "placeable-neutral" },
        order = "a-b-c",
        minable = {
            mining_time = 2,
            result = "shungite"
        },
        walking_sound = sounds.ore,
        collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        autoplace = {
            order = "c",
            probability_expression = 0,
        },
        stage_counts = { 1500, 950, 550, 290, 130 },
        stages = {
            sheet = {
                filename = "__heliara__/graphics/entity/shungite/shungite.png",
                priority = "extra-high",
                size = 117,
                frame_count = 5,
                variation_count = 5,
                scale = 0.4
            }
        },
        map_color = { 0.05, 0.1, 0.2 },
        mining_visualisation_tint = { r = 0.77, g = 0.77, b = 0.9, a = 1.000 }
    }
})
