local hit_effects = require("__base__.prototypes.entity.hit-effects")
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
local tungsten_rock_tint = {.6,.8,.9}

return {
    {
        common = {
            name = "huge_fullerene_rock",
            icon = "__space-age__/graphics/icons/huge-volcanic-rock.png"
        },
        entity = {
            type = "simple-entity",
            subgroup = "grass",
            order = "c[decorative]-l[rock]-f[huge-fullerene-rock]",
            collision_box = { { -1.5, -1.1 }, { 1.5, 1.1 } },
            selection_box = { { -1.7, -1.3 }, { 1.7, 1.3 } },
            damaged_trigger_effect = hit_effects.rock(),
            dying_trigger_effect = decorative_trigger_effects.huge_rock(),
            minable = {
                mining_particle = "stone-particle",
                mining_time = 3,
                results = {
                    { type = "item", name = "stone", amount_min = 6, amount_max = 18 },
                    { type = "item", name = "iron-ore", amount_min = 9, amount_max = 27 },
                    { type = "item", name = "fullerene", amount_min = 6, amount_max = 5 },
                },
            },
            map_color = { 129, 105, 78 },
            count_as_rock_for_filtered_deconstruction = true,
            mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
            impact_category = "stone",
            render_layer = "object",
            max_health = 1800,
            autoplace = {
                order = "a[landscape]-c[rock]-a[huge]",
                probability_expression = 0
            },
            pictures = {
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-05.png",
                    width = 201,
                    height = 179,
                    scale = 0.5,
                    shift = { 0.25, 0.0625 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-06.png",
                    width = 233,
                    height = 171,
                    scale = 0.5,
                    shift = { 0.429688, 0.046875 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-07.png",
                    width = 240,
                    height = 192,
                    scale = 0.5,
                    shift = { 0.398438, 0.03125 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-08.png",
                    width = 219,
                    height = 175,
                    scale = 0.5,
                    shift = { 0.148438, 0.132812 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-09.png",
                    width = 240,
                    height = 208,
                    scale = 0.5,
                    shift = { 0.3125, 0.0625 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-10.png",
                    width = 243,
                    height = 190,
                    scale = 0.5,
                    shift = { 0.1875, 0.046875 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-11.png",
                    width = 249,
                    height = 185,
                    scale = 0.5,
                    shift = { 0.398438, 0.0546875 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-12.png",
                    width = 273,
                    height = 163,
                    scale = 0.5,
                    shift = { 0.34375, 0.0390625 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-13.png",
                    width = 275,
                    height = 175,
                    scale = 0.5,
                    shift = { 0.273438, 0.0234375 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-14.png",
                    width = 241,
                    height = 215,
                    scale = 0.5,
                    shift = { 0.195312, 0.0390625 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-15.png",
                    width = 318,
                    height = 181,
                    scale = 0.5,
                    shift = { 0.523438, 0.03125 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-16.png",
                    width = 217,
                    height = 224,
                    scale = 0.5,
                    shift = { 0.0546875, 0.0234375 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-17.png",
                    width = 332,
                    height = 228,
                    scale = 0.5,
                    shift = { 0.226562, 0.046875 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-18.png",
                    width = 290,
                    height = 243,
                    scale = 0.5,
                    shift = { 0.195312, 0.0390625 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-19.png",
                    width = 349,
                    height = 225,
                    scale = 0.5,
                    shift = { 0.609375, 0.0234375 },
                    tint = tungsten_rock_tint
                },
                {
                    filename = "__space-age__/graphics/decorative/huge-volcanic-rock/huge-volcanic-rock-20.png",
                    width = 287,
                    height = 250,
                    scale = 0.5,
                    shift = { 0.132812, 0.03125 },
                    tint = tungsten_rock_tint
                }
            }
        }
    }
}
