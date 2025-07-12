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
          line_length = 8,
          scale = 0.5
        },
        {
          picture = "__heliara__/graphics/terrain/" .. name .. ".png",
          count   = 12,
          size    = 2,
          line_length = 4,
          y = 128,
          scale = 0.5
        },
      },
    },
    map_color = map_color,
    autoplace = {probability_expression = expression_base .. " + abs(noise_layer_noise(" .. layer .. ")) / 5"},
  }
end

data:extend({
  tile('heliara_dust', 5, { r = 5, g = 4, b = 7 }, "heliara_dust_base"),
  tile('heliara_rusty_sand', 6, {  r = 40, g = 20, b = 4 }, "heliara_rusty_sand_base"),
  tile('heliara_iron_carbon_slag', 7, {  r = 30, g = 24, b = 24 }, "heliara_iron_carbon_slag"),
  tile('heliara_clay_shale', 8, {  r = 65, g = 70, b = 27  }, "heliara_clay_shale_base"),
  tile('heliara_weathered_siliceous_crust', 9, {  r = 80, g = 90, b = 100 }, "heliara_weathered_siliceous_crust"),
  tile('heliara_ferocalcite_crust', 10, {  r = 80, g = 90, b = 100 }, "heliara_ferocalcite_crust"),
})

local function decal(x, y, w, h)
    return {
        filename = "__heliara__/graphics/decal/decals.png",
        priority = "extra-high",
        x = x,
        y = y,
        width = w,
        height = h,
        scale = 0.5,
    }
end

local function clay_cracks_decals()
  local pictures = {
  }
  local x = 144
  local y = 0
  local w = 256
  local h = 336
  local stripe = function(c)
    for i = 1, c, 1 do
      table.insert(pictures, decal(x, y, w, h))
      y = y + h
    end
  end
  local next = function(nw,nh)
    y = 0
    x = x + w
    w = nw
    h = nh
  end

  stripe(1)
  h=21*16
  stripe(1)
  h=14*16
  stripe(1)

  next(4*16,4*16)
  stripe(1)
  h=11*16
  stripe(1)
  h=8*16
  stripe(1)

  return pictures
end

data:extend({
  {
    name = "clay_cracks",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]",
    collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
    --collision_mask = {},
    render_layer = "decals",
    tile_layer =  255,
    autoplace = {
      order = "d[ground-surface]-e[crater]-a[small]",
      probability_expression = "clay_cracks"
    },
    pictures = clay_cracks_decals()
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
                    ["heliara_clay_shale"] = {},
                    ["heliara_weathered_siliceous_crust"] = {},
                    ["heliara_ferocalcite_crust"] = {},
                }
            },
            ["decorative"] =
            {
                settings =
                {

                  -- ["small-sand-rock"] = {}, -- todo make black and red tints
                  -- ["sand-dune-decal"] = {},  -- todo make black and red tints
                  -- ["sand-decal"] = {},  -- todo make 4 tints
                  --["red-desert-decal"] = {},  -- todo make 4 tints
                  --["light-mud-decal"] = {},  -- todo make glue tints
                  --["dark-mud-decal"] = {},  -- todo make default tints
                  --["large-volcanic-stone"] = {},  -- todo make default, black and red tints
                  --["huge-cold-cracks"] = {},  -- todo make default, black and red tints
                  --["large-cold-cracks"] = {},  -- todo make default, black and red tints
                  ["clay_cracks"] = {},
                  ["heliara_tiny_rock_1"] = {},
                  ["heliara_tiny_rock_2"] = {},
                  ["heliara_tiny_rock_3"] = {},
                  ["heliara_waves_decal"] = {},
                  ["heliara_calcite_small"] = {},
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