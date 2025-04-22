local _name = "fullerene"

data:extend({
    {
        type = "fuel-category",
        name = "solar_fuel"
    }
})

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
        },
        recipe = {
            ingredients = {
                shungite = 100,
            },
            fluid_ingredients = {
                water = 200,
            },
            results = {
                shungite = 20,
                carbon = 10,
                fullerene = 7,
                ["iron-ore"] = 5,
            },
            energy_required = 5,
            category = "fullerene-chemistry",
            enabled = false
        },
        item = {
            order = "a-b-c",
            --subgroup = "heliara",
            color_hint = { text = "T" },
            fuel_value = "300kJ",
            fuel_category = "solar_fuel",
            subgroup = "raw-material",

            stack_size = 400,
            weight = 0.25 * kg
        }
    }
}