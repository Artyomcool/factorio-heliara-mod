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
  local x = 0
  local y = 0
  local w = 256
  local h = 256
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

  stripe(4)
  next(256,256)
  stripe(4)
  next(256,256)
  stripe(4)
  next(256,256)
  stripe(4)

  return pictures
end

data:extend({
  {
    name = "clay_cracks",
    type = "optimized-decorative",
    order = "a[vulcanus]-b[decorative]",
    collision_box = {{-8, -8}, {8, 8}},
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
        name = "heliara_stone_richness",
        expression = "random_penalty(x, y, 500, 2, 400)",
    },
    {
        type = "noise-expression",
        name = "heliara_calcite_richness",
        expression = "abs(noise_layer_noise(37)) * 300",
    },
    {
        type = "noise-expression",
        name = "heliara_carbon_coal_richness",
        expression = "random_penalty(x, y, 600, 2, 300)",
    },
    {
        type = "noise-expression",
        name = "heliara_silcrete_richness",
        expression = "random_penalty(x, y, 3000, 2, 2950)",
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
            ["entity:shungite:probability"] = "heliara_shungite_probability",
            ["entity:shungite:richness"] = "heliara_shungite_richness",
            ["entity:stone:probability"] = "heliara_stone_probability",
            ["entity:stone:richness"] = "heliara_stone_richness",
            ["entity:calcite:probability"] = "heliara_calcite_probability",
            ["entity:calcite:richness"] = "heliara_calcite_richness",
            ["entity:carbon_coal:probability"] = "heliara_carbon_coal_probability",
            ["entity:carbon_coal:richness"] = "heliara_carbon_coal_richness",
            ["entity:silcrete:probability"] = "heliara_silcrete_probability",
            ["entity:silcrete:richness"] = "heliara_silcrete_richness",
            ["entity:huge_fullerene_rock:probability"] = "heliara_huge_fullerene_rock_probability",
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

                  ["heliara_sand_dune_blue"] = {},
                  ["heliara_sand_dune_red"] = {},
                  ["heliara_sand_blue"] = {},
                  ["heliara_sand_gray"] = {},
                  ["heliara_sand_red"] = {},
                  ["heliara_sand_yellow"] = {},
                  ["heliara_red_desert_decal_blue"] = {},
                  ["heliara_red_desert_decal_gray"] = {},
                  ["heliara_red_desert_decal_yellow"] = {},
                  ["heliara_light_mud_decal"] = {},
                  ["heliara_mud_decal"] = {},
                  ["heliara_huge_cracks"] = {},
                  ["heliara_cracks"] = {},
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
                    ["calcite"] = {},
                    ["carbon_coal"] = {},
                    ["silcrete"] = {},
                    ["huge_fullerene_rock"] = {},
                }
            }
        }
    }
end

return planet_map_gen