local hit_effects = require("__base__.prototypes.entity.hit-effects")

local _name = "fullerene_extraction_bath"

data:extend({
    {
        type = "recipe-category",
        name = "fullerene-chemistry"
    }
})

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/shungite.png", -- fixme
            icon_size = 500,
        },
        item = {
            stack_size = 10,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 10,
                ["steel-plate"] = 10,
                ["iron-plate"] = 20
            },
            energy_required = 10,
            enabled = false
        },
        entity = {
            type = "assembling-machine",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            minable = { mining_time = 2, result = _name },    -- fixme automate
            fast_replaceable_group = "chemical-plant",
            max_health = 300,
            icon_draw_specification = { shift = { 0, -0.3 } },
            circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
            collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
            selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            damaged_trigger_effect = hit_effects.entity(),
            drawing_box_vertical_extension = 0.4,
            module_slots = 1,
            allowed_effects = { "consumption", "speed", "productivity", "pollution", "quality" },
            heating_energy = "100kW",

            graphics_set = {
                animation = {
                    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                    width = 1024,
                    height = 1024,
                    frame_count = 1,
                    line_length = 1,
                    shift = { 0.0, 0.0 },
                    scale = 0.125
                }
            },
            impact_category = "metal-large",
            crafting_speed = 0.2,
            energy_source = {
                type = "electric",
                usage_priority = "secondary-input",
                emissions_per_minute = { pollution = 4 }
            },
            energy_usage = "0.2MW",
            crafting_categories = { "fullerene-chemistry" },
            fluid_boxes = {
                {
                    production_type = "input",
                    filter = "water",
                    volume = 200,
                    pipe_covers = pipecoverspictures(),
                    pipe_connections =
                    {
                        {flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0}},
                        {flow_direction = "input-output", direction = defines.direction.east, position = {1, 0}}
                    }
                },
            },
        },
    }
}