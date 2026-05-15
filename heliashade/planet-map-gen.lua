require("common.common")

local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

local tile_names = { "flat", "crests", "lumpy", "patchy" }
for v in values(tile_names) do
    local d = table.deepcopy(data.raw["tile"]["dust-" .. v])
    local s = table.deepcopy(data.raw["tile"]["snow-" .. v])
    d.name = "helia-" .. v
    d.autoplace = s.autoplace
    d.autoplace.probability_expression = "min(1, 10000 + (" .. d.autoplace.probability_expression .. "))"
    d.tint = {0.85, 0.85, 0.85, 1}
    for k, vv in pairs(d.map_color) do
        d.map_color[k] = vv * 0.5
    end
    data:extend({d})
end

local d = table.deepcopy(data.raw["tile"]["empty-space"])
d.name = "helia-empty-space"
d.autoplace = {
    probability_expression = "(F > 1) * 1.5 + (\z
        (F > 0.800) * max(0, noise_layer_noise(10)) + \z
        (F > 0.825) * max(0, noise_layer_noise(11)) + \z
        (F > 0.850) * max(0, noise_layer_noise(12)) + \z
        (F > 0.875) * max(0, noise_layer_noise(13)) + \z
        (F > 0.900) * max(0, noise_layer_noise(14)) + \z
        (F > 0.925) * max(0, noise_layer_noise(15)) + \z
        (F > 0.950) * max(0, noise_layer_noise(16)) + \z
        (F > 0.975) * max(0, noise_layer_noise(17))\z
    ) * 1.25",
    local_expressions = {
        a = "128", b = "64",
        F = "(x/a)^2 + (y/b)^2"
    }
}

data:extend({d})

planet_map_gen.heliashade = function()
    return
    {
        property_expression_names =
        {
            elevation = "aquilo_elevation",
            temperature = "aquilo_temperature",
            moisture = "moisture_basic",
            aux = "aquilo_aux",
        },
        autoplace_controls =
        {
        },
        autoplace_settings =
        {
            ["tile"] =
            {
                settings =
                {
                    ["helia-flat"] = {},
                    ["helia-crests"] = {},
                    ["helia-lumpy"] = {},
                    ["helia-patchy"] = {},
                    ["helia-empty-space"] = {}
                }
            },
            ["decorative"] =
            {
                settings =
                {
                }
            },
            ["entity"] =
            {
                settings =
                {
                }
            }
        }
    }
end

return planet_map_gen
