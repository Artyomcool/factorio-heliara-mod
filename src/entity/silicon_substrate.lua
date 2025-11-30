require("common")

local _name = "silicon_substrate"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
        },
        recipe = {
            ingredients = {
                fullerene = 4,
                stone = 5,
                ["iron-plate"] = 2
            },
            fluid_ingredients = {
                water = 200,
            },
            results = {
                shungite = 4,
                stone = 3,
                silicon_substrate = 1,
            },
            energy_required = 1,
            category = "fullerene-chemistry",
            enabled = false,
            allow_productivity = true,
        },
        item = {
            order = "a-b-c",
            color_hint = { text = "T" },
            subgroup = "raw-material",

            stack_size = 200,
            weight = 0.5 * kg
        }
    },
    {
        recipe = {
            name = "advanced_silicon_substrate",
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
            ingredients = {
                fullerene = 16,
                brick_dust = 40,
                ["iron-plate"] = 1,
                graphite = 8,
            },
            fluid_ingredients = {
                water = 200,
            },
            results = {
                silicon_substrate = 4,
            },
            energy_required = 10,
            category = "electromagnetics",
            enabled = false,
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    }
}