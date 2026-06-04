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
  {
    type = "noise-expression",
    name = "heliara_brackish_vent_probability",
    expression = "clamp(spot_noise{\z
                    x=x,\z
                    y=y,\z
                    density_expression=0.1,\z
                    spot_quantity_expression=20000,\z
                    spot_radius_expression=10,\z
                    spot_favorability_expression=heliara_silcrete_crust * 4 + heliara_clay_shale * 20 - (heliara_rusty_sand + heliara_ferocalcite_crust + heliara_iron_carbon_slag),\z
                    seed0=map_seed,\z
                    seed1=309,\z
                    basement_value=0,\z
                    maximum_spot_basement_radius=20\z
                  }, 0, 0.05)\z
                    * cut(heliara_clay_shale - heliara_rusty_sand * 0.8, 0.6) * cut(heliara_clay_shale - heliara_silcrete_crust * 0.9, 0.15)"

  },

  -- decals
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_1",
    expression = "cut(heliara_rusty_sand - heliara_clay_shale, 0.35) * 0.015"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_2",
    expression = "cut(heliara_dust - heliara_weathered_siliceous_crust, 0.35) * 0.012"
  },
  {
    type = "noise-expression",
    name = "heliara_tiny_rock_3",
    expression = "max(0, heliara_iron_carbon_slag - heliara_dust - heliara_rusty_sand - heliara_silcrete_crust - heliara_ferocalcite_crust - heliara_weathered_siliceous_crust) * 0.04"
  },
  {
    type = "noise-expression",
    name = "heliara_waves_decal",
    expression = "cut(heliara_rusty_sand + heliara_dust - heliara_weathered_siliceous_crust - heliara_silcrete_crust - heliara_ferocalcite_crust - heliara_clay_shale, 0.55) * (0.0015 + max(0, noise_layer_noise(30)) * 0.001)"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_stain",
    expression = "cut(heliara_ferocalcite_crust - heliara_dust / 2, 0.2) * 0.01"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_small",
    expression = "cut(heliara_ferocalcite_crust - heliara_dust / 2, 0.2) * 0.03"
  },
  {
    type = "noise-expression",
    name = "heliara_huge_cracks",
    expression = "max(0, heliara_silcrete_crust + heliara_weathered_siliceous_crust - heliara_clay_shale - 0.85) * 0.0015"
  },
  {
    type = "noise-expression",
    name = "heliara_cracks",
    expression = "max(0, heliara_silcrete_crust + heliara_weathered_siliceous_crust - heliara_clay_shale - 0.6) * 0.003"
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
  {
    type = "noise-expression",
    name = "heliara_black_dust_stain",
    expression = "clamp(heliara_dust + heliara_iron_carbon_slag - heliara_rusty_sand - heliara_clay_shale - 1.0 + noise_layer_noise(31) / 5, 0, 0.25) * 0.0012"
  },
  {
    type = "noise-expression",
    name = "heliara_orange_oxidation_patch",
    expression = "clamp(heliara_rusty_sand + heliara_ferocalcite_crust - heliara_dust - heliara_silcrete_crust - 0.85 + noise_layer_noise(32) / 6, 0, 0.25) * 0.002"
  },
  {
    type = "noise-expression",
    name = "heliara_silcrete_fractures",
    expression = "clamp(heliara_silcrete_crust + heliara_weathered_siliceous_crust - heliara_rusty_sand - heliara_clay_shale - 0.95 + noise_layer_noise(33) / 8, 0, 0.25) * 0.001"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_slag_speckles",
    expression = "clamp(heliara_iron_carbon_slag - heliara_dust - heliara_rusty_sand - 0.45 + noise_layer_noise(34) / 5, 0, 0.25) * 0.006"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_slag_rust",
    expression = "clamp(heliara_iron_carbon_slag + heliara_ferocalcite_crust - heliara_clay_shale - 0.75 + noise_layer_noise(38) / 6, 0, 0.25) * 0.0025"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_slag_gloss",
    expression = "clamp(heliara_iron_carbon_slag - heliara_silcrete_crust - heliara_rusty_sand - 0.55 + noise_layer_noise(39) / 7, 0, 0.25) * 0.002"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_slag_scab",
    expression = "max(0, heliara_iron_carbon_slag - max(heliara_dust, heliara_rusty_sand, heliara_clay_shale, heliara_weathered_siliceous_crust, heliara_ferocalcite_crust, heliara_silcrete_crust) - 0.16) * clamp(0.7 + noise_layer_noise(40), 0, 1) * 0.05"
  },
  {
    type = "noise-expression",
    name = "heliara_carbon_slag_small_scab",
    expression = "max(0, heliara_iron_carbon_slag - max(heliara_dust, heliara_rusty_sand, heliara_clay_shale, heliara_weathered_siliceous_crust, heliara_ferocalcite_crust, heliara_silcrete_crust)) * clamp(1.05 - 3.2 * max(0, heliara_iron_carbon_slag - max(heliara_dust, heliara_rusty_sand, heliara_clay_shale, heliara_weathered_siliceous_crust, heliara_ferocalcite_crust, heliara_silcrete_crust)), 0.12, 1) * clamp(0.65 + noise_layer_noise(41), 0, 1) * 0.8"
  },
  {
    type = "noise-expression",
    name = "heliara_calcite_veins",
    expression = "clamp(heliara_ferocalcite_crust + heliara_clay_shale - heliara_dust - 0.65 + noise_layer_noise(35) / 7, 0, 0.25) * 0.002"
  },
  {
    type = "noise-expression",
    name = "heliara_dune_ridges",
    expression = "clamp(heliara_dust + heliara_rusty_sand - heliara_silcrete_crust - heliara_weathered_siliceous_crust - 0.8 + noise_layer_noise(36) / 7, 0, 0.25) * 0.0025"
  },
  {
    type = "noise-expression",
    name = "heliara_brackish_salt_ring",
    expression = "clamp(heliara_clay_shale + heliara_ferocalcite_crust - heliara_rusty_sand - 0.7 + noise_layer_noise(37) / 7, 0, 0.25) * 0.0015"
  },

  -- weathered siliceous crust decals — separate expressions per size for density tuning
  -- base: positive only where WSC dominates; multiplier controls density like other decals
  {
    type = "noise-expression",
    name = "heliara_wsc_decal_base",
    expression = "max(0, heliara_weathered_siliceous_crust - max(heliara_dust, heliara_rusty_sand, heliara_clay_shale, heliara_ferocalcite_crust, heliara_silcrete_crust, heliara_iron_carbon_slag)) * clamp(0.7 + noise_layer_noise(42), 0, 1)"
  },
  { type = "noise-expression", name = "heliara_wsc_decal_8x8", expression = "heliara_wsc_decal_base * 0.001" },
  { type = "noise-expression", name = "heliara_wsc_decal_4x4", expression = "heliara_wsc_decal_base * 0.003" },
  { type = "noise-expression", name = "heliara_wsc_decal_2x2", expression = "heliara_wsc_decal_base * 0.030" },
  { type = "noise-expression", name = "heliara_wsc_decal_2x1", expression = "heliara_wsc_decal_base * 0.012" },
  { type = "noise-expression", name = "heliara_wsc_decal_1x1", expression = "heliara_wsc_decal_base * 0.060" },
})
