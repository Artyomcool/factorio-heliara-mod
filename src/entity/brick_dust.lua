require("common")

local _name = "brick_dust"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 2,
                ["stone"] = 1
            },
            results = {
                [_name] = 16,
            },
            energy_required = 0.5,
            category = "fullerene_craft",
            enabled = false,
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
    },
    {
        recipe = {
            name = "shungite_from_brick_dust",
            icon = "__heliara__/graphics/icons/default.png",
            ingredients = {
                [_name] = 400,
                coal = 2,
                ["iron-ore"] = 1,
                calcite = 1
            },
            fluid_ingredients = {
                water = 20,
            },
            results = {
                shungite = 4,
            },
            category = "fullerene_craft",
            energy_required = 2,
            enabled = false,
        },
    },
}