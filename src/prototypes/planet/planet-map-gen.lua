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

local function tile(name, layer, map_color, expression_base)
  return {
    type = "tile",
    name = name,
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = layer,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__heliara__/graphics/terrain/" .. name .. ".png",
          count   = 16,
          size    = 1,
          line_length = 8
        },
        {
          picture = "__heliara__/graphics/terrain/" .. name .. ".png",
          count   = 12,
          size    = 2,
          line_length = 4,
          y = 64
        },
      },
    },
    map_color = map_color,
    autoplace = {probability_expression = expression_base .. " + abs(noise_layer_noise(" .. layer .. ")) / 5"},
  }
end

data:extend({
  tile('heliara_dust', 5, { r = 4, g = 4, b = 5 }, "peak(elevation, 0.2, 0.9) * peak(moisture, 0, 0.5) + 0.91"),
  tile('heliara_rusty_sand', 6, {  r = 13, g = 8, b = 2 }, "peak(elevation, 0.2, 0.8) * peak(moisture, 0.2, 0.8) + 0.79"),
  tile('heliara_iron_carbon_slag', 7, {  r = 22, g = 17, b = 17 }, "1 + abs(noise_layer_noise(1)) / 2"),
  tile('heliara_clay_shale', 8, {  r = 65, g = 70, b = 27  }, "peak(elevation, 0, 0.2) * peak(moisture, 0.7, 1) + 0.86"),
})

local function decals()
  local pictures = {
  }
  local x = 0
  local y = 0
  local w = 32
  local h = 32
  local d = function()
    table.insert(pictures, {
        filename = "__heliara__/graphics/decal/decals.png",
        priority = "extra-high",
        x = x,
        y = y,
        width = w,
        height = h,
        scale = 0.5,
    })
  end
  local stripe = function(c)
    for i = 1, c, 1 do
      d();
      y = y + h
    end
  end

  stripe(8)
  h = 48
  stripe(2)

  x = 32
  y = 0
  w = 48
  h = 48
  stripe(5)
  h = 64
  stripe(3)
  x = 80
  y = 0
  w = 64
  h = 64
  stripe(1)
  h = 48
  stripe(1)
  h = 64
  stripe(1)
  h = 96
  stripe(1)
  h = 48
  stripe(1)
  h = 64
  stripe(4)
  h = 48
  stripe(2)
  h = 64
  stripe(2)

  return pictures
end

data:extend({
  {
    name = "rust_crystals",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]",
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    --collision_mask = {},
    render_layer = "decals",
    tile_layer =  255,
    autoplace = {
      order = "d[ground-surface]-e[crater]-a[small]",
      probability_expression = "peak(moisture, 0.2, 0.8) * peak(elevation, 0.2, 1) * 0.05"
    },
    pictures = decals()
  },
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
                      } < (1 - moisture * 100) * 0.1, 1, 0)"
    },
    {
        type = "noise-expression",
        name = "heliara_shungite_richness",
        expression = "random_penalty(x, y, 400, 1, 380)",
    },
    {
        type = "noise-function",
        name = "parabola",
        parameters = {
          "value", "left_zero", "right_zero"
        },
        expression = "(value - left_zero) * (value - right_zero)"
    },
    {
        type = "noise-function",
        name = "peak",
        parameters = {
          "value", "left_zero", "right_zero"
        },
        expression = "clamp(parabola(value, left_zero, right_zero) / parabola((left_zero + right_zero) / 2, left_zero, right_zero), 0, 1)"
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
                } * 7.5 - 5.75, 0, 1) * min(1, peak(elevation, 0.05, 0.2) * 20)"
    },
    {
        type = "noise-expression",
        name = "heliara_stone_richness",
        expression = "random_penalty(x, y, 500, 2, 400)",
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
            moisture = "moisture_heliara",
            elevation = "elevation_heliara",
            ["entity:shungite:probability"] = "heliara_shungite_probability",
            ["entity:shungite:richness"] = "heliara_shungite_richness",
            ["entity:stone:probability"] = "heliara_stone_probability",
            ["entity:stone:richness"] = "heliara_stone_richness",
            --["entity:huge_fullerene_rock:probability"] = "heliara_huge_fullerene_rock_probability",
        },

        autoplace_controls = {},

        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    ["heliara_dust"] = {},
                    ["heliara_rusty_sand"] = {},
                    ["heliara_iron_carbon_slag"] = {},
                    ["heliara_clay_shale"] = {}
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
                    -- ["sulfur-stain"] = {},
                    -- ["sulfur-stain-small"] = {},
                    -- ["sulfuric-acid-puddle"] = {},
                    -- ["sulfuric-acid-puddle-small"] = {},
                    -- ["crater-small"] = {},
                    -- ["crater-large"] = {},
                    -- ["pumice-relief-decal"] = {},
                    -- ["small-volcanic-rock"] = {},
                    -- ["medium-volcanic-rock"] = {},
                    -- ["tiny-volcanic-rock"] = {},
                    -- ["tiny-rock-cluster"] = {},
                    -- ["small-sulfur-rock"] = {},
                    -- ["tiny-sulfur-rock"] = {},
                    -- ["sulfur-rock-cluster"] = {},
                    ["rust_crystals"] = {},
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