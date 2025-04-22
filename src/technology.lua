data:extend({
    {
        type = "technology",
        name = "planet-discovery-heliara",
        icons = util.technology_icon_constant_planet("__heliara__/graphics/icons/heliara.png"),
        icon_size = 2048,
        essential = true,
        effects = {
            {
                type = "unlock-space-location",
                space_location = "heliara",
                use_icon_overlay_constant = true
            },
        },
        prerequisites = { "planet-discovery-vulcanus", "planet-discovery-fulgora", "planet-discovery-aquilo" },
        unit = {
            count = 4000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "production-science-pack", 1 },
                { "utility-science-pack", 1 },
                { "space-science-pack", 1 },
                { "metallurgic-science-pack", 1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "fullerene_extraction_bath",
        icon = "__heliara__/graphics/icons/fullerene.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_extraction_bath",
            },
        },
        prerequisites = { "planet-discovery-heliara" },
        research_trigger = {
            type = "mine-entity",
            entity = "shungite"
        },
    },
    {
        type = "technology",
        name = "fullerene_solar_panel",
        icon = "__heliara__/graphics/icons/fullerene.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_solar_panel",
            },
        },
        prerequisites = { "fullerene_extraction_bath" },
        research_trigger = {
            type = "mine-entity",
            entity = "huge_fullerene_rock"
        },
    },
    {
        type = "technology",
        name = "fullerene",
        icon = "__heliara__/graphics/icons/fullerene.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene",
            },
        },
        prerequisites = { "fullerene_extraction_bath", "fullerene_solar_panel"},
        research_trigger = {
            type = "build-entity",
            entity = "fullerene_extraction_bath"
        },
    },
    {
        type = "technology",
        name = "graphite",
        icon = "__heliara__/graphics/icons/graphite.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite",
            },
        },
        prerequisites = { "fullerene" },
        research_trigger = {
            type = "craft-item",
            item = "fullerene"
        },
    },
    {
        type = "technology",
        name = "fullerene-science-pack",
        icon = "__heliara__/graphics/icons/fullerene-science-pack.png",
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene-science-pack",
            },
        },
        prerequisites = { "graphite", "fullerene" },
        research_trigger = {
            type = "craft-item",
            item = "graphite"
        },
    },
    {
        type = "technology",
        name = "fullerene_lab",
        icon = "__heliara__/graphics/icons/fullerene.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_lab",
            },
        },
        prerequisites = { "fullerene-science-pack"},
        research_trigger = {
            type = "craft-item",
            item = "fullerene-science-pack"
        },
    },
    {
        type = "technology",
        name = "silicon_substrate",
        icon = "__heliara__/graphics/icons/silicon_substrate.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "silicon_substrate",
            },
        },
        prerequisites = { "fullerene_lab" },
        unit = {
            count = 200,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "silicon_substrate",
        icon = "__heliara__/graphics/icons/silicon_substrate.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "silicon_substrate",
            },
        },
        prerequisites = { "fullerene_lab" },
        unit = {
            count = 50,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "graphite_circuit",
        icon = "__heliara__/graphics/icons/graphite_circuit.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite_circuit",
            },
        },
        prerequisites = { "silicon_substrate" },
        unit = {
            count = 50,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "graphite-automation-science-pack",
        icon = "__heliara__/graphics/icons/graphite_circuit.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite-automation-science-pack",
            },
        },
        prerequisites = { "graphite_circuit" },
        unit = {
            count = 50,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "graphite-automation-science-pack",
        icon = "__base__/graphics/icons/automation-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite-automation-science-pack",
            },
        },
        prerequisites = { "graphite_circuit" },
        unit = {
            count = 50,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "graphite-logistic-science-pack",
        icon = "__base__/graphics/icons/logistic-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite-automation-science-pack",
            },
        },
        prerequisites = { "graphite_circuit" },
        unit = {
            count = 50,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "heliara_assembling_machine",
        icon = "__heliara__/graphics/icons/heliara_assembling_machine.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "heliara_assembling_machine",
            },
        },
        prerequisites = { "graphite-automation-science-pack" },
        unit = {
            count = 100,
            ingredients = {
                { "automation-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "solar_refractor",
        icon = "__heliara__/graphics/icons/solar_refractor.png",
        icon_size = 1024,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "solar_refractor",
            },
            {
                type = "unlock-recipe",
                recipe = "solar_refractor_silo",
            },
        },
        prerequisites = { "graphite-automation-science-pack", "graphite-logistic-science-pack" },
        unit = {
            count = 400,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },

})
