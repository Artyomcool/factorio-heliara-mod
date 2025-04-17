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
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        autoplace = {
            order = "c",
            probability_expression = 0,
        },
        stage_counts = { 15000, 9500, 5500, 2900, 1300, 400, 150, 80, 20 },
        stages = {
            sheet = {
                filename = "__heliara__/graphics/entity/fullerene/fullerene.png",
                priority = "extra-high",
                size = 50,
                frame_count = 9,
                variation_count = 9,
                scale = 1
            }
        },
        map_color = { 0.05, 0.1, 0.2 },
        mining_visualisation_tint = { r = 0.77, g = 0.77, b = 0.9, a = 1.000 }
    }
})
