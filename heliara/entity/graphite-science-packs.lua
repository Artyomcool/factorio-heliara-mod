require("common.common")

local surface_conditions = {
    { property = "magnetic-field", min = 50, max = 60, },
    { property = "pressure", min = 2000, max = 3000, },
    { property = "gravity", min = 1, max = 3, },
}

local function recipe(recipe)
    recipe.energy_required = 1
    recipe.enabled = false
    recipe.surface_conditions = surface_conditions
    recipe.auto_recycle = false
    recipe.allow_productivity = true
    recipe.allow_decomposition = false

    return { recipe = recipe }
end

local function graphite_circuit_science_pack_icon(icon)
    return {
        {
            icon = icon,
            icon_size = 64,
        },
        {
            icon = "__heliara__/graphics/icons/graphite_circuit.png",
            icon_size = 64,
            scale = 0.30,
            shift = { -10, 10 },
        },
    }
end

return {
    recipe({
        name = "graphite-automation-science-pack",
        icons = graphite_circuit_science_pack_icon("__base__/graphics/icons/automation-science-pack.png"),
        icon_size = 64,
        subgroup = "heliara-science-pack",
        order = "b[graphite-automation-science-pack]",
        ingredients = {
            ["iron-plate"] = 1,
            ["iron-gear-wheel"] = 2,
            ["graphite"] = 2,
        },
        results = {
            ["automation-science-pack"] = 2,
        },
        category = "crafting",
    }),
    recipe({
        name = "graphite-logistic-science-pack",
        icons = graphite_circuit_science_pack_icon("__base__/graphics/icons/logistic-science-pack.png"),
        icon_size = 64,
        subgroup = "heliara-science-pack",
        order = "c[graphite-logistic-science-pack]",
        ingredients = {
            ["burner-inserter"] = 1,
            ["transport-belt"] = 1,
            ["graphite_circuit"] = 2,
        },
        results = {
            ["logistic-science-pack"] = 2,
        },
        category = "crafting",
    }),
    recipe({
        name = "graphite-chemical-science-pack",
        icons = graphite_circuit_science_pack_icon("__base__/graphics/icons/chemical-science-pack.png"),
        icon_size = 64,
        subgroup = "heliara-science-pack",
        order = "d[graphite-chemical-science-pack]",
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
        category = "fullerene_craft",
    }),
    recipe({
        name = "graphite-production-science-pack",
        icons = graphite_circuit_science_pack_icon("__base__/graphics/icons/production-science-pack.png"),
        icon_size = 64,
        subgroup = "heliara-science-pack",
        order = "e[graphite-production-science-pack]",
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
        category = "fullerene_craft",
    }),
}
