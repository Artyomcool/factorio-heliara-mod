local _name = "graphite"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
        },
        recipe = {
            ingredients = {
                fullerene = 8,
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
        },
        item = {
            order = "a-b-c",
            color_hint = { text = "T" },
            subgroup = "raw-material",

            stack_size = 400,
            weight = 0.25 * kg,
        },
    },
    {
        recipe = {
            name = _name .. "-from-shungite",
            icon = "__heliara__/graphics/icons/" .. _name .. "_from_shungite.png",
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
            energy_required = 10,
            category = "fullerene-chemistry",
            enabled = false,
        },
    },
}