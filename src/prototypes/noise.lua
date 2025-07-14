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
    type = "noise-expression",
    name = "s1",
    expression = "control:big_noise:size"
  },
  {
    type = "noise-expression",
    name = "f1",
    expression = "control:big_noise:frequency"
  },
  {
    type = "noise-expression",
    name = "ss1",
    expression = "control:big_noise_details:size"
  },
  {
    type = "noise-expression",
    name = "ff1",
    expression = "control:big_noise_details:frequency"
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
    name = "global_cut_left",
    expression = "control:global_cut:size / 6"
  },
  {
    type = "noise-expression",
    name = "global_cut_right",
    expression = "control:global_cut:frequency / 6"
  },
  {
    type = "autoplace-control",
    name = "big_noise",
    order = "aa1",
    category = "terrain"
  },
  {
    type = "autoplace-control",
    name = "big_noise_details",
    order = "aa2",
    category = "terrain"
  },
  {
    type = "autoplace-control",
    name = "small_noise_1",
    order = "aa3",
    category = "terrain"
  },
  {
    type = "autoplace-control",
    name = "small_noise_2",
    order = "aa3",
    category = "terrain"
  },
  {
    type = "autoplace-control",
    name = "global_cut",
    order = "aa4",
    category = "terrain"
  },

  -- elevation
  {
    type = "noise-expression",
    name = "elevation_heliara",
    expression = "(\z
        clamp(\z
            multioctave_normal(503, 1/128 * f1, 1 + ss1 * 6, ff1 / 6) * s1\z
             + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 504, input_scale = small_noise_1_freq, output_scale = small_noise_1_size}\z
             + basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 505, input_scale = small_noise_2_freq, output_scale = small_noise_2_size},\z
            global_cut_left,\z
            global_cut_right\z
        ) - global_cut_left)\z
    /(global_cut_right - global_cut_left)",
    local_expressions = {
        e1 = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.5,\z
                                    seed0 = map_seed,\z
                                    seed1 = 701,\z
                                    octaves = 4,\z
                                    input_scale = 1}",
        e2 = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.5,\z
                                    seed0 = map_seed,\z
                                    seed1 = 701,\z
                                    octaves = 4,\z
                                    input_scale = 1 / 150,\z
                                    output_scale = 0.5}",
        e = "e1",
    }
  },
  {
    type = "noise-expression",
    name = "elevation_heliara-ttt",
    --intended_property = "elevation", --removed as an option as it is the default
    expression = "min(1, abs(wlc_elevation/max_elevation))",
    local_expressions =
    {
      -- comparing to navius: we have here scaled to 0-1 values, not just random elevations
      wlc_elevation = "(0.1 + 0.5 * heliara_bridges) + 0.25 * abs(heliara_detail) + 3 * heliara_macro",
      max_elevation = "3.85"    -- wlc_elevation with all variables = max possible value
    }
  },
  {
    type = "noise-expression",
    name = "heliara_detail", -- the small scale details with variable persistance for a mix of smooth and jagged coastline
    expression = "variable_persistence_multioctave_noise{x = x,\z
                                                         y = y,\z
                                                         seed0 = map_seed,\z
                                                         seed1 = 601,\z
                                                         input_scale = heliara_segmentation_multiplier / 14,\z
                                                         output_scale = 0.03,\z
                                                         offset_x = 10000 / heliara_segmentation_multiplier,\z
                                                         octaves = 5,\z
                                                         persistence = heliara_persistance}"
  },
  {
    type = "noise-expression",
    name = "heliara_bridges", -- large scale land-bridges for land connectivity
    expression = "1 - (0.1 * heliara_bridge_billows + 0.9 * max(0, -0.1 + heliara_bridge_billows))"
  },
  {
    type = "noise-expression",
    name = "heliara_bridge_billows", -- original: large scale land-bridges for land connectivity, probably we could make it vise versa to make canions?
    expression = "min(1, abs(multioctave_noise{x = x,\z
                                        y = y,\z
                                        persistence = 0.5,\z
                                        seed0 = map_seed,\z
                                        seed1 = 701,\z
                                        octaves = 4,\z
                                        input_scale = 1 / 150}))"
  },
  {
    type = "noise-expression",
    name = "heliara_segmentation_multiplier",
    expression = "16"
  },
  {
    type = "noise-expression",
    name = "heliara_persistance",
    expression = "clamp(amplitude_corrected_multioctave_noise{x = x,\z
                                                              y = y,\z
                                                              seed0 = map_seed,\z
                                                              seed1 = 500,\z
                                                              octaves = 5,\z
                                                              input_scale = heliara_segmentation_multiplier / 2,\z
                                                              offset_x = 10000 / heliara_segmentation_multiplier,\z
                                                              persistence = 0.7,\z
                                                              amplitude = 0.5} + 0.55,\z
                      0.5, 0.65)"
  },
  {
    type = "noise-expression",
    name = "heliara_macro",
    expression = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.6,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1000,\z
                                    octaves = 2,\z
                                    input_scale = heliara_segmentation_multiplier / 1600}\z
                  * max(0, multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.6,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1100,\z
                                    octaves = 1,\z
                                    input_scale = heliara_segmentation_multiplier / 1600})",
  },
  
  -- moisture
  {
    type = "noise-expression",
    name = "moisture_heliara",
    expression = "min(1,\z
        abs(multioctave_noise {\z
            x = x,\z
            y = y,\z
            seed0 = map_seed,\z
            seed1 = 503,\z
            input_scale = 1 / 32,\z
            octaves = 5,\z
            persistence = 0.25,\z
            output_scale = 0.9\z
            }\z
        )\z
    )"
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
