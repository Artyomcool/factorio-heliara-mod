require ("util")

local item_tints = require("__base__.prototypes.item-tints")

require("__base__.prototypes.entity.pipecovers")
require("__base__.prototypes.entity.assemblerpipes")

local _name = "solar_refractor_silo"

data:extend({
    {
        type = "recipe-category",
        name = "steam_rockets"
    }
})

local retractor_silo = {
    type = "rocket-silo",
    name = _name,
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    fast_transfer_modules_into_module_slots_only = false,
    crafting_categories = { "steam_rockets" },
    fast_replaceable_group = "steam_rockets",
    --rocket_parts_required = 12,
    rocket_parts_required = 2,
    rocket_quick_relaunch_start_offset = -0.625,
    cargo_station_parameters = {
        hatch_definitions = {
            {
                hatch_graphics = nil,
                offset = { 0, 0 },
                pod_shadow_offset = { 0, 0 };
                cargo_unit_entity_to_spawn = "",
                receiving_cargo_units = {}
            }
        },
    },
    crafting_speed = 1,
    logistic_trash_inventory_size = 0,
    -- icon_draw_specification = {shift = {0, 2}},
    -- icons_positioning = { {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 3.3}} },
    -- fixed_recipe = "rocket-part",
    -- show_recipe_icon = false,
    -- allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    minable = { mining_time = 5, result = _name }, -- fixme automate
    max_health = 1000,
    -- corpse = "rocket-silo-remnants",
    -- dying_explosion = "rocket-silo-explosion",
    collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
    selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    -- damaged_trigger_effect = hit_effects.entity(),
    hole_clipping_box = { { -1, -1 }, { 1, 1 } }, -- hole_clipping_box = { {-2.75, -1.15}, {2.75, 2.25} },
    resistances =
    {
        {
            type = "fire",
            percent = 40 -- 60
        },
        {
            type = "impact",
            percent = 80 -- 60
        }
    },
    impact_category = "metal-large",
    energy_source = {
        type = "fluid",
        fluid_box = {
            production_type = "input",
            filter = "steam",
            volume = 500,
            pipe_covers = pipecoverspictures(),
            pipe_connections = {
                { flow_direction = "input", direction = defines.direction.west, position = { -1, 0 } },
                { flow_direction = "input", direction = defines.direction.east, position = { 1, 0 } },
                { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
                { flow_direction = "input", direction = defines.direction.south, position = { 0, 1 } }
            }
        },
        fluid_usage_per_tick = 10,
    },
    energy_usage = "250kW", --energy usage used when crafting the rocket
    lamp_energy_usage = "0kW",
    active_energy_usage = "0.5MW", -- 3990kW
    rocket_entity = "solar_refractor",
    times_to_blink = 0,
    light_blinking_speed = 10000, -- 1 / (3 * 60),
    door_opening_speed = 10000, -- (4.25 * 60),

    -- base_engine_light = { intensity = 1, size = 25, shift = {0, 1.5} },
    -- shadow_sprite = { filename = "__base__/graphics/entity/rocket-silo/00-rocket-silo-shadow.png", priority = "medium", width = 612, height = 578, draw_as_shadow = true, dice = 2, shift = util.by_pixel(7, 2), scale = 0.5 },

    hole_sprite =
    {
        filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. "_hole.png",
        width = 1024,
        height = 1024,
        -- shift = util.by_pixel(-5, 16),
        scale = 0.125
    },

    hole_light_sprite =
    {
        filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. "_hole.png",
        width = 1024,
        height = 1024,
        -- shift = util.by_pixel(-5, 16),
        scale = 0.125
    },

    --rocket_shadow_overlay_sprite =
    --{
    --    filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-shadow-over-rocket.png",
    --    width = 426,
    --    height = 288,
    --    shift = util.by_pixel(-2, 21),
    --    scale = 0.5
    --},
    --rocket_glow_overlay_sprite =
    --{
    --    filename = "__base__/graphics/entity/rocket-silo/03-rocket-over-glow.png",
    --    blend_mode = "additive",
    --    width = 434,
    --    height = 446,
    --    shift = util.by_pixel(-3, 36),
    --    scale = 0.5
    --},

    --door_back_sprite =
    --{
    --    filename = "__heliara__/graphics/entity/" .. _name .. "/" .. _name .. "_door.png",
    --    width = 1024,
    --    height = 1024,
    --    --shift = util.by_pixel(37, 12),
    --    scale = 0.125
    --},

    heating_energy = "1MW",
    door_back_open_offset = { 1.8, -1.8 * 0.43299225 },
    door_front_open_offset = { -1.8, 1.8 * 0.43299225 },
    silo_fade_out_start_distance = 8,
    silo_fade_out_end_distance = 15,

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
    launch_to_space_platforms = false,
    can_launch_without_landing_pads = true
}

local cargo_silo = table.deepcopy(retractor_silo)
cargo_silo.name = 'steam_cargo_silo'
cargo_silo.icon = "__heliara__/graphics/icons/" .. _name .. ".png"
cargo_silo.launch_to_space_platforms = true
cargo_silo.can_launch_without_landing_pads = false
cargo_silo.rocket_entity = "steam_cargo"
cargo_silo.crafting_categories = { "steam_rockets" }
cargo_silo.to_be_inserted_to_rocket_inventory_size = 1

return {
    {
        common = {
            name = _name,
            icon = "__heliara__/graphics/icons/" .. _name .. ".png",
        },
        item = {
            stack_size = 1,
            random_tint_color = item_tints.iron_rust,
            place_result = _name,
        },
        recipe = {
            ingredients = {
                ["stone-brick"] = 40,
                ["concrete"] = 100,
                ["steel-plate"] = 20,
                ["iron-plate"] = 50,
                ["iron-gear-wheel"] = 50,
                ["engine-unit"] = 50,
                ["graphite_circuit"] = 40,
                ["heliara_assembling_machine"] = 4,
            },
            energy_required = 10,
            enabled = false,
        },
        entity = retractor_silo
    },
    {
        entity = cargo_silo
    }
}