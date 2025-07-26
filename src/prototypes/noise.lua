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
    name = "heliara_dust",
    expression = "max(0, 0.05 - moisture) / 0.1 * 4 + noise_layer_noise(1) / 4"
  },
  {
    type = "noise-expression",
    name = "heliara_rusty_sand",
    expression = "max(0, 0.25 - max(0, 0.5 - moisture)) / 0.25 * 4 + noise_layer_noise(2) / 10 + abs(noise_layer_noise(21)) * min(moisture, 0.5) * 6"
  },
  {
    type = "noise-expression",
    name = "heliara_clay_shale",
    expression = "(max(0, moisture - 0.8) / 0.2)^0.25 * 5 + noise_layer_noise(3) / 10"
  },
  {
    type = "noise-expression",
    name = "heliara_iron_carbon_slag",
    expression = "0.5"
  },
  {
    type = "noise-expression",
    name = "heliara_weathered_siliceous_crust",
    expression = "max(0, elevation - 0.9) / 0.1 * 5 + noise_layer_noise(4) / 8 - 5*5*max(0, 0.2 - abs(multioctave_noise {\z
                    x = x,\z
                    y = y,\z
                    seed0 = map_seed,\z
                    seed1 = 509,\z
                    input_scale = 1/3,\z
                    octaves = 5,\z
                    persistence = 0.25,\z
                    output_scale = 1\z
                  }))"
  },
  {
    type = "noise-expression",
    name = "heliara_ferocalcite_crust",
    expression = "max(0, 0.15 - max(0, 0.5 - elevation))*2 + noise_layer_noise(5) / 2"
  },
  {
    type = "noise-expression",
    name = "heliara_silcrete_crust",
    expression = "max(0, 0.35 - elevation) / 0.35 * 5 + noise_layer_noise(6) / 10"
  },

  -- resources
  {
    type = "noise-expression",
    name = "heliara_stone_probability",
    expression = "peak(elevation, 0.97, 1.05) * basis_noise{x=x, y=y, seed0=map_seed, seed1=301, input_scale=1/512} - abs(basis_noise{x=x, y=y, seed0=map_seed, seed1=302, input_scale=1/16}) - abs(basis_noise{x=x, y=y, seed0=map_seed, seed1=302, input_scale=1/128})"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_probability",
    expression = "max(\z
      0,\z
      spot_noise{\z
        x=x,\z
        y=y,\z
        density_expression=0.01,\z
        spot_quantity_expression=2000,\z
        spot_radius_expression = 20,\z
        spot_favorability_expression=max(heliara_ferocalcite_crust, heliara_clay_shale)\z
            - max(heliara_silcrete_crust, heliara_weathered_siliceous_crust, heliara_iron_carbon_slag, heliara_rusty_sand, heliara_dust),\z
        seed0=map_seed,\z
        seed1=301,\z
        basement_value=-1000,\z
        maximum_spot_basement_radius=40\z
      }\z
    )\z
        * multioctave_noise {\z
            x = x,\z
            y = y,\z
            seed0 = map_seed,\z
            seed1 = 341,\z
            input_scale = 1/4,\z
            octaves = 4,\z
            persistence = 0.5\z
          }"
  },
  {
    type = "noise-expression",
    name = "heliara_shungite_probability",
    local_expressions = {
      dy = "(y + 3 * (floor(x / 7) % 2)) % 6",
    },
    expression = "(abs(x % 7 - 3) < 4 - abs(dy - 2)*1.334)\z
                  *\z
                  spot_noise{\z
                    x=x,\z
                    y=y,\z
                    density_expression=0.01,\z
                    spot_quantity_expression=2000,\z
                    spot_radius_expression = 20,\z
                    spot_favorability_expression=heliara_dust*5+heliara_weathered_siliceous_crust/3-heliara_rusty_sand*2,\z
                    seed0=map_seed,\z
                    seed1=305,\z
                    basement_value=-1000,\z
                    maximum_spot_basement_radius=40\z
                  } * max(0, 0.6-voronoi_spot_noise{x=x,y=y,seed0=map_seed,seed1=306,grid_size=32,distance_type=2})"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_coal_probability",
    expression = "spot_noise{\z
                    x=x,\z
                    y=y,\z
                    density_expression=0.005,\z
                    spot_quantity_expression=2000,\z
                    spot_radius_expression = 20,\z
                    spot_favorability_expression=heliara_dust*5-heliara_weathered_siliceous_crust*2-heliara_rusty_sand,\z
                    seed0=map_seed,\z
                    seed1=306,\z
                    basement_value=-1000,\z
                    maximum_spot_basement_radius=40\z
                  } * random_penalty_between(0.1, 0.4, 307)"
  },
  {
    type = "noise-expression",
    name = "heliara_silcrete_probability",
    expression = "spot_noise{\z
                    x=x,\z
                    y=y,\z
                    density_expression=0.01,\z
                    spot_quantity_expression=20000,\z
                    spot_radius_expression=300,\z
                    spot_favorability_expression=heliara_silcrete_crust * 20 + heliara_clay_shale * 4 - (heliara_rusty_sand + heliara_ferocalcite_crust + heliara_iron_carbon_slag),\z
                    seed0=map_seed,\z
                    seed1=308,\z
                    basement_value=0,\z
                    maximum_spot_basement_radius=600\z
                  } * 20 * cut(heliara_silcrete_crust - heliara_rusty_sand, 0.6) * cut(heliara_silcrete_crust - heliara_clay_shale * 0.95, 0.15)"
  },

  -- decals
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_1",
    expression = "cut(heliara_rusty_sand - heliara_clay_shale, 0.4) * 0.02"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_2",
    expression = "cut(heliara_dust - heliara_weathered_siliceous_crust, 0.4) * 0.02"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_3",
    expression = "(heliara_iron_carbon_slag - heliara_dust - heliara_rusty_sand - heliara_silcrete_crust - heliara_ferocalcite_crust - heliara_weathered_siliceous_crust) * 0.1"
  },
  {
    type = "noise-expression",
    name = "heliara_waves_decal",
    expression = "cut(heliara_rusty_sand + heliara_dust - heliara_weathered_siliceous_crust - heliara_silcrete_crust - heliara_ferocalcite_crust - heliara_clay_shale, 0.65) * 0.0005"
  },
  {
    type = "noise-expression",
    name = "clay_cracks",
    expression = "cut(heliara_clay_shale - heliara_rusty_sand, 0.6) * 0.05"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_small",
    expression = "cut(heliara_ferocalcite_crust, 0.2) * 0.002"
  },
  {
    type = "noise-expression",
    name = "heliara_huge_cracks",
    expression = "max(0, 0.05 - heliara_ferocalcite_crust - heliara_clay_shale) * 0.05"
  },
  {
    type = "noise-expression",
    name = "heliara_cracks",
    expression = "max(0, 0.05 - heliara_ferocalcite_crust - heliara_clay_shale) * 0.05"
  },
  {
    type = "noise-expression",
    name = "heliara_mud_decal",
    expression = "max(0, heliara_ferocalcite_crust - heliara_dust - heliara_weathered_siliceous_crust - heliara_silcrete_crust - heliara_clay_shale) * 0.0025"
  },
  {
    type = "noise-expression",
    name = "heliara_light_mud_decal",
    expression = "clamp(heliara_clay_shale*2 - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - heliara_ferocalcite_crust - heliara_dust - 0.2, 0, 0.2) * 0.01"
  },
  {
    type = "noise-expression",
    name = "heliara_red_desert_decal_gray",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust - heliara_rusty_sand + heliara_silcrete_crust + heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(20) / 5, 0, 0.2) * 0.00025"
  },
  {
    type = "noise-expression",
    name = "heliara_red_desert_decal_blue",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust + heliara_dust - 0.2 + noise_layer_noise(21) / 5, 0, 0.2) * 0.001"
  },
  {
    type = "noise-expression",
    name = "heliara_red_desert_decal_yellow",
    expression = "clamp(heliara_clay_shale*2 + heliara_ferocalcite_crust - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(22) / 5, 0, 0.2) * 0.005"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_gray",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust - heliara_rusty_sand + heliara_silcrete_crust + heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(23) / 5, 0, 0.2) * 0.00025"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_blue",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust + heliara_dust - 0.2 + noise_layer_noise(24) / 5, 0, 0.2) * 0.001"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_red",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust + heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(24) / 5, 0, 0.2) * 0.001"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_yellow",
    expression = "clamp(heliara_clay_shale*2 + heliara_ferocalcite_crust - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(25) / 5, 0, 0.2) * 0.005"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_dune_blue",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust - heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust + heliara_dust - 0.2 + noise_layer_noise(26) / 5, 0, 0.2) * 0.004"
  },
  {
    type = "noise-expression",
    name = "heliara_sand_dune_red",
    expression = "clamp(-heliara_clay_shale - heliara_ferocalcite_crust + heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - heliara_dust - 0.2 + noise_layer_noise(27) / 5, 0, 0.2) * 0.004"
  },
})
