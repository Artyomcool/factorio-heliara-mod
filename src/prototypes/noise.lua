data:extend({
  -- elevation
  {
    type = "noise-expression",
    name = "elevation_heliara",
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
    expression = "1.5"
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
    expression = "clamp(\z
        (multioctave_noise {\z
            x = x,\z
            y = y,\z
            seed0 = map_seed,\z
            seed1 = 503,\z
            input_scale = 1 / 128,\z
            octaves = 5,\z
            persistence = 0.5,\z
            output_scale = 1\z
            } + 1\z
        ) / 2,\z
        0,\z
        1\z
    )"
  }
})