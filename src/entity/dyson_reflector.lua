require("common")

local _name = "dyson_reflector"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/default.png",
            icon_size = 128,
        },
        item = {
            subgroup = "space-related",
            color_hint = { text = "2" }, -- ??
            order = "g[dyson_reflector]",
            --inventory_move_sound = item_sounds.mechanical_inventory_move,
            --pick_sound = item_sounds.mechanical_inventory_pickup,
            --drop_sound = item_sounds.mechanical_inventory_move,
            stack_size = 1,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["steel-plate"] = 200,
                ["tungsten-plate"] = 200,
                graphite_circuit = 250,
                ["processing-unit"] = 200,
                ["superconductor"] = 40,
                ["quantum-processor"] = 40,
                ["uranium-235"] = 10,
                ["uranium-238"] = 8,
                ["photosoma"] = 100,
            },
            fluid_ingredients = {
                ["fluoroketone-cold"] = 100,
            },
            energy_required = 160,
            category = "cryogenics",
            surface_conditions = {
                { property = "gravity", min = 0.3, max = 0.9 },
                { property = "pressure", min = 0, max = 10 },
                { property = "solar-power", min = 0, max = 1 },
                { property = "magnetic-field", min = 10, max = 30 },
            }
        },
        entity = {
            type = "simple-entity",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            minable = { mining_time = 0.2, result = _name },
            max_health = 15000,
            resistances = {
                {
                    type = "fire",
                    percent = 99
                }
            },
            collision_box = { { -7.9, -7.9 }, { 7.9, 7.9 } },
            selection_box = { { -8, -8 }, { 8, 8 } },
            impact_category = "metal",

            animations = {
                {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                    width = 1024,
                    height = 1024,
                    scale = 0.5
                },
            },
            surface_conditions = {
                { property = "gravity", min = 0, max = 0 },
                { property = "pressure", min = 0, max = 0 },
            }
        }
    },
    {
        common = {
            name = "photosoma",
            icon = "__heliara__/graphics/icons/default.png",
            icon_size = 128,
        },
        recipe = {
            name = "photosoma-synthesis",
            category = "centrifuging",
            energy_required = 10,
            --enabled = false,
            ingredients =
            {
                ["copper-bacteria"] = 40,
                ["iron-bacteria"] = 40,
                ["uranium-238"] = 1,
            },
            results =
            {
                ["photosoma"] = {1, 1, 0.005},
                ["spoilage"] = 1,
                ["uranium-238"] = {1, 1, 0.75},
            },
            main_product = "photosoma",
            subgroup = "intermediate-product",
            order = "z[photosoma]-a[synt]",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
        item = {
            subgroup = "intermediate-product",
            order = "z[photosoma]-a",
            stack_size = 50,
            default_import_location = "gleba",
            weight = 1 * kg,
            spoil_ticks = 5 * minute,
            spoil_result = "spoilage"
        }
    },
    {
        recipe = {
            name = "photosoma-breeding",
            category = "organic",
            energy_required = 16,
            --enabled = false,
            ingredients =
            {
                ["photosoma"] = 20,
                ["graphite"] = 2,
                ["jelly"] = 1,
                ["spoilage"] = 10,
            },
            results =
            {
                ["photosoma"] = 24,
            },
            main_product = "photosoma",
            subgroup = "intermediate-product",
            order = "z[photosoma]-a[synt]",
            auto_recycle = false,
            allow_productivity = true,
            allow_decomposition = false,
        },
    }
}