require("common")

local _name = "graphite"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
            order = "h[heliara]-e[graphite]-a[base]",
        },
        recipe = {
            subgroup = "heliara-materials",
            ingredients = {
                fullerene = 6,
                carbon = 6
            },
            fluid_ingredients = {
                water = 50,
            },
            results = {
                graphite = 6
            },
            energy_required = 1,
            category = "fullerene-chemistry",
            enabled = false,
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
        item = {
            order = "a-b-c",
            color_hint = { text = "T" },
            subgroup = "heliara-materials",

            stack_size = 400,
            weight = 0.25 * kg,
        },
    },
    {
        recipe = {
            name = _name .. "-from-shungite",
            icon = "__heliara__/graphics/icons/" .. _name .. "_from_shungite.png",
            icon_size = 64,
            subgroup = "heliara-materials",
            order = "h[heliara]-e[graphite]-b[from-shungite]",
            ingredients = {
                shungite = 100,
            },
            fluid_ingredients = {
                water = 200,
            },
            results = {
                graphite = 30,
                ["iron-ore"] = 5,
            },
            energy_required = 5,
            category = "fullerene-chemistry",
            enabled = false,
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    },
    {
        recipe = {
            name = _name .. "-from-carbon",
            icon = "__heliara__/graphics/icons/" .. _name .. "_from_carbon.png",
            icon_size = 64,
            subgroup = "heliara-materials",
            order = "h[heliara]-e[graphite]-c[from-carbon]",
            ingredients = {
                carbon = 100,
            },
            results = {
                graphite = 20,
                carbon = 20,
            },
            energy_required = 10,
            category = "chemistry",
            enabled = false,
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    },
}
