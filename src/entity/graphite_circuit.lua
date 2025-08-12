require("common")

local _name = "graphite_circuit"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 64,
        },
        recipe = {
            ingredients = {
                silicon_substrate = 2,
                graphite = 2,
            },
            energy_required = 5,
            category = "crafting",
            enabled = false,
        },
        item = {
            order = "b[circuits]-d[graphite-circuit]",
            color_hint = { text = "T" },
            subgroup = "intermediate-product",

            stack_size = 200,
            ingredient_to_weight_coefficient = 0.2,
        }
    }
}