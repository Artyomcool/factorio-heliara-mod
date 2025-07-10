local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

local function transition_masks()
  return {
    mask_spritesheet = "__base__/graphics/terrain/masks/transition-1.png",
    mask_layout =
    {
      scale = 0.5,
      inner_corner =
      {
        count = 8,
      },
      outer_corner =
      {
        count = 8,
        x = 64*9
      },
      side =
      {
        count = 8,
        x = 64*9*2
      },
      u_transition =
      {
        count = 1,
        x = 64*9*3
      },
      o_transition =
      {
        count = 1,
        x = 64*9*4
      }
    }
  }
end

data:extend({
  -- Сам тайл
  {
    type = "tile",
    name = "heliara_dust",
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = 50,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__heliara__/graphics/terrain/heliara_dust.png",
          count   = 16,
          size    = 1,
          line_length = 8
        },
        {
          picture = "__heliara__/graphics/terrain/heliara_dust.png",
          count   = 12,
          size    = 2,
          line_length = 4,
          y = 64
        },
      },
    },
    map_color = { r = 0, g = 50, b = 50 },
    decorative_removal_probability = 0.5,

--    transitions = {},

    autoplace = {probability_expression = "expression_in_range_base(-10, 0.7, 11, 11) + noise_layer_noise(19)"},
  }
})
data:extend({
  -- Сам тайл
  {
    type = "tile",
    name = "heliara_dirt",
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = 60,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__heliara__/graphics/terrain/heliara_dirt.png",
          count   = 16,
          size    = 1,
          line_length = 8,
          scale = 0.5
        },
        {
          picture = "__heliara__/graphics/terrain/heliara_dirt.png",
          count   = 12,
          size    = 2,
          line_length = 4,
          y = 128,
          scale = 0.5
        },
      },
    },
    map_color = { r = 50, g = 50, b = 50 },
    decorative_removal_probability = 0.5,

--    transitions = {},

    autoplace = {probability_expression = "expression_in_range_base(-10, 0.7, 11, 11) + noise_layer_noise(20)"},
  }
})

data:extend({
    {
        type = "noise-expression",
        name = "heliara_shungite_probability",
        expression = "if ((y + 3 * (floor(x / 7) % 2)) % 6 > 4, \z
                        0, \z
                        if ((y + 3 * (floor(x / 7) % 2)) % 6 == 2, \z
                          1, \z
                          if (abs((y + 3 * (floor(x / 7) % 2)) % 6 - 2) - 1 == 0, \z
                            if (abs(x % 7 - 3) - 1 < 2, 1, 0), \z
                            if (abs(x % 7 - 3) - 1 < 1, 1, 0) \z
                          ) \z
                        ) \z
                      ) \z
                      * \z
                      if(voronoi_spot_noise{ \z
                        x = x + 5.2 * sin(0.17 * y), \z
                        y = y + 2.7 * cos(0.12 * x), \z
                        seed0 = map_seed, \z
                        seed1 = 'heliara-shungite', \z
                        grid_size = 113, \z
                        distance_type = 'euclidean', \z
                        jitter = 0.8 \z
                      } < 0.1, 1, 0)"
    },
    {
        type = "noise-expression",
        name = "heliara_shungite_richness",
        expression = "random_penalty(x, y, 400, 1, 380)",
    },
    {
        type = "noise-expression",
        name = "heliara_stone_probability",
        expression = "clamp(voronoi_spot_noise{ \z
                x = x + 4.1 * cos(0.13 * y), \z
                y = y + 5.3 * sin(0.21 * x), \z
                seed0 = map_seed + 1, \z
                seed1 = 'heliara-stone', \z
                grid_size = 97, \z
                distance_type = 'euclidean', \z
                jitter = 0.7 \z
                } * 7.5 - 6, 0, 1)"
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
                    -- ["volcanic-ash-soil"] = {},
                    -- ["natural-yumako-soil"] = {},
                    -- ["natural-jellynut-soil"] = {},
                    -- ["wetland-yumako"] = {},
                    -- ["wetland-jellynut"] = {},
                    -- ["wetland-blue-slime"] = {},
                    -- ["wetland-light-green-slime"] = {},
                    -- ["wetland-green-slime"] = {},
                    -- ["wetland-light-dead-skin"] = {},
                    -- ["wetland-dead-skin"] = {},
                    -- ["wetland-pink-tentacle"] = {},
                    -- ["wetland-red-tentacle"] = {},
                    -- ["gleba-deep-lake"] = {},
                    -- ["lowland-brown-blubber"] = {},
                    -- ["lowland-olive-blubber"] = {},
                    -- ["lowland-olive-blubber-2"] = {},
                    -- ["lowland-olive-blubber-3"] = {},
                    -- ["lowland-pale-green"] = {},
                    -- ["lowland-cream-cauliflower"] = {},
                    -- ["lowland-cream-cauliflower-2"] = {},
                    -- ["lowland-dead-skin"] = {},
                    -- ["lowland-dead-skin-2"] = {},
                    -- ["lowland-cream-red"] = {},
                    -- ["lowland-red-vein"] = {},
                    -- ["lowland-red-vein-2"] = {},
                    -- ["lowland-red-vein-3"] = {},
                    -- ["lowland-red-vein-4"] = {},
                    -- ["lowland-red-vein-dead"] = {},
                    -- ["lowland-red-infection"] = {},
                    -- ["midland-turquoise-bark"] = {},
                    -- ["midland-turquoise-bark-2"] = {},
                    -- ["midland-cracked-lichen"] = {},
                    -- ["midland-cracked-lichen-dull"] = {},
                    -- ["midland-cracked-lichen-dark"] = {},
                    -- ["midland-yellow-crust"] = {},
                    -- ["midland-yellow-crust-2"] = {},
                    -- ["midland-yellow-crust-3"] = {},
                    -- ["midland-yellow-crust-4"] = {},
                    -- ["highland-dark-rock"] = {},
                    -- ["highland-dark-rock-2"] = {},
                    -- ["highland-yellow-rock"] = {},
                    -- ["pit-rock"] = {},
                    ["heliara_dust"] = {},
                    ["heliara_dirt"] = {}
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
                    --["huge_fullerene_rock"] = {},
                }
            }
        }
    }
end

return planet_map_gen