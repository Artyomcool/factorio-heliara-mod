require("common")

return {
    {
        recipe = {
            name = "fullerene_solid_fuel",
            icons = {
                {
                    icon = "__base__/graphics/icons/solid-fuel.png",
                    icon_size = 64,
                },
                {
                    icon = "__heliara__/graphics/icons/fullerene.png",
                    icon_size = 128,
                    scale = 0.18,
                    shift = { -8, 8 },
                },
            },
            icon_size = 64,
            ingredients = {
                carbon = 10,
                graphite = 8,
                fullerene = 2,
            },
            fluid_ingredients = {
                water = 50,
            },
            results = {
                ["solid-fuel"] = 1,
            },
            energy_required = 5,
            enabled = false,
            main_product = "solid-fuel",
            subgroup = "heliara-materials",
            order = "h[heliara]-g[solid-fuel]-a[from-fullerene]",
            category = "fullerene-chemistry",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    },
    {
        recipe = {
            name = "fullerene_rocket_fuel",
            icons = {
                {
                    icon = "__base__/graphics/icons/rocket-fuel.png",
                    icon_size = 64,
                },
                {
                    icon = "__heliara__/graphics/icons/fullerene.png",
                    icon_size = 128,
                    scale = 0.28,
                    shift = { -10, -10 },
                },
            },
            icon_size = 64,
            ingredients = {
                carbon = 20,
                fullerene = 2,
                ["solid-fuel"] = 14,
                ["iron-plate"] = 1,
            },
            fluid_ingredients = {
                steam = 500,
            },
            results = {
                ["rocket-fuel"] = 1,
                ["iron-ore"] = 1,
            },
            energy_required = 15,
            enabled = false,
            main_product = "rocket-fuel",
            subgroup = "heliara-materials",
            order = "h[heliara]-h[rocket-fuel]-a[from-fullerene]",
            category = "fullerene_craft",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    },
}
