local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")



data:extend({
    {
        type = "noise-expression",
        name = "heliara_fullerene_probability",
        expression = "spot_noise{x = x,\z
                              y = y,\z
                              seed0 = map_seed,\z
                              seed1 = 3,\z
                              candidate_spot_count = 1,\z
                              suggested_minimum_candidate_point_spacing = 400,\z
                              skip_span = 1,\z
                              skip_offset = 0,\z
                              region_size = 256,\z
                              density_expression = 1,\z
                              spot_quantity_expression = 10000,\z
                              spot_radius_expression = 100,\z
                              hard_region_target_quantity = 0,\z
                              spot_favorability_expression = 1,\z
                              basement_value = 0,\z
                              maximum_spot_basement_radius = 100}",
    }
})
data:extend({
    {
        type = "noise-expression",
        name = "heliara_fullerene_richness",
        expression = "random_penalty(x, y, 2000, 1, 1800)",
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