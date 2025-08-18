local function map(list, func)
    local r = {}
    for _, v in ipairs(list) do
        table.insert(r, func(v))
    end
    return r
end

local function ingredients(...)
    return map({...}, function (v) return {v .. "-science-pack", 1} end)
end

local function unit(count, time, ...)
    return {
        count = count,
        time = time,
        ingredients = ingredients(...)
    }
end

local function recipes(...)
    return map({...}, function (v) return { type = "unlock-recipe", recipe = v} end )
end

local function productivity(change, ...)
    return map({...}, function (v) return { type = "change-recipe-productivity", recipe = v, change = change} end )
end

local planet = {
    type = "technology",
    name = "planet-discovery-heliara",
    icons = util.technology_icon_constant_planet("__heliara__/graphics/icons/heliara_tech.png"),
    essential = true,
    effects = {
        {
            type = "unlock-space-location",
            space_location = "heliara",
            use_icon_overlay_constant = true
        },
        {
            type = "unlock-space-location",
            space_location = "heliashade",
            use_icon_overlay_constant = true
        },
    },
    prerequisites = { "planet-discovery-vulcanus", "planet-discovery-fulgora" },
    unit = unit(2000, 60,
        "automation", 
        "logistic",
        "chemical",
        "production",
        "utility",
        "space",
        "metallurgic",
        "electromagnetic"
    ),
}

local planet_navigation = PlanetsLib.cargo_drops_technology_base("heliara", "__heliara__/graphics/icons/heliara_tech.png", 256)
planet_navigation.prerequisites = { "steam_cargo", "cryogenic-science-pack" }
planet_navigation.unit = unit(4000, 120,
    "automation",
    "logistic",
    "chemical",
    "production",
    "utility",
    "space",
    "metallurgic",
    "electromagnetic",
    "cryogenic",
    "fullerene"
)

data:extend({
    planet,
    {
        type = "technology",
        name = "fullerene_extraction_bath",
        icon = "__heliara__/graphics/icons/fullerene_extraction_bath.png",
        icon_size = 128,
        essential = true,
        effects = recipes("fullerene_extraction_bath"),
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
        effects = recipes("fullerene_solar_panel", "wireless_pole"),
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
        effects = recipes("dryer", "water-from-concrete"),
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
        effects = recipes("fullerene", "graphite", "fullerene-science-pack"),
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
        effects = recipes("fullerene_lab"),
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
        effects = recipes("silicon_substrate"),
        prerequisites = { "fullerene_lab" },
        unit = unit(5, 60, "fullerene"),
    },
    {
        type = "technology",
        name = "silcrete",
        icon = "__heliara__/graphics/icons/silcrete.png",
        icon_size = 128,
        essential = false,
        effects = recipes("silcrete"),
        prerequisites = { "fullerene_lab", "dryer" },
        unit = unit(15, 45, "fullerene"),
    },
    {
        type = "technology",
        name = "graphite_circuit",
        icon = "__heliara__/graphics/icons/graphite_circuit.png",
        icon_size = 64,
        essential = true,
        effects = recipes("graphite_circuit"),
        prerequisites = { "silicon_substrate" },
        unit = unit(5, 60, "fullerene"),
    },
    {
        type = "technology",
        name = "fast_burner_inserter",
        icon = "__base__/graphics/icons/burner-inserter.png",
        essential = false,
        effects = recipes("fast_burner_inserter"),
        prerequisites = { "graphite_circuit", "logistic-science-pack" },
        unit = unit(200, 60, "fullerene", "logistic"),
    },
    {
        type = "technology",
        name = "long_burner_inserter",
        icon = "__base__/graphics/icons/burner-inserter.png",
        essential = false,
        effects = recipes("long_burner_inserter"),
        prerequisites = { "fast_burner_inserter" },
        unit = unit(200, 60, "fullerene", "logistic"),
    },
    {
        type = "technology",
        name = "graphite-automation-science-pack",
        icon = "__base__/graphics/icons/automation-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = recipes("graphite-automation-science-pack"),
        prerequisites = { "graphite_circuit" },
        unit = unit(10, 60, "fullerene"),
    },
    {
        type = "technology",
        name = "graphite-logistic-science-pack",
        icon = "__base__/graphics/icons/logistic-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = recipes("graphite-logistic-science-pack"),
        prerequisites = { "graphite_circuit" },
        unit = unit(50, 60, "fullerene"),
    },
    {
        type = "technology",
        name = "graphite-chemical-science-pack",
        icon = "__base__/graphics/icons/chemical-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = recipes("graphite-chemical-science-pack"),
        prerequisites = { "graphite-automation-science-pack", "graphite-logistic-science-pack", "silcrete" },
        unit = unit(150, 60, "automation", "logistic", "fullerene"),
    },
    {
        type = "technology",
        name = "heliara_assembling_machine",
        icon = "__heliara__/graphics/icons/heliara_assembling_machine.png",
        icon_size = 64,
        essential = true,
        effects = recipes("heliara_assembling_machine"),
        prerequisites = { "graphite-automation-science-pack" },
        unit = unit(20, 60, "automation", "fullerene"),
    },
    {
        type = "technology",
        name = "graphite-production-science-pack",
        icon = "__base__/graphics/icons/production-science-pack.png",
        icon_size = 64,
        essential = true,
        effects = recipes("graphite-production-science-pack"),
        prerequisites = { "heliara_assembling_machine", "graphite-chemical-science-pack" },
        unit = unit(200, 60, "automation", "logistic", "chemical", "fullerene"),
    },
    {
        type = "technology",
        name = "effective_wireless_pole",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 64,
        essential = true,
        effects = recipes("effective_wireless_pole"),
        prerequisites = { "graphite-production-science-pack" },
        unit = unit(275, 60, "automation", "logistic", "production", "fullerene"),
    },
    {
        type = "technology",
        name = "osmosis_pipejack",
        icon = "__heliara__/graphics/icons/osmosis_filter.png",
        icon_size = 64,
        essential = true,
        effects = recipes("osmosis_pipejack", "osmosis_filter"),
        prerequisites = { "graphite-production-science-pack" },
        unit = unit(200, 60, "automation", "chemical", "production", "fullerene"),
    },
    {
        type = "technology",
        name = "solar_refractor",
        icon = "__heliara__/graphics/icons/solar_refractor.png",
        icon_size = 1024,
        essential = true,
        effects = recipes("solar_refractor", "solar_refractor_silo"),
        prerequisites = { "graphite-automation-science-pack", "graphite-logistic-science-pack", "silcrete" },
        unit = unit(300, 60, "automation", "logistic", "fullerene"),
    },
    {
        type = "technology",
        name = "advanced-shungite",
        icon = "__heliara__/graphics/icons/fullerene_from_shungite.png",
        icon_size = 500,
        essential = false,
        effects = recipes(
            "fullerene-from-shungite",
            "graphite-from-shungite",
            "carbon-from-shungite",
            "brick_dust",
            "shungite_from_brick_dust"
        ),
        prerequisites = { "graphite-chemical-science-pack" },
        unit = unit(400, 60, "automation", "logistic", "chemical", "fullerene"),
    },
    {
        type = "technology",
        name = "advanced-character-distance",
        icon = "__core__/graphics/icons/entity/character.png",
        essential = false,
        upgrade = true,
        max_level = 3,
        show_levels_info = true,
        effects = {{ type = "character-build-distance", modifier = 8 }},
        prerequisites = { "graphite-logistic-science-pack" },
        unit = unit(200, 120, "logistic", "fullerene"),
    },
    {
        type = "technology",
        name = "fullerene_rocket_fuel",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 128,
        essential = true,
        effects = recipes("fullerene_rocket_fuel", "fullerene_solid_fuel"),
        prerequisites = { "advanced-shungite" },
        unit = unit(400, 60, "automation", "logistic", "fullerene"),
    },
    {
        type = "technology",
        name = "steam_cargo",
        icon = "__heliara__/graphics/icons/solar_refractor_silo.png",
        icon_size = 128,
        essential = true,
        effects = recipes("steam_cargo"),
        prerequisites = { "osmosis_pipejack", "fullerene_rocket_fuel", "solar_refractor" },
        unit = unit(2000, 60,
            "automation",
            "logistic",
            "production",
            "chemical",
            "fullerene"
        ),
    },
    planet_navigation,
    {
        type = "technology",
        name = "advanced-fullerene",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 128,
        essential = false,
        effects = recipes("fullerene-from-graphite", "graphite-from-carbon"),
        prerequisites = { planet_navigation.name, "advanced-shungite" },
        unit = unit(8000, 120,
            "automation",
            "logistic",
            "production",
            "chemical",
            "utility",
            "space",
            "metallurgic",
            "electromagnetic",
            "agricultural",
            "cryogenic",
            "fullerene"
        ),
    },
    {
        type = "technology",
        name = "stone-asteroid-crushing",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 128,
        essential = false,
        effects = recipes("stone-asteroid-crushing"),
        prerequisites = { "advanced-fullerene" },
        unit = unit(8000, 120,
            "automation",
            "logistic",
            "production",
            "chemical",
            "utility",
            "space",
            "metallurgic",
            "electromagnetic",
            "agricultural",
            "cryogenic",
            "fullerene"
        ),
    },
    {
        type = "technology",
        name = "coal-productivity",
        icons = util.technology_icon_constant_productivity("__heliara__/graphics/icons/coal.png"),
        essential = false,
        effects = productivity(0.1,
            "carbon",
            "coal-synthesis",
            "fullerene-from-shungite",
            "graphite-from-shungite",
            "carbon-from-shungite",
            "fullerene-from-graphite",
            "graphite-from-carbon"
        ),
        prerequisites = { "advanced-fullerene" },
        unit = {
            count_formula = "1.5^L*1000",
            ingredients = ingredients(
                "automation",
                "logistic",
                "production",
                "chemical",
                "utility",
                "space",
                "metallurgic",
                "electromagnetic",
                "agricultural",
                "cryogenic",
                "fullerene"
            ),
            time = 60
        },
        max_level = "infinite",
        upgrade = true
    },
    {
        type = "technology",
        name = "dyson_swarm",
        icon = "__heliara__/graphics/icons/default.png",
        icon_size = 1024,
        essential = false,
        effects = recipes("dyson_swarm_element", "dyson_swarm_launcher"),
        prerequisites = { planet_navigation.name },
        unit = unit(24000, 120,
            "automation",
            "logistic",
            "production",
            "chemical",
            "utility",
            "space",
            "metallurgic",
            "electromagnetic",
            "agricultural",
            "cryogenic",
            "fullerene"
        ),
    },
})
