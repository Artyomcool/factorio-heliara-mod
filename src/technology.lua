local planet = {
    type = "technology",
    name = "planet-discovery-heliara",
    icons = util.technology_icon_constant_planet("__heliara__/graphics/icons/heliara.png"),
    essential = true,
    effects = {
        {
            type = "unlock-space-location",
            space_location = "heliara",
            use_icon_overlay_constant = true
        },
    },
    prerequisites = { "planet-discovery-vulcanus", "planet-discovery-fulgora" },
    unit = {
        count = 2000,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 1 },
            { "space-science-pack", 1 },
            { "metallurgic-science-pack", 1 },
            { "electromagnetic-science-pack", 1 },
        },
        time = 60
    }
}

local planet_navigation =
{
    type = "technology",
    name = "heliara_navigation",
    icons = util.technology_icon_constant_range("__heliara__/graphics/icons/heliara.png"),
    essential = true,
    effects = {
        {
            type = "nothing",
        },
    },
    prerequisites = { "steam_cargo", "cryogenic-science-pack" },
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
            { "fullerene-science-pack", 1 },
        },
        time = 120
    }
}

planet.icons[1].icon_size = 512
planet_navigation.icons[1].icon_size = 512

data:extend({
    planet,
    {
        type = "technology",
        name = "fullerene_extraction_bath",
        icon = "__heliara__/graphics/icons/fullerene_extraction_bath.png",
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
        icon = "__heliara__/graphics/icons/fullerene_solar_panel.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_solar_panel",
            },
            {
                type = "unlock-recipe",
                recipe = "wireless_pole",
            },
        },
        prerequisites = { "planet-discovery-heliara" },
        research_trigger = {
            type = "mine-entity",
            entity = "huge_fullerene_rock"
        },
    },
    {
        type = "technology",
        name = "dryer",
        icon = "__base__/graphics/icons/boiler.png",    -- fixme
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "dryer",
            },
            {
                type = "unlock-recipe",
                recipe = "water-from-concrete",
            },
        },
        prerequisites = { "planet-discovery-heliara" },
        research_trigger = {
            type = "mine-entity",
            entity = "silcrete"
        },
    },
    {
        type = "technology",
        name = "carbon-electrolitic-processing",
        icon = "__heliara__/graphics/icons/shungite.png",
        icon_size = 500,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene",
            },
            {
                type = "unlock-recipe",
                recipe = "graphite",
            },
            {
                type = "unlock-recipe",
                recipe = "fullerene-science-pack",
            },
        },
        prerequisites = { "fullerene_extraction_bath", "fullerene_solar_panel" },
        research_trigger = {
            type = "build-entity",
            entity = "fullerene_extraction_bath"
        },
    },
    {
        type = "technology",
        name = "fullerene_lab",
        icon = "__heliara__/graphics/icons/fullerene_lab.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_lab",
            },
        },
        prerequisites = { "carbon-electrolitic-processing" },
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
            count = 5,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "silcrete",
        icon = "__heliara__/graphics/icons/silcrete.png",
        icon_size = 128,
        essential = false,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "silcrete",
            },
        },
        prerequisites = { "fullerene_lab", "dryer" },
        unit = {
            count = 15,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 45
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
            count = 5,
            ingredients = {
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "fast_burner_inserter",
        icon = "__base__/graphics/icons/burner-inserter.png",
        essential = false,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fast_burner_inserter",
            },
        },
        prerequisites = { "graphite_circuit", "logistic-science-pack" },
        unit = {
            count = 200,
            ingredients = {
                { "logistic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "long_burner_inserter",
        icon = "__base__/graphics/icons/burner-inserter.png",
        essential = false,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "long_burner_inserter",
            },
        },
        prerequisites = { "fast_burner_inserter" },
        unit = {
            count = 200,
            ingredients = {
                { "logistic-science-pack", 1 },
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
            count = 10,
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
                recipe = "graphite-logistic-science-pack",
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
        name = "graphite-chemical-science-pack",
        icon = "__base__/graphics/icons/chemical-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite-chemical-science-pack",
            },
        },
        prerequisites = { "graphite-automation-science-pack", "graphite-logistic-science-pack", "silcrete" },
        unit = {
            count = 150,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
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
            count = 20,
            ingredients = {
                { "automation-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "graphite-production-science-pack",
        icon = "__base__/graphics/icons/production-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "graphite-production-science-pack",
            },
        },
        prerequisites = { "heliara_assembling_machine", "graphite-chemical-science-pack" },
        unit = {
            count = 200,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "osmosis_pipejack",
        icon = "__heliara__/graphics/icons/osmosis_filter.png",
        icon_size = 64,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "osmosis_pipejack",
            },
            {
                type = "unlock-recipe",
                recipe = "osmosis_filter",
            },
        },
        prerequisites = { "graphite-production-science-pack" },
        unit = {
            count = 200,
            ingredients = {
                { "automation-science-pack", 1 },
                { "production-science-pack", 1 },
                { "chemical-science-pack", 1 },
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
        prerequisites = { "graphite-automation-science-pack", "graphite-logistic-science-pack", "silcrete" },
        unit = {
            count = 800,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "advanced-shungite",
        icon = "__heliara__/graphics/icons/fullerene_from_shungite.png",
        icon_size = 500,
        essential = false,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene-from-shungite",
            },
            {
                type = "unlock-recipe",
                recipe = "graphite-from-shungite",
            },
            {
                type = "unlock-recipe",
                recipe = "carbon-from-shungite",
            },
        },
        prerequisites = { "graphite-chemical-science-pack" },
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
    {
        type = "technology",
        name = "advanced-character-distance",
        icon = "__core__/graphics/icons/entity/character.png",
        essential = false,
        upgrade = true,
        max_level = 3,
        show_levels_info = true,
        effects = {
            {
                type = "character-build-distance",
                modifier = 1,
            },
            {
                type = "character-item-drop-distance",
                modifier = 1,
            },
            {
                type = "character-reach-distance",
                modifier = 1,
            },
            {
                type = "character-resource-reach-distance",
                modifier = 1,
            },
            {
                type = "character-item-pickup-distance",
                modifier = 1,
            },
            {
                type = "character-loot-pickup-distance",
                modifier = 1,
            },
        },
        prerequisites = { "graphite-logistic-science-pack" },
        unit = {
            count = 200,
            ingredients = {
                { "logistic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 120
        }
    },
    {
        type = "technology",
        name = "fullerene_rocket_fuel",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene_rocket_fuel",
            },
        },
        prerequisites = { "advanced-shungite" },
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
    {
        type = "technology",
        name = "steam_cargo",
        icon = "__heliara__/graphics/icons/solar_refractor_silo.png",
        icon_size = 128,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "steam_cargo",
            },
        },
        prerequisites = { "osmosis_pipejack", "fullerene_rocket_fuel", "solar_refractor" },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "production-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 60
        }
    },
    planet_navigation,
    {
        type = "technology",
        name = "advanced-fullerene",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 128,
        essential = false,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "fullerene-from-graphite",
            },
            {
                type = "unlock-recipe",
                recipe = "graphite-from-carbon",
            },
        },
        prerequisites = { "heliara_navigation", "advanced-shungite" },
        unit = {
            count = 8000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "production-science-pack", 1 },
                { "utility-science-pack", 1 },
                { "space-science-pack", 1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 120
        }
    },
    {
        type = "technology",
        name = "dyson_swarm",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 1024,
        essential = true,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "dyson_swarm_element",
            },
            {
                type = "unlock-recipe",
                recipe = "dyson_swarm_launcher",
            },
        },
        prerequisites = { "heliara_navigation" },
        unit = {
            count = 24000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "production-science-pack", 1 },
                { "utility-science-pack", 1 },
                { "space-science-pack", 1 },
                { "electromagnetic-science-pack", 1 },
                { "cryogenic-science-pack", 1 },
                { "fullerene-science-pack", 1 },
            },
            time = 120
        }
    },

})
