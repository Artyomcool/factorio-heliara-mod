require("common")

return {
    {
      item = {
          icon = "__heliara__/graphics/icons/fluorite.png",
          name = "fluorite",
          order = "a-b-c",
          color_hint = { text = "T" },
          subgroup = "raw-material",
          stack_size = 50,
          weight = 0.1 * kg
      },
      recipe = {
          icon = "__heliara__/graphics/icons/fluorite.png",
          name = "fluoroketone_from_fluorite",
          category = "cryogenics",
          subgroup = "raw-material",
          order = "f[fluorite]",
          enabled = false,
          ingredients =
          {
              fluorite = 1,
              carbon = 1,
              sulfur = 1,
              ["solid-fuel"] = 1,
              ["lithium"] = 1,
          },
          fluid_ingredients =
          {
              water = 50,
          },
          energy_required = 12,
          fluid_results =
          {
              ["fluoroketone-hot"] = 20
          },
          main_product = "fluoroketone-hot",
          auto_recycle = false,
          allow_productivity = true,
          allow_decomposition = false
      },
    },
    {
        recipe = {
            icon = "__heliara__/graphics/icons/default.png",
            name = "stone-asteroid-crushing",
            category = "crushing",
            subgroup="space-crushing",
            order = "f[stone-asteroid-crushing]",
            enabled = false,
            ingredients =
            {
                ["oxide-asteroid-chunk"] = 1,
                ["carbonic-asteroid-chunk"] = 1
            },
            energy_required = 10,
            results =
            {
                carbon = 1,
                sulfur = {1, 1, 0.25},
                stone = 5,
                fluorite = {1, 1, 0.01},
                ["oxide-asteroid-chunk"] = {1, 1, 0.01},
                ["carbonic-asteroid-chunk"] = {1, 1, 0.01},
            },
            main_product = "",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    },
    {
        recipe = {
            icon = "__heliara__/graphics/icons/default.png",
            name = "advanced-promethium-asteroid-crushing",
            category = "crushing",
            subgroup="space-crushing",
            order = "f[advanced-promethium-asteroid-crushing]",
            enabled = false,
            ingredients =
            {
                ["metallic-asteroid-chunk"] = 1,
                ["promethium-asteroid-chunk"] = 1
            },
            energy_required = 10,
            results = {
                ["iron-ore"] = 1,
                ["copper-ore"] = { 1, 1, 1 / 5 },
                ["lithium"] = { 1, 1, 1 / 25 },
                ["tungsten-ore"] = { 1, 1, 1 / 100 },
                ["holmium-ore"] = { 1, 1, 1 / 200 },
                ["uranium-ore"] = { 1, 1, 1 / 400 },
                ["metallic-asteroid-chunk"] = { 1, 1, 0.005 },
                ["promethium-asteroid-chunk"] = { 1, 1, 0.005 },
            },
            main_product = "",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    }
}




