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

data:extend({{ type = "collision-layer", name = "fragile" }})

local function tile(name, layer, map_color, allow_build)
  return {
    type = "tile",
    name = name,
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers = allow_build and { ground_tile = true } or { fragile=true, is_lower_object = true }
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
    autoplace = {probability_expression = name},
    default_cover_tile = not allow_build and "concrete" or nil
  }
end

data:extend({
  tile('heliara_dust', 5, { r = 6, g = 5, b = 8 }, false),
  tile('heliara_rusty_sand', 6, {  r = 40, g = 20, b = 4 }, false),
  tile('heliara_iron_carbon_slag', 7, {  r = 30, g = 24, b = 24 }, false),
  tile('heliara_clay_shale', 8, {  r = 65, g = 67, b = 27 }, false),
  tile('heliara_weathered_siliceous_crust', 9, {  r = 80, g = 90, b = 100 }, true),
  tile('heliara_ferocalcite_crust', 10, {  r = 125, g = 120, b = 40 }, false),
  tile('heliara_silcrete_crust', 11, {  r = 15, g = 15, b = 10 }, true),
})

local t = {}

for i = 1, 255, 1 do
  t["c-" .. i] = {}
  data:extend({{
    type = "tile",
    name = "c-" .. i,
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = 4,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__core__/graphics/white-square.png",
          count = 1,
          size = 1,
          scale = 32,
        },
      },
    },
    map_color = {i/255, i/255, i/255},
    tint = {i/255, i/255, i/255},
    autoplace = {probability_expression = "between(elevation," .. (i-1)/255 .. "," .. i/255 .. ")"},
  }});
end
  t["c-" .. 256] = {}
  data:extend({{
    type = "tile",
    name = "c-" .. 256,
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = 4,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__core__/graphics/white-square.png",
          count = 1,
          size = 1,
          scale = 32,
        },
      },
    },
    map_color = {255,0,0},
    tint = {255,0,0},
    autoplace = {probability_expression = "if (elevation < 0, 1, 0)"},
  }});
  t["c-" .. 257] = {}
  data:extend({{
    type = "tile",
    name = "c-" .. 257,
    needs_correction = false,
    walking_speed_modifier = 1.0,
    collision_mask = {
        layers={
            ground_tile=true
        }
    },
    layer = 4,
    variants = {
      transition = transition_masks(),
      main = {
        {
          picture = "__core__/graphics/white-square.png",
          count = 1,
          size = 1,
          scale = 32,
        },
      },
    },
    map_color = {255,255,0},
    tint = {255,255,0},
    autoplace = {probability_expression = "if (elevation > 1, 1, 0)"},
  }});

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

local debug = false

planet_map_gen.heliara = function()
    return
    {
        property_expression_names =
        {
            moisture = "moisture_heliara",
            elevation = "elevation_heliara",
            --["entity:shungite:probability"] = "heliara_shungite_probability",
            --["entity:shungite:richness"] = "heliara_shungite_richness",
            --["entity:stone:probability"] = "heliara_stone_probability",
            --["entity:stone:richness"] = "heliara_stone_richness",
            --["entity:huge_fullerene_rock:probability"] = "heliara_huge_fullerene_rock_probability",
        },

        autoplace_controls = {
          ["big_noise"] = {frequency = 1, size = 1, richness = 1, tmp = 1},
          ["big_noise_details"] = {frequency = 1, size = 1, richness = 1},
          ["small_noise_1"] = {frequency = 1, size = 1, richness = 1},
          ["small_noise_2"] = {frequency = 1, size = 1, richness = 1},
          ["global_cut"] = {frequency = 1, size = 1, richness = 1},
        },

        autoplace_settings =
        {
            ["tile"] =
            {
                settings = debug and t or
                {
                    ["heliara_dust"] = {},
                    ["heliara_rusty_sand"] = {},
                    ["heliara_iron_carbon_slag"] = {},
                    ["heliara_clay_shale"] = {},
                    ["heliara_weathered_siliceous_crust"] = {},
                    ["heliara_ferocalcite_crust"] = {},
                    ["heliara_silcrete_crust"] = {},
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