local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
    {
        type = "item",
        name = "shungite",
        icon = "__heliara__/graphics/icons/shungite.png",
        icon_size = 500,
        order = "a-b-c",
        --subgroup = "heliara",
        color_hint = { text = "T" },

        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 100,
        default_import_location = "heliara",
        weight = 0.01 * kg
    }
})