local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "resource",
        name = "fullerene",
        icon = "__heliara__/graphics/icons/fullerene.png",
        flags = { "placeable-neutral" },
        order = "a-b-c",
        minable = {
            mining_time = 2,
            result = "fullerene"
        },
        walking_sound = sounds.ore,
        collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
        selection_box = { { -0.25, -0.25 }, { 0.25, 0.25 } },
        autoplace = {
            order = "c",
            probability_expression = 0,
        },
        stage_counts = { 1500, 950, 550, 290, 130 },
        stages = {
            sheet = {
                filename = "__heliara__/graphics/entity/fullerene/fullerene.png",
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
