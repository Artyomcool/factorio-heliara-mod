require("common.common")

local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")
local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout

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

local function weathered_cliff_transitions()
  return {
    {
      to_tiles = {
        "heliara_dust",
        "heliara_rusty_sand",
        "heliara_iron_carbon_slag",
        "heliara_clay_shale",
        "heliara_ferocalcite_crust",
        "heliara_silcrete_crust",
      },
      transition_group = default_transition_group_id,
      spritesheet = "__space-age__/graphics/terrain/water-transitions/lava-stone-cold.png",
      layout = tile_spritesheet_layout.transition_16_16_16_4_4,
      effect_map_layout =
      {
        spritesheet = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
        inner_corner_count = 8,
        outer_corner_count = 8,
        side_count = 8,
        u_transition_count = 2,
        o_transition_count = 1
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

local function tile_hd(name, layer, map_color, allow_build)
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
          picture     = "__heliara__/graphics/terrain/" .. name .. ".png",
          count       = 11,
          size        = 4,
          line_length = 4,
          scale       = 0.5,
          x           = 0,
          y           = 0,
        },
        {
          picture     = "__heliara__/graphics/terrain/" .. name .. ".png",
          count       = 16,
          size        = 1,
          line_length = 4,
          scale       = 0.5,
          x           = 768,
          y           = 512,
        },
        {
          picture     = "__heliara__/graphics/terrain/" .. name .. ".png",
          count       = 16,
          size        = 2,
          line_length = 8,
          scale       = 0.5,
          x           = 0,
          y           = 768,
        },
      },
    },
    map_color = map_color,
    autoplace = {probability_expression = name},
    transitions = name == "heliara_weathered_siliceous_crust" and weathered_cliff_transitions() or nil,
    default_cover_tile = not allow_build and "concrete" or nil
  }
end

local function tile_with_material(name, layer, map_color, allow_build)
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
      material_background = {
        picture = "__heliara__/graphics/terrain/" .. name .. "_material.png",
        count   = 1,
        scale   = 0.5,
      },
      material_texture_width_in_tiles  = 1024 / 64,  -- 16 tiles
      material_texture_height_in_tiles = 1024 / 64,  -- 16 tiles
    },
    map_color = map_color,
    autoplace = {probability_expression = name},
    default_cover_tile = not allow_build and "concrete" or nil
  }
end

local function tile_with_material_hd(name, layer, map_color, allow_build)
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
      material_background = {
        picture = "__heliara__/graphics/terrain/" .. name .. "_material.png",
        count   = 16,
        scale   = 0.5,
        line_length = 4,
      },
      material_texture_width_in_tiles  = 8,
      material_texture_height_in_tiles = 8,
    },
    map_color = map_color,
    autoplace = {probability_expression = name},
    default_cover_tile = not allow_build and "concrete" or nil
  }
end

data:extend({
  tile(                  'heliara_dust',                      5,  { r = 21,  g = 22,  b = 28  }, false),
  tile_with_material(    'heliara_rusty_sand',                6,  { r = 168, g = 75,  b = 22  }, false),
  tile(                  'heliara_iron_carbon_slag',          7,  { r = 47,  g = 45,  b = 42  }, false),
  tile_with_material(    'heliara_clay_shale',                8,  { r = 91,  g = 75,  b = 46  }, false),
  tile_hd( 'heliara_weathered_siliceous_crust', 9,  { r = 66,  g = 63,  b = 59  }, true),
  tile_with_material(    'heliara_ferocalcite_crust',         10, { r = 135, g = 82,  b = 37  }, false),
  tile_with_material(    'heliara_silcrete_crust',            11, { r = 42,  g = 37,  b = 30  }, true),
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


data:extend({
    {
        type = "noise-expression",
        name = "heliara_shungite_richness",
        expression = "(noise_layer_noise(38) / 2 + 0.25) * 4000",
    },
    {
        type = "noise-expression",
        name = "heliara_stone_richness",
        expression = "random_penalty(x, y, 500, 2, 400)",
    },
    {
        type = "noise-expression",
        name = "heliara_calcite_richness",
        expression = "(noise_layer_noise(37) / 2 + 0.25) * 300",
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
            ["entity:brackish_vent:richness"] = "1000000",
            ["entity:brackish_vent:probability"] = "heliara_brackish_vent_probability",
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
                  ["heliara_carbon_slag_scab"] = {},
                  ["heliara_carbon_slag_small_scab"] = {},
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
                    ["brackish_vent"] = {},
                }
            }
        }
    }
end

return planet_map_gen
