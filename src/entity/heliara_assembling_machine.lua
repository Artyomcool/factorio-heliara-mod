local _name = "heliara_assembling_machine"

require("__base__.prototypes.entity.pipecovers")
require("__base__.prototypes.entity.assemblerpipes")

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
            icon_size = 64,
            icon_draw_specification = { shift = { 0, -0.3 } },
        },
        item = {
            subgroup = "production-machine",
            color_hint = { text = "2" }, -- ??
            order = "d[assembling-machine-heliara]",
            --inventory_move_sound = item_sounds.mechanical_inventory_move,
            --pick_sound = item_sounds.mechanical_inventory_pickup,
            --drop_sound = item_sounds.mechanical_inventory_move,
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                graphite_circuit = 5,
                ["iron-gear-wheel"] = 8,
                ["steel-plate"] = 2,
                ["iron-plate"] = 10,
            },
            energy_required = 10,
            enabled = false,
        },
        entity = {
            type = "assembling-machine",
            flags = { "placeable-neutral", "placeable-player", "player-creation" },
            selection_priority = 40,
            minable = { mining_time = 0.2, result = _name },
            max_health = 300,
            resistances = {
                {
                    type = "fire",
                    percent = 70
                }
            },
            --corpse = _name .. "-repnants",
            --dying_explosion =
            collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
            selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
            --damaged_trigger_effect = hit_effects.entity(),
            fast_replaceable_group = "assembling-machine",
            next_upgrade = "assembling-machine-2",
            --circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
            --circuit_connector = circuit_connector_definitions["assembling-machine"],
            alert_icon_shift = util.by_pixel(0, -12),
            ingredient_count = 20,
            crafting_categories = { "crafting", "basic-crafting", "advanced-crafting", "crafting-with-fluid", "fullerene_craft" },
            crafting_speed = 0.7,
            module_slots = 1,
            allowed_effects = { "consumption", "speed", "productivity", "pollution" }, --, "quality"},
            impact_category = "metal",

            fluid_boxes = {
                {
                    production_type = "input",
                    pipe_picture = assembler2pipepictures(),
                    pipe_covers = pipecoverspictures(),
                    volume = 1000,
                    pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
                    secondary_draw_orders = { north = -1 }
                },
                {
                    production_type = "output",
                    pipe_picture = assembler2pipepictures(),
                    pipe_covers = pipecoverspictures(),
                    volume = 1000,
                    pipe_connections = { { flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } } },
                    secondary_draw_orders = { north = -1 }
                },
            },
            fluid_boxes_off_when_no_fluid_recipe = true,

            graphics_set = {
                animation = {
                    layers = {
                        {
                            filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                            priority = "high",
                            width = 214,
                            height = 226,
                            frame_count = 32,
                            line_length = 8,
                            shift = util.by_pixel(0, 2),
                            scale = 0.5
                        },
                        {
                            filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. "_shadow.png",
                            priority = "high",
                            width = 190,
                            height = 165,
                            line_length = 1,
                            repeat_count = 32,
                            draw_as_shadow = true,
                            shift = util.by_pixel(8.5, 5),
                            scale = 0.5
                        }
                    }
                }
            },

            energy_source = {
                type = "electric",
                usage_priority = "secondary-input",
                emissions_per_minute = { pollution = 4 },
            },
            energy_usage = "75kW",

            --open_sound = sounds.machine_open,
            --close_sound = sounds.machine_close,
            working_sound = {
                sound = { filename = "__base__/sound/assembling-machine-t2-1.ogg", volume = 0.45, audible_distance_modifier = 0.5 },
                fade_in_ticks = 4,
                fade_out_ticks = 20
            },
        }
    },
    {
        recipe = {
            name = "fullerene_rocket_fuel",
            ingredients = {
                carbon = 50,
                fullerene = 10,
                graphite = 8,
                ["iron-plate"] = 1,
            },
            fluid_ingredients = {
                steam = 500,
            },
            results = {
                ["rocket-fuel"] = 1,
                ["iron-ore"] = 1,
            },
            energy_required = 20,
            enabled = false,
            main_product = "rocket-fuel",
            category = "fullerene_craft",
        },
    },
}