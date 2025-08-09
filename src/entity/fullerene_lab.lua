require("common")

local _name = "fullerene_lab"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
        },
        item = {
            stack_size = 10,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 10,
                ["burner-inserter"] = 8,
                ["fullerene"] = 20,
                ["iron-plate"] = 5,
                ["steel-plate"] = 2,
                ["iron-gear-wheel"] = 20,
            },
            energy_required = 2,
            enabled = false,
        },
        entity = {
            type = "lab",
            name = _name,
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            minable = { mining_time = 1, result = _name },
            max_health = 100,
            collision_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            module_slots = 1,
            allowed_effects = { "consumption", "pollution" },
            energy_usage = "250kW",
            energy_source = {
                type = "burner",
                fuel_inventory_size = 1,
                fuel_categories = { "solar_fuel" }
            },

            inputs = {
                "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "fullerene-science-pack"
            },

            off_animation = {
                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                width = 256,
                height = 256,
                frame_count = 1,
                line_length = 1,
                shift = { 0.0, 0.0 },
                scale = 0.5
            },

            on_animation = {
                filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                width = 256,
                height = 256,
                frame_count = 1,
                line_length = 1,
                shift = { 0.0, 0.0 },
                scale = 0.5
            },
            impact_category = "metal-large",
            crafting_speed = 1,
            launch_to_space_platforms = false,
            can_launch_without_landing_pads = true
        },
    }
}