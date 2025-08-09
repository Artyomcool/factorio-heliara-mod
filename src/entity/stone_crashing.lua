require("common")

local _name = "stone_crashing"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/default.png",
        },
        recipe = {
            name = "stone-asteroid-crushing",
            category = "crushing",
            subgroup="space-crushing",
            order = "f[stone-asteroid-crushing]",
            auto_recycle = false,
            enabled = false,
            ingredients =
            {
                ["oxide-asteroid-chunk"] = 1,
                ["carbonic-asteroid-chunk"] = 1
            },
            energy_required = 10,
            results =
            {
                calcite = 1,
                carbon = 3,
                stone = 5,
                ["oxide-asteroid-chunk"] = {1, 1, 0.01},
                ["carbonic-asteroid-chunk"] = {1, 1, 0.01},
            },
            main_product = "stone",
            allow_productivity = true,
            allow_decomposition = false
        },
    }
}




