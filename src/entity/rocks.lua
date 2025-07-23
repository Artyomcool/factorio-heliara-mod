local hit_effects = require("__base__.prototypes.entity.hit-effects")
local decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")

return {
    {
        common = {
            name = "huge_fullerene_rock",
            icon = "__heliara__/graphics/icons/huge-heliara-rock.png",
        },
        entity = {
            type = "simple-entity",
            subgroup = "grass",
            order = "c[decorative]-l[rock]-f[huge-fullerene-rock]",
            collision_box = { { -1.7, -1.2 }, { 1.7, 1.2 } },
            selection_box = { { -1.8, -1.3 }, { 1.8, 1.3 } },
            damaged_trigger_effect = hit_effects.rock(),
            dying_trigger_effect = decorative_trigger_effects.huge_rock(),
            minable = {
                mining_particle = "stone-particle",
                mining_time = 5,
                results = {
                    { type = "item", name = "stone", amount_min = 6, amount_max = 18 },
                    { type = "item", name = "iron-ore", amount_min = 9, amount_max = 27 },
                    { type = "item", name = "fullerene", amount_min = 3, amount_max = 5 },
                    { type = "item", name = "shungite", amount_min = 1, amount_max = 7 },
                    { type = "item", name = "graphite", amount_min = 1, amount_max = 3 },
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
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-00.png",
                    width = 309,
                    height = 247,
                    scale = 0.5,
                    shift = { 0.65, -0.6 },
                },
                {
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-01.png",
                    width = 254,
                    height = 186,
                    scale = 0.5,
                    shift = { 0.22, -0.45 },
                },
                {
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-02.png",
                    width = 279,
                    height = 193,
                    scale = 0.5,
                    shift = { 0.55, -0.45 },
                },
                {
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-03.png",
                    width = 272,
                    height = 206,
                    scale = 0.5,
                    shift = { 0.5, -0.6 },
                },
                {
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-04.png",
                    width = 268,
                    height = 230,
                    scale = 0.5,
                    shift = { 0.5, -0.7 },
                },
                {
                    filename = "__heliara__/graphics/decorative/huge-heliara-rock/huge-heliara-rock-05.png",
                    width = 265,
                    height = 228,
                    scale = 0.5,
                    shift = { 0.4, -0.66 },
                },
            }
        }
    }
}
