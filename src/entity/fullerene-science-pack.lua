require("common")

local _name = "fullerene-science-pack"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 64,
        },
        recipe = {
            subgroup = "heliara-science-pack",
            order = "a[fullerene-science-pack]",
            ingredients = {
                carbon = 4,
                shungite = 4,
                fullerene = 8,
                graphite = 8,
            },
            energy_required = 15,
            category = "crafting",
            enabled = false,
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
        raw = {
            {
                type = "tool",
                name = "fullerene-science-pack",
                localised_description = {"item-description.science-pack"},
                icon = "__heliara__/graphics/icons/" .. _name .. ".png",
                icon_size = 64,
                subgroup = "heliara-science-pack",
                color_hint = { text = "F" },
                order = "a[fullerene-science-pack]",
                stack_size = 200,
                default_import_location = "heliara",
                weight = 1*kg,
                durability = 1,
            },
        },
    }
}
