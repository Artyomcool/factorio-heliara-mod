require("common")

return {
    {
        recipe = {
            name = "graphite-automation-science-pack",
            icon = "__base__/graphics/icons/automation-science-pack.png",
            ingredients = {
                ["iron-plate"] = 1,
                ["iron-gear-wheel"] = 2,
                ["graphite"] = 2,
            },
            results = {
                ["automation-science-pack"] = 2,
            },
            energy_required = 1,
            category = "crafting",
            enabled = false,
            surface_conditions = {
                { property = "magnetic-field", min = 30, max = 60, },
                { property = "pressure", min = 3000, max = 4000, },
                { property = "gravity", min = 5, max = 7, },
            }
        }
    },
    {
        recipe = {
            name = "graphite-logistic-science-pack",
            icon = "__base__/graphics/icons/logistic-science-pack.png",
            ingredients = {
                ["burner-inserter"] = 1,
                ["transport-belt"] = 1,
                ["graphite_circuit"] = 2,
            },
            results = {
                ["logistic-science-pack"] = 2,
            },
            energy_required = 1,
            category = "crafting",
            enabled = false,
            surface_conditions = {
                { property = "magnetic-field", min = 30, max = 60, },
                { property = "pressure", min = 3000, max = 4000, },
                { property = "gravity", min = 5, max = 7, },
            }
        }
    },
    {
        recipe = {
            name = "graphite-chemical-science-pack",
            icon = "__base__/graphics/icons/chemical-science-pack.png",
            ingredients = {
                ["fullerene"] = 4,
                ["calcite"] = 2,
                ["engine-unit"] = 3,
                ["graphite_circuit"] = 12,
                ["graphite"] = 3,
            },
            fluid_ingredients = {
                ["water"] = 50,
            },
            results = {
                ["chemical-science-pack"] = 2,
            },
            energy_required = 1,
            category = "fullerene_craft",
            enabled = false,
            surface_conditions = {
                { property = "magnetic-field", min = 30, max = 60, },
                { property = "pressure", min = 3000, max = 4000, },
                { property = "gravity", min = 5, max = 7, },
            }
        }
    },
    {
        recipe = {
            name = "graphite-production-science-pack",
            icon = "__base__/graphics/icons/production-science-pack.png",
            ingredients = {
                ["rail"] = 35,
                ["steel-plate"] = 15,
                ["dryer"] = 5,
                ["concrete"] = 25,
                ["graphite_circuit"] = 22,
                ["graphite"] = 3,
            },
            results = {
                ["production-science-pack"] = 3,
            },
            energy_required = 1,
            category = "fullerene_craft",
            enabled = false,
            surface_conditions = {
                { property = "magnetic-field", min = 30, max = 60, },
                { property = "pressure", min = 3000, max = 4000, },
                { property = "gravity", min = 5, max = 7, },
            }
        }
    },
}