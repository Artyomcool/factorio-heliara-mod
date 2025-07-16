data:extend({
  {
    type = "noise-function",
    name = "cut",
    parameters = {
        "value",
        "lower_bound"
    },
    expression = "(max(value, lower_bound) - lower_bound) / lower_bound"
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
    type = "noise-function",
    name = "quad_clamp",
    parameters = {
      "value", "zero", "max"
    },
    local_expressions = {
        corrected_value = "max(zero, min(max, value))"
    },
    expression = "peak(corrected_value, zero, max + max - zero)"
  },
  {
    type = "noise-function",
    name = "lpos",
    parameters = {
      "value", "from", "to"
    },
    expression = "clamp((value - from) / (to - from), 0, 1)"
  },
  {
    type = "noise-function",
    name = "between",
    parameters = {
      "value", "from", "to"
    },
    expression = "if (value < from, 0, if (value > to, 0, 1))"
  },
  {
    type = "noise-function",
    name = "multioctave_normal",
    parameters = {
      "seed", "scale", "octaves", "p"
    },
    expression = "1 - min(1, abs(multioctave_noise {x=x,y=y,seed0=map_seed,seed1=seed,input_scale=scale,octaves=octaves,persistence=p,output_scale=(1-p)/(1-pow(p,octaves))}) * 2)"
  },
  {
    type = "noise-function",
    name = "control_index",
    parameters = {
      "v", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12"
    },
    expression =
      "if(v<0.18, v1,\z
        if(v<0.26, v2,\z
          if(v<0.34, v3,\z
            if(v<0.51, v4,\z
              if(v<0.76, v5,\z
                if(v<1.01, v6,\z
                  if(v<1.34, v7,\z
                    if(v<1.51, v8,\z
                      if(v<2.01, v9,\z
                        if(v<3.01, v10,\z
                          if(v<4.01, v11,\z
                            v12\z
      ) ) ) ) ) ) ) ) ) ) )"
  },
  {
    type = "noise-function",
    name = "control_i",
    parameters = {
      "v", "s"
    },
    expression = "control_index(v, s+0, s+1, s+2, s+3, s+4, s+5, s+6, s+7, s+8, s+9, s+10, s+11)"
  },
  {
    type = "noise-expression",
    name = "big_noise_size",
    expression = "control:big_noise:size"
  },
  {
    type = "noise-expression",
    name = "big_noise_freq",
    expression = "control:big_noise:frequency"
  },
  {
    type = "noise-expression",
    name = "big_noise_rich",
    expression = "control:big_noise:richness"
  },
  {
    type = "noise-expression",
    name = "big_noise_details_size",
    expression = "control:big_noise_details:size"
  },
  {
    type = "noise-expression",
    name = "big_noise_details_freq",
    expression = "control:big_noise_details:frequency"
  },
  {
    type = "noise-expression",
    name = "big_noise_details_rich",
    expression = "control:big_noise_details:richness"
  },
  {
    type = "noise-expression",
    name = "small_noise_1_size",
    expression = "control:small_noise_1:size"
  },
  {
    type = "noise-expression",
    name = "small_noise_1_freq",
    expression = "control:small_noise_1:frequency"
  },
  {
    type = "noise-expression",
    name = "small_noise_1_rich",
    expression = "control:small_noise_1:richness"
  },
  {
    type = "noise-expression",
    name = "small_noise_2_size",
    expression = "control:small_noise_2:size"
  },
  {
    type = "noise-expression",
    name = "small_noise_2_freq",
    expression = "control:small_noise_2:frequency"
  },
  {
    type = "noise-expression",
    name = "small_noise_2_rich",
    expression = "control:small_noise_2:richness"
  },
  {
    type = "noise-expression",
    name = "global_cut_left",
    expression = "control:global_cut:size"
  },
  {
    type = "noise-expression",
    name = "global_cut_mid",
    expression = "control:global_cut:frequency"
  },
  {
    type = "noise-expression",
    name = "global_cut_right",
    expression = "control:global_cut:richness"
  },
  {
    type = "autoplace-control",
    name = "big_noise",
    order = "_aa1",
    category = "resource",
    richness = true
  },
  {
    type = "autoplace-control",
    name = "big_noise_details",
    order = "_aa2",
    category = "resource",
    richness = true
  },
  {
    type = "autoplace-control",
    name = "small_noise_1",
    order = "_aa3",
    category = "resource",
    richness = true
  },
  {
    type = "autoplace-control",
    name = "small_noise_2",
    order = "_aa3",
    category = "resource",
    richness = true
  },
  {
    type = "autoplace-control",
    name = "global_cut",
    order = "_aa4",
    category = "resource",
    richness = true
  },

  -- elevation
  {
    type = "noise-expression",
    name = "elevation_heliara",
    expression = "clamp(expr(700, 1/25) - expr(600, 1/24) + 0.5, 0, 1)",--"clamp(((1 - max(0, e1)) - abs(e1) * big_noise_details_freq)*global_cut_mid, global_cut_left-1/6, global_cut_right) * (global_cut_right - global_cut_left)",
    local_functions = {
      base = {
        parameters = {
            "seed", "multiply", "scale"
        },
        expression = "1 - (abs(multioctave_noise{\z
                                    x = x + multioctave_noise{x=x, y=y, seed0=map_seed, seed1=seed+1, octaves=5, input_scale=1/3,persistence = 0.75} * 5,\z
                                    y = y + multioctave_noise{x=x, y=y, seed0=map_seed, seed1=seed+2, octaves=5, input_scale=1/3,persistence = 0.75} * 5,\z
                                    persistence = 0.25,\z
                                    seed0 = map_seed,\z
                                    seed1 = seed,\z
                                    octaves = 6,\z
                                    input_scale = scale,\z
                                    output_scale = multiply})) ^ 0.5"
      },
      expr = {
        parameters = {
          "seed", "scale"
        },
        expression = "max(0, (base(seed, 1, scale) - clamp(base(seed + 5, 0.75, scale), 0, 1)) - 0.1) * 2"
      }
    }
  },
  
  -- moisture
  {
    type = "noise-expression",
    name = "moisture_heliara",
    expression = "(1 - elevation)^4 * (1 - elevation + elevation * base(1, 1/32)^0.25)",
    local_functions = {
      base = {
        parameters = {
            "multiply", "scale"
        },
        expression = "min(1,\z
            abs(multioctave_noise {\z
                x = x,\z
                y = y,\z
                seed0 = map_seed,\z
                seed1 = 503,\z
                input_scale = scale,\z
                octaves = 5,\z
                persistence = 0.25,\z
                output_scale = multiply\z
              }\z
            )\z
        )"
      }
    },
  },

  -- terrains
  {
    type = "noise-expression",
    name = "heliara_dust_base",
    expression = "lpos(moisture, 0.5, 0)"
  },
  {
    type = "noise-expression",
    name = "heliara_rusty_sand_base",
    expression = "peak(moisture, 0.1, 0.9)"
  },
  {
    type = "noise-expression",
    name = "heliara_clay_shale_base",
    expression = "lpos(moisture, 0.9, 1) * 0.8 - elevation / 2"
  },
  {
    type = "noise-expression",
    name = "heliara_iron_carbon_slag",
    expression = "1 - max(heliara_dust_base, heliara_rusty_sand_base, heliara_clay_shale_base) + noise_layer_noise(7)"
  },
  {
    type = "noise-expression",
    name = "heliara_weathered_siliceous_crust",
    expression = "clamp(lpos(elevation, 0.6, 1) * 3 - moisture / 8, 0, 1)"
  },
  {
    type = "noise-expression",
    name = "heliara_ferocalcite_crust",
    expression = "cut(peak(elevation, 0.2, 0.8), 0.1) * 0.25"
  },
  {
    type = "noise-expression",
    name = "heliara_silcrete_crust",
    expression = "lpos(elevation, 0.4, 0)"
  },
  

  -- decals
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_1",
    expression = "cut(heliara_rusty_sand_base, 0.4) * 0.1"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_2",
    expression = "cut(heliara_dust_base, 0.4) * 0.1"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_3",
    expression = "cut(heliara_iron_carbon_slag, 0.4) * 0.1"
  },
  {
    type = "noise-expression",
    name = "heliara_waves_decal",
    expression = "cut(max(heliara_rusty_sand_base, heliara_dust_base), 0.65) * 0.0005"
  },
  {
    type = "noise-expression",
    name = "clay_cracks",
    expression = "cut(heliara_clay_shale_base, 0.4) * 0.025"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_small",
    expression = "cut(1 - heliara_dust_base - heliara_rusty_sand_base + heliara_clay_shale_base / 4, 0.2) * 0.002"
  },
})
