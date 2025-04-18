require("__heliara__.prototypes.planet.planet")
require("__heliara__.prototypes.entity.shungite")
require("__heliara__.prototypes.entity.fullerene_solar_panel")
require("__heliara__.prototypes.item.shungite")



require("util")

data:extend({
    --BASICS
    {
        type = "technology",
        name = "planet-discovery-heleria",
        icons = util.technology_icon_constant_planet("__heliara__/graphics/icons/heliara.png"),
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "heliara",
                use_icon_overlay_constant = true
            },
        },
        prerequisites = {"space-platform-thruster"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1},
            },
            time = 60
        }
    },


}
)