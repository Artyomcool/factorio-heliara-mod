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

local prereqs = { "planet-discovery-aquilo" }
if mods["heliara"] then
    table.insert(prereqs, "planet-discovery-heliara")
end

data:extend({
    {
        type = "technology",
        name = "planet-discovery-heliashade",
        icons = util.technology_icon_constant_planet("__heliashade__/graphics/icons/default.png"),
        essential = true,
        effects = {
            {
                type = "unlock-space-location",
                space_location = "heliashade",
                use_icon_overlay_constant = true
            },
        },
        prerequisites = prereqs,
        unit = unit(4000, 120,
            "automation",
            "logistic",
            "chemical",
            "production",
            "utility",
            "space",
            "metallurgic",
            "electromagnetic",
            "cryogenic"
        ),
    },
    --[[ {
        type = "technology",
        name = "dyson_swarm",
        icon = "__heliashade__/graphics/icons/default.png",
        icon_size = 128,
        essential = false,
        effects = {
            { type = "unlock-recipe", recipe = "dyson_swarm_element" },
            { type = "unlock-recipe", recipe = "dyson_swarm_launcher" },
        },
        prerequisites = { "planet-discovery-heliashade", "promethium-science-pack" },
        unit = unit(64000, 120,
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
            "promethium"
        ),
    }, ]]
})
