require("common.common")
require("planet")
require("noise")
require("util")
require("technology")

local decl = require("common.declarations")

data:extend({
    {
        type = "item-subgroup",
        name = "heliara-materials",
        group = "intermediate-products",
        order = "h[heliara-materials]"
    },
    {
        type = "item-subgroup",
        name = "heliara-science-pack",
        group = "intermediate-products",
        order = "y[science-pack]-a[heliara]"
    },
})

decl.all(require("entities"))

local collapsing_container = util.table.deepcopy(data.raw["temporary-container"]["cargo-pod-container"])
collapsing_container.name = "collapsing-cargo-pod-container"
collapsing_container.time_to_leave = 1
data:extend({collapsing_container})

data:extend({
    {
        type = "achievement",
        name = "heliara-sun-control-1",
        order = "a[progress]-r[heliara]-c[1]",
        icon = "__heliara__/graphics/icons/solar_reflector.png",
        icon_size = 1024,
    },
    {
        type = "achievement",
        name = "heliara-sun-control-2",
        order = "a[progress]-r[heliara]-c[2]",
        icon = "__heliara__/graphics/icons/heliara_tech.png",
        icon_size = 256,
    },
    {
        type = "achievement",
        name = "heliara-sun-control-3",
        order = "a[progress]-r[heliara]-c[3]",
        icon = "__heliara__/graphics/icons/heliara.png",
        icon_size = 512,
    },
})
