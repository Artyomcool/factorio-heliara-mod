require("common")

local _name = "platform_replicator"
local _blueprint_container = "platform_replicator_blueprint_container"
local _cargo_container = "platform_replicator_cargo_container"
local _starter_pack_container = "platform_replicator_starter_pack_container"
local _blueprint_tool = "platform_replicator_blueprint_tool"
local _blueprint = "platform_replicator_blueprint"

local _starter_pack = "big_space_platform_hub"

local _blue = {r = 0.15, g = 0.75, b = 1.0, a = 1}

local hub_spawn_delay_ticks = 15 * 60

local function is_platform_hub_entity_name(name)
    local proto = name and prototypes.entity[name]
    return proto and proto.type == "space-platform-hub"
end

local function remove_platform_hubs_from_blueprint_entities(bp_entities)
    local filtered = {}

    for _, bp_e in ipairs(bp_entities or {}) do
        local entity_name = bp_e.ghost_name or bp_e.name

        if not is_platform_hub_entity_name(entity_name) then
            filtered[#filtered + 1] = bp_e
        end
    end

    return filtered
end

local function get_position_axis(position, axis, index)
    return position and (position[axis] or position[index])
end

local function get_platform_snapshot_grid_center(blueprint)
    local snap_to_grid = blueprint.blueprint_snap_to_grid

    if not snap_to_grid then
        return nil
    end

    local snap_x = get_position_axis(snap_to_grid, "x", 1)
    local snap_y = get_position_axis(snap_to_grid, "y", 2)

    if not snap_x or not snap_y then
        return nil
    end

    if snap_x <= 0 or snap_y <= 0 then
        return nil
    end

    return {
        x = math.floor(snap_x / 2),
        y = math.floor(snap_y / 2)
    }
end

local function print_fail(s, entity, player, message)
    local next_message_tick = s["platform_replicator_next_message_tick"] or 0

    if game.tick >= next_message_tick then
        s["platform_replicator_next_message_tick"] = game.tick + 600

        if player and player.valid and player.connected then
            player.print("[Heliara] Platform replicator: " .. message)
        elseif entity and entity.valid and entity.force then
            entity.force.print("[Heliara] Platform replicator: " .. message)
        else
            game.print("[Heliara] Platform replicator: " .. message)
        end
    end
end

local function collect_cargo(cargo_inv)
    local cargo = {}

    for i = 1, #cargo_inv do
        local stack = cargo_inv[i]

        if stack and stack.valid_for_read then
            cargo[#cargo + 1] = {
                name = stack.name,
                count = stack.count,
                quality = stack.quality and stack.quality.name or "normal"
            }
        end
    end

    return cargo
end

local function clear_inventory(inv)
    for i = 1, #inv do
        local stack = inv[i]

        if stack and stack.valid_for_read then
            stack.clear()
        end
    end
end

local function finish_pending(entity)
    if not entity or not entity.valid then return end

    local s = entity_storage(entity)
    local pending = s["platform_replicator_pending"]

    if not pending then return end
    if game.tick < pending.hub_spawn_tick then return end

    s["platform_replicator_pending"] = nil

    local player = entity.last_user

    local function fail(message)
        print_fail(s, entity, player, message)
    end

    local new_platform = entity.force.create_space_platform{
        planet = pending.location_name,
        starter_pack = {
            name = pending.starter_pack_name,
            quality = pending.starter_pack_quality
        }
    }

    if not new_platform then
        return fail("failed to create new space platform.")
    end

    local hub = new_platform.apply_starter_pack()
    if not hub or not hub.valid then
        return fail("failed to apply starter pack after delay.")
    end

    local target_surface = new_platform.surface
    if not target_surface then
        return fail("new platform surface was not created after delay.")
    end

    local temp_inv = game.create_inventory(1)
    local import_result = temp_inv[1].import_stack(pending.blueprint_string)

    if import_result == 1 then
        temp_inv.destroy()
        return fail("failed to restore consumed blueprint.")
    end

    local blueprint = temp_inv[1]

    if not blueprint.valid_for_read or not blueprint.is_blueprint then
        temp_inv.destroy()
        return fail("restored item is not a valid blueprint.")
    end

    local bp_entities = blueprint.get_blueprint_entities() or {}
    local bp_tiles = blueprint.get_blueprint_tiles() or {}

    local build_min_x = nil
    local build_min_y = nil
    local build_max_x = nil
    local build_max_y = nil

    local function add_build_bounds(x, y)
        build_min_x = build_min_x and math.min(build_min_x, x) or x
        build_min_y = build_min_y and math.min(build_min_y, y) or y
        build_max_x = build_max_x and math.max(build_max_x, x) or x
        build_max_y = build_max_y and math.max(build_max_y, y) or y
    end

    local grid_center = get_platform_snapshot_grid_center(blueprint)

    for _, bp_e in ipairs(bp_entities) do
        local entity_name = bp_e.ghost_name or bp_e.name
        local x = bp_e.position.x
        local y = bp_e.position.y

        if not is_platform_hub_entity_name(entity_name) then
            add_build_bounds(x, y)
        end
    end

    for _, bp_t in ipairs(bp_tiles) do
        add_build_bounds(bp_t.position.x, bp_t.position.y)
        add_build_bounds(bp_t.position.x + 1, bp_t.position.y + 1)
    end

    if not grid_center then
        temp_inv.destroy()
        return fail("blueprint must contain a platform snapshot grid.")
    end

    if not build_min_x then
        temp_inv.destroy()
        return fail("blueprint contains no buildable content after removing snapshot helpers.")
    end

    local build_center = {
        x = math.floor((build_min_x + build_max_x) / 2),
        y = math.floor((build_min_y + build_max_y) / 2)
    }

    local build_position = {
        x = build_center.x - grid_center.x,
        y = build_center.y - grid_center.y
    }

    blueprint.set_blueprint_entities(remove_platform_hubs_from_blueprint_entities(bp_entities))

    blueprint.build_blueprint{
        surface = target_surface,
        force = entity.force,
        position = build_position,
        build_mode = defines.build_mode.superforced,
        skip_fog_of_war = false,
        raise_built = true,
        by_player = player and player.valid and player.index or nil
    }

    temp_inv.destroy()

    for _, item in ipairs(pending.cargo or {}) do
        local inserted = hub.insert{
            name = item.name,
            count = item.count,
            quality = item.quality
        }

        if inserted < item.count then
            fail(
                "new platform hub inventory is full; lost cargo: " ..
                item.name ..
                " [" .. item.quality .. "] " ..
                inserted .. "/" .. item.count
            )
        end
    end
end

local function on_tick(entity)
    local s = entity_storage(entity)

    if s["platform_replicator_pending"] then
        finish_pending(entity)
        return
    end

    local blueprint_container = s[_blueprint_container]
    local cargo_container = s[_cargo_container]
    local starter_pack_container = s[_starter_pack_container]

    local player = entity.last_user

    local function fail(message)
        print_fail(s, entity, player, message)
    end

    if not blueprint_container or not blueprint_container.valid then
        return fail("missing blueprint container.")
    end

    if not cargo_container or not cargo_container.valid then
        return fail("missing cargo container.")
    end

    if not starter_pack_container or not starter_pack_container.valid then
        return fail("missing starter pack container.")
    end

    local blueprint_inv = blueprint_container.get_inventory(defines.inventory.chest)
    if not blueprint_inv then
        return fail("blueprint container has no chest inventory.")
    end

    local cargo_inv = cargo_container.get_inventory(defines.inventory.chest)
    if not cargo_inv then
        return fail("cargo container has no chest inventory.")
    end

    local starter_pack_inv = starter_pack_container.get_inventory(defines.inventory.chest)
    if not starter_pack_inv then
        return fail("starter pack container has no chest inventory.")
    end

    local blueprint = blueprint_inv[1]

    if not blueprint.valid_for_read then
        return fail("put a blueprint into the blueprint container.")
    end

    if not blueprint.is_blueprint then
        return fail("blueprint container must contain a blueprint.")
    end

    local bp_entities = blueprint.get_blueprint_entities() or {}
    local bp_tiles = blueprint.get_blueprint_tiles() or {}

    if #bp_entities == 0 and #bp_tiles == 0 then
        return fail("blueprint is empty.")
    end

    if not get_platform_snapshot_grid_center(blueprint) then
        return fail("blueprint must contain a platform snapshot grid.")
    end

    local starter_stack = starter_pack_inv[1]

    if not starter_stack.valid_for_read then
        return fail("put starter pack into the starter pack container.")
    end

    if starter_stack.type ~= "space-platform-starter-pack" then
        return fail(_starter_pack .. " is not a space platform starter pack.")
    end

    local starter_pack_name = starter_stack.name
    local starter_pack_quality = starter_stack.quality and starter_stack.quality.name or "normal"

    local required = {}

    for _, bp_e in ipairs(bp_entities) do
        local entity_name = bp_e.ghost_name or bp_e.name

        if not is_platform_hub_entity_name(entity_name) then
            local proto = prototypes.entity[entity_name]

            if proto and proto.items_to_place_this and proto.items_to_place_this[1] then
                local place_stack = proto.items_to_place_this[1]
                local item_name = place_stack.name
                local item_count = place_stack.count or 1
                local item_proto = prototypes.item[item_name]
                local quality_name = bp_e.quality or "normal"

                if not item_proto or item_proto.type ~= "space-platform-starter-pack" then
                    required[item_name] = required[item_name] or {}
                    required[item_name][quality_name] = (required[item_name][quality_name] or 0) + item_count
                end
            else
                return fail("cannot determine item required to place entity: " .. entity_name)
            end
        end
    end

    for _, bp_t in ipairs(bp_tiles) do
        local proto = prototypes.tile[bp_t.name]

        if proto and proto.items_to_place_this and proto.items_to_place_this[1] then
            local place_stack = proto.items_to_place_this[1]
            local item_name = place_stack.name
            local item_count = place_stack.count or 1

            required[item_name] = required[item_name] or {}
            required[item_name]["normal"] = (required[item_name]["normal"] or 0) + item_count
        else
            return fail("cannot determine item required to place tile: " .. bp_t.name)
        end
    end

    local starter_pack_proto = prototypes.item[starter_pack_name]

    if starter_pack_proto and starter_pack_proto.initial_items then
        for _, product in ipairs(starter_pack_proto.initial_items) do
            if product.type == "item" and product.name then
                local amount = product.amount or product.amount_min or 0

                if amount > 0 and required[product.name] and required[product.name][starter_pack_quality] then
                    required[product.name][starter_pack_quality] =
                        required[product.name][starter_pack_quality] - amount

                    if required[product.name][starter_pack_quality] <= 0 then
                        required[product.name][starter_pack_quality] = nil
                    end

                    if next(required[product.name]) == nil then
                        required[product.name] = nil
                    end
                end
            end
        end
    end

    local platform = entity.surface.platform

    if not platform then
        for _, p in pairs(entity.force.platforms) do
            if p.valid and p.surface and p.surface.index == entity.surface.index then
                platform = p
                break
            end
        end
    end

    if not platform then
        return fail("replicator is not on a space platform.")
    end

    local location = platform.space_location or platform.last_visited_space_location

    if not location then
        return fail("source platform is not at a known space location.")
    end

    local blueprint_string = blueprint.export_stack()

    if not blueprint_string or blueprint_string == "" then
        return fail("failed to export blueprint before launch.")
    end

    local launched = entity.launch_rocket{type = defines.cargo_destination.orbit}

    if not launched then
        return
    end

    local removed_starter_pack = starter_pack_inv.remove{
        name = starter_pack_name,
        count = 1,
        quality = starter_pack_quality
    }

    if removed_starter_pack < 1 then
        return fail("failed to remove starter pack from starter pack container.")
    end

    blueprint.clear()

    local cargo = collect_cargo(cargo_inv)
    clear_inventory(cargo_inv)

    s["platform_replicator_pending"] = {
        location_name = location.name,
        starter_pack_name = starter_pack_name,
        starter_pack_quality = starter_pack_quality,
        blueprint_string = blueprint_string,
        cargo = cargo,
        hub_spawn_tick = game.tick + hub_spawn_delay_ticks
    }

    if player and player.valid and player.connected then
        player.print("[Heliara] Platform replicator: rocket launched, hub will spawn in 15 seconds.")
    end
end

local _silo_base_img = "__heliara__/graphics/entity/space_platform_silo/space_platform_silo_A_base.png"
local _silo_shadow_img = "__heliara__/graphics/entity/space_platform_silo/space_platform_silo_A_shadow.png"
local _silo_front_img = "__heliara__/graphics/entity/space_platform_silo/space_platform_silo_A_front.png"
local _rocket_img = "__heliara__/graphics/entity/space_platform_silo/space_platform_rocket.png"

local entity = {
    type = "rocket-silo",
    name = _name,
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    fast_transfer_modules_into_module_slots_only = false,
    crafting_categories = { "rocket-building" },
    rocket_parts_required = 4,
    rocket_quick_relaunch_start_offset = -0.625,
    cargo_station_parameters = {
        hatch_definitions = {
            {
                hatch_graphics = nil,
                offset = { 0, 0 },
                pod_shadow_offset = { 0, 0 },
                cargo_unit_entity_to_spawn = "",
                receiving_cargo_units = {}
            }
        },
    },
    crafting_speed = 1,
    logistic_trash_inventory_size = 0,
    minable = { mining_time = 1, result = _name },
    max_health = 1000,
    collision_box = { { -1.99, -2.49 }, { 1.99, 2.49 } },
    selection_box = { { -1.99, -2.49 }, { 1.99, 2.49 } },
    hole_clipping_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    resistances = {
        { type = "fire",   percent = 20 },
        { type = "impact", percent = 40 },
    },
    impact_category = "metal-large",
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
    },
    energy_usage = "250kW",
    lamp_energy_usage = "0kW",
    active_energy_usage = "2.5MW",
    rocket_entity = "space_platform_rocket",
    times_to_blink = 0,
    light_blinking_speed = 10000,
    door_opening_speed = 10000,
    heating_energy = "1MW",
    door_back_open_offset = { 1.8, -1.8 * 0.43299225 },
    door_front_open_offset = { -1.8, 1.8 * 0.43299225 },
    silo_fade_out_start_distance = 8,
    silo_fade_out_end_distance = 15,
    fixed_recipe = nil,
    to_be_inserted_to_rocket_inventory_size = 0,
    launch_to_space_platforms = false,
    surface_conditions = {
        { property = "gravity", min = 0, max = 0 }
    },
    hole_sprite = nil,
    hole_light_sprite = nil,
    shadow_sprite = {
        filename = _silo_shadow_img,
        width = 381,
        height = 374,
        shift = { 0.55, -0.05 },
        scale = 0.5,
        draw_as_shadow = true,
    },
    base_day_sprite = {
        filename = _silo_base_img,
        width = 317,
        height = 374,
        shift = { 0.05, -0.05 },
        scale = 0.5,
    },
    base_front_sprite = {
        filename = _silo_front_img,
        width = 317,
        height = 374,
        shift = { 0.05, -0.05 },
        scale = 0.5,
    },
    bound_entities = (function()
        local function slot(name, offset, width, inventory_size, extra)
            local t = {
                type = "container",
                name = name,
                offset = offset,
                flags = { "not-on-map" },
                hidden = true,
                inventory_size = inventory_size,
                collision_box = { { -0.5*width, -0.5 }, { 0.5*width, 0.5 } },
                collision_mask = { layers = {} },
                selection_box = { { -0.5*width, -0.5 }, { 0.5*width, 0.5 } },
                picture = { filename = "__core__/graphics/empty.png", width = 1, height = 1, scale = 1 },
            }
            if extra then for k, v in pairs(extra) do t[k] = v end end
            return t
        end
        return {
            slot(_blueprint_container,    { -2, 2 }, 1, 1),
            slot(_cargo_container,        { 0, 2 }, 2, 20, { inventory_type = "with_weight_limit", inventory_weight_limit = 2 * tons }),
            slot(_starter_pack_container, {  1, 2 }, 1, 1),
        }
    end)(),
}

local rocket_entity_proto = {
    type = "rocket-silo-rocket",
    name = "space_platform_rocket",
    hidden = true,
    flags = { "not-on-map" },
    collision_mask = { layers = {}, not_colliding_with_itself = true },
    collision_box = { { -1, -4 }, { 1, 2 } },
    selection_box = { { 0, 0 }, { 0, 0 } },
    dying_explosion = "massive-explosion",
    shadow_slave_entity = "rocket-silo-rocket-shadow",
    inventory_size = 0,
    rising_speed = 1 / (1 * 60),
    engine_starting_speed = 10000,
    flying_speed = 1 / (1250 * 60),
    flying_acceleration = 0.01,
    icon_draw_specification = { render_layer = "air-entity-info-icon" },
    glow_light = { intensity = 1, size = 30, shift = { 0, 1.5 }, color = { 1, 1, 1 } },
    cargo_pod_entity = "cargo-pod-no-payload",
    rocket_sprite = {
        filename = _rocket_img,
        width = 192,
        height = 320,
        scale = 0.175,
    },
    rocket_flame_animation = util.sprite_load("__base__/graphics/entity/rocket-silo/rocket-jet",
        {
            shift = {0.2, -6.2},
            draw_as_glow = true,
            blend_mode = "additive",
            scale = 0.08,
            frame_count = 8,
            animation_speed = 0.5
        }),
    rocket_flame_left_rotation = 0,
    rocket_flame_right_rotation = 0,
    rocket_initial_offset = { 0.1, 3 },
    rocket_rise_offset = { 0.1, -1.1 },
    rocket_launch_offset = { 0.1, -64 },
    cargo_attachment_offset = util.by_pixel(0, -63.4),
    rocket_render_layer_switch_distance = 9.5,
    full_render_layer_switch_distance = 11,
    effects_fade_in_start_distance = 4.5,
    effects_fade_in_end_distance = 7.5,
    shadow_fade_out_start_ratio = 0.25,
    shadow_fade_out_end_ratio = 0.75,
    rocket_visible_distance_from_center = 0.4,
    rocket_above_wires_slice_offset_from_center = -3,
    rocket_air_object_slice_offset_from_center = -6,
    flying_sound = nil
}

entity.on_build = wrap(function(e)
    local s = entity_storage(e)

    local blueprint_container = s[_blueprint_container]
    if blueprint_container and blueprint_container.valid then
        local inv = blueprint_container.get_inventory(defines.inventory.chest)
        if inv and inv.supports_filters() then
            inv.set_filter(1, _blueprint)
        end
    end

    local starter_pack_container = s[_starter_pack_container]
    if starter_pack_container and starter_pack_container.valid then
        local inv = starter_pack_container.get_inventory(defines.inventory.chest)
        if inv and inv.supports_filters() then
            inv.set_filter(1, _starter_pack)
        end
    end
end)

entity.on_tick = wrap(on_tick)

local blueprint_tool_proto = wrap_for_data(
    function()
        return {
            type = "selection-tool",
            name = _blueprint_tool,
            icon = "__heliara__/graphics/icons/platform_replicator_blueprint.png",
            icon_size = 64,
            subgroup = "space-platform",
            order = "z[heliara]-a[platform-replicator]-c[blueprint-tool]",
            stack_size = 1,
            flags = {"not-stackable", "spawnable"},
            select = {
                border_color = _blue,
                mode = {"blueprint"},
                cursor_box_type = "copy",
            },
            alt_select = {
                border_color = {r = 1, g = 1, b = 1, a = 1},
                mode = {"blueprint"},
                cursor_box_type = "copy",
            },
        }
    end
)

local platform_blueprint_proto = wrap_for_data(
    function()
        local blueprint = table.deepcopy(data.raw["blueprint"]["blueprint"])
        blueprint.name = _blueprint
        blueprint.localised_name = {"item-name.platform-replicator-blueprint"}
        blueprint.icon = "__heliara__/graphics/icons/platform_replicator_blueprint.png"
        blueprint.icon_size = 64
        blueprint.subgroup = "tool"
        blueprint.order = "c[automated-construction]-aa[platform-replicator-blueprint]"
        return blueprint
    end
)

local blueprint_tool_shortcut_proto = wrap_for_data(
    function()
        return {
            type = "shortcut",
            name = _blueprint_tool,
            order = "b[blueprints]-ga[platform-snapshot]",
            action = "lua",
            localised_name = {"shortcut-name.platform-replicator-blueprint-tool"},
            style = "blue",
            icon = "__heliara__/graphics/icons/platform_replicator_blueprint.png",
            icon_size = 64,
            small_icon = "__heliara__/graphics/icons/platform_replicator_blueprint.png",
            small_icon_size = 64,
        }
    end
)

return {
    {
        common = {
            name = _name,
            icon = "__base__/graphics/icons/rocket-silo.png",
        },
        item = {
            stack_size = 1,
            place_result = _name,
            subgroup = "space-platform",
            order = "z[heliara]-a[platform-replicator]-a[replicator]",
        },
        recipe = {
            ingredients = {
                ["rocket-silo"] = 1,
                ["tungsten-plate"] = 100,
                ["processing-unit"] = 50,
                ["fullerene"] = 50,
                ["graphite_circuit"] = 30,
            },
            energy_required = 60,
            enabled = true,
        },
        entity = entity,
        raw = {
            platform_blueprint_proto,
            blueprint_tool_proto,
            blueprint_tool_shortcut_proto,
            rocket_entity_proto,
        }
    }
}
