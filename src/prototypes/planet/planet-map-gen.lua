local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")



data:extend({
    {
        type = "noise-expression",
        name = "heliara_shungite_probability",
        expression = 0.01,
    },
    {
        type = "noise-expression",
        name = "heliara_shungite_richness",
        expression = "random_penalty(x, y, 400, 1, 380)",
    },
    {
        type = "noise-expression",
        name = "heliara_stone_probability",
        expression = 0.01
    },
    {
        type = "noise-expression",
        name = "heliara_stone_richness",
        expression = "random_penalty(x, y, 500, 2, 100)",
    },
    {
        type = "noise-expression",
        name = "heliara_huge_fullerene_rock_probability",
        expression = 0.01,
    },
})

planet_map_gen.heliara = function()
    return
    {
        property_expression_names =
        {
            elevation = "heliara_elevation",
            temperature = "heliara_temperature",
            moisture = "heliara_moisture",
            aux = "heliara_aux",
            ["entity:shungite:probability"] = "heliara_shungite_probability",
            ["entity:shungite:richness"] = "heliara_shungite_richness",
            ["entity:stone:probability"] = "heliara_stone_probability",
            ["entity:stone:richness"] = "heliara_stone_richness",
            ["entity:huge_fullerene_rock:probability"] = "heliara_huge_fullerene_rock_probability",
        },

        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    ["volcanic-ash-soil"] = {},
                    ["natural-yumako-soil"] = {},
                    ["natural-jellynut-soil"] = {},
                    ["wetland-yumako"] = {},
                    ["wetland-jellynut"] = {},
                    ["wetland-blue-slime"] = {},
                    ["wetland-light-green-slime"] = {},
                    ["wetland-green-slime"] = {},
                    ["wetland-light-dead-skin"] = {},
                    ["wetland-dead-skin"] = {},
                    ["wetland-pink-tentacle"] = {},
                    ["wetland-red-tentacle"] = {},
                    ["gleba-deep-lake"] = {},
                    ["lowland-brown-blubber"] = {},
                    ["lowland-olive-blubber"] = {},
                    ["lowland-olive-blubber-2"] = {},
                    ["lowland-olive-blubber-3"] = {},
                    ["lowland-pale-green"] = {},
                    ["lowland-cream-cauliflower"] = {},
                    ["lowland-cream-cauliflower-2"] = {},
                    ["lowland-dead-skin"] = {},
                    ["lowland-dead-skin-2"] = {},
                    ["lowland-cream-red"] = {},
                    ["lowland-red-vein"] = {},
                    ["lowland-red-vein-2"] = {},
                    ["lowland-red-vein-3"] = {},
                    ["lowland-red-vein-4"] = {},
                    ["lowland-red-vein-dead"] = {},
                    ["lowland-red-infection"] = {},
                    ["midland-turquoise-bark"] = {},
                    ["midland-turquoise-bark-2"] = {},
                    ["midland-cracked-lichen"] = {},
                    ["midland-cracked-lichen-dull"] = {},
                    ["midland-cracked-lichen-dark"] = {},
                    ["midland-yellow-crust"] = {},
                    ["midland-yellow-crust-2"] = {},
                    ["midland-yellow-crust-3"] = {},
                    ["midland-yellow-crust-4"] = {},
                    ["highland-dark-rock"] = {},
                    ["highland-dark-rock-2"] = {},
                    ["highland-yellow-rock"] = {},
                    ["pit-rock"] = {}
                }
            },
            ["decorative"] =
            {
                settings =
                {
                    -- nauvis decoratives
                    --["v-brown-carpet-grass"] = {},
                    --["v-green-hairy-grass"] = {},
                    --["v-brown-hairy-grass"] = {},
                    --["v-red-pita"] = {},
                    -- end of nauvis
                    ["sulfur-stain"] = {},
                    ["sulfur-stain-small"] = {},
                    ["sulfuric-acid-puddle"] = {},
                    ["sulfuric-acid-puddle-small"] = {},
                    ["crater-small"] = {},
                    ["crater-large"] = {},
                    ["pumice-relief-decal"] = {},
                    ["small-volcanic-rock"] = {},
                    ["medium-volcanic-rock"] = {},
                    ["tiny-volcanic-rock"] = {},
                    ["tiny-rock-cluster"] = {},
                    ["small-sulfur-rock"] = {},
                    ["tiny-sulfur-rock"] = {},
                    ["sulfur-rock-cluster"] = {},
                    ["waves-decal"] = {},
                }
            },
            ["entity"] =
            {
                settings =
                {
                    ["shungite"] = {},
                    ["stone"] = {},
                    ["huge_fullerene_rock"] = {},
                }
            }
        }
    }
end

return planet_map_gen