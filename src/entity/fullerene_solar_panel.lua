require("common")
req("__heliara__/script/ui")

local _name = "fullerene_solar_panel"

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
        },
        item = {
            stack_size = 20,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 10,
                ["steel-plate"] = 2,
                ["iron-plate"] = 4,
                ["iron-gear-wheel"] = 4,
            },
            energy_required = 4,
            enabled = false
        },
        entity = {
            type = "solar-panel",
            flags = { "placeable-neutral", "player-creation" },
            selection_priority = 50,
            minable = { mining_time = 0.75, result = _name },
            collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
            selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
            damaged_trigger_effect = hit_effects.entity(),
            energy_source = {
                type = "electric",
                usage_priority = "solar",
                render_no_power_icon = false,
                render_no_network_icon = false,
            },
            production = "800kW",

            picture = {
                layers = {
                    {
                        filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. ".png",
                        priority = "high",
                        width = 230,
                        height = 224,
                        shift = util.by_pixel(-3, 3.5),
                        scale = 0.5
                    },
                    {
                        filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
                        priority = "high",
                        width = 220,
                        height = 180,
                        shift = util.by_pixel(9.5, 6),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            },
            overlay = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
                        priority = "high",
                        width = 214,
                        height = 180,
                        shift = util.by_pixel(10.5, 6),
                        scale = 0.5
                    }
                }
            },
            impact_category = "glass",
            perceived_performance = {minimum = 0.1, maximum = 0.1},

            bound_entities = {
                {
                    type = "burner-generator",
                    name = "hidden-burner-generator",
                    flags = { "not-on-map", "placeable-off-grid" },
                    selection_priority = 51,
                    --selectable_in_game = false,
                    hidden = true,
                    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
                    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
                    energy_source = {
                        type = "electric",
                        buffer_capacity = "2kJ",
                        usage_priority = "tertiary",
                        input_flow_limit = "0kW",
                        output_flow_limit = "2kW",
                        render_no_power_icon = false,
                        render_no_network_icon = false,
                        drain = "2kW"
                    },
                    burner = {
                        type = "burner",
                        fuel_inventory_size = 1,
                        fuel_categories = {"solar_fuel"},
                        burner_usage = "fullerene"
                    },
                    max_power_output = "2kW",

                    pictures = {
                        filename = "__core__/graphics/empty.png",
                        width = 1,
                        height = 1,
                        direction_count = 1
                    },
                    on_gui_opened = make_reflectors_ui,
                    on_gui_destroy = destroy_reflectors_ui,
                }
            }
        },
        raw = {
            {
                type = "burner-usage",
                name = "fullerene",
                empty_slot_sprite = {
                    filename = "__core__/graphics/icons/mip/empty-nutrients-slot.png",
                    priority = "extra-high-no-scale",
                    size = 64,
                    mipmap_count = 2,
                    flags = {"gui-icon"},
                },
                empty_slot_caption = {"gui.nutrients"},
                empty_slot_description = {"gui.nutrients-description"},

                icon = {
                    filename = "__core__/graphics/icons/alerts/nutrients-icon-red.png",
                    priority = "extra-high-no-scale",
                    width = 64,
                    height = 64,
                    flags = {"icon"}
                },
                no_fuel_status = {"entity-status.no-nutrients"},

                accepted_fuel_key = "description.accepted-nutrients",
                burned_in_key = "eaten-by", -- factoriopedia
            }
        }
    },
}