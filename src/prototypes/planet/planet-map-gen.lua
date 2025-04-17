local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")



data:extend({
    {
        type = "noise-expression",
        name = "heliara_fullerene_probability",
        expression = "(1000 * ((1 + 2) * random_penalty_between(0.9, 1, 1) - 1))",
    }
})
data:extend({
    {
        type = "noise-expression",
        name = "heliara_fullerene_richness",
        expression = "2 * random_penalty_between(0.9, 1, 1)\z
                  * 10000 * 1\z
                  * 1"
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
            ["entity:fullerene:probability"] = "heliara_fullerene_probability",
            ["entity:fullerene:richness"] = "heliara_fullerene_richness",
        },

        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    ["volcanic-soil-dark"] = {},
                    ["volcanic-soil-light"] = {},
                    ["volcanic-ash-soil"] = {},
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
                    ["fullerene"] = {},
                }
            }
        }
    }
end

return planet_map_gen