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
                fullerene = 10,
                stone = 5,
                ["iron-plate"] = 2
            },
            fluid_ingredients = {
                water = 200,
            },
            energy_required = 3,
            category = "fullerene-chemistry"
        },
        item = {
            order = "a-b-c",
            color_hint = { text = "T" },
            subgroup = "raw-material",

            stack_size = 200,
            weight = 0.5 * kg
        }
    }
}