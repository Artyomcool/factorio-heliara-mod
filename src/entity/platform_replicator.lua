require("common")

local _name = "platform_replicator"
local _container = "platform_replicator_container"
local _control_container = "platform_replicator_control_container"
local _marker = "platform_replicator_center_marker"

local _purple = {r = 0.9, g = 0.7, b = 1, a = 1}
local _blue = {r = 0.15, g = 0.75, b = 1.0, a = 1}

local hub_spawn_delay_ticks = 15 * 60

local function tint_all_with(t, tint)
    if type(t) ~= "table" then return end

    if t.filename then
        t.tint = tint
    end

    for _, v in pairs(t) do
        tint_all_with(v, tint)
    end
end

local function tint_all(t)
    tint_all_with(t, _purple)
end

local function get_player(entity, cargo_container, control_container)
    if control_container and control_container.valid and control_container.last_user and control_container.last_user.valid then
        return control_container.last_user
    elseif cargo_container and cargo_container.valid and cargo_container.last_user and cargo_container.last_user.valid then
        return cargo_container.last_user
    elseif entity and entity.valid and entity.last_user and entity.last_user.valid then
        return entity.last_user
    end

    return nil
end

local function print_fail(s, entity, player, message)
    local next_message_tick = s["platform_replicator_next_message_tick"] or 0

    if game.tick >= next_message_tick then
        s["platform_replicator_next_message_tick"] = game.tick + 300

        if player and player.valid and player.connected then
            player.print("[Heliara] Platform replicator: " .. message)
        elseif entity and entity.valid and entity.force then
            entity.force.print("[Heliara] Platform replicator: " .. message)
        else
            game.print("[Heliara] Platform replicator: " .. message)
        end
    end
end

local function check_required(cargo_inv, required)
    for item_name, qualities in pairs(required) do
        for quality_name, count in pairs(qualities) do
            local available = cargo_inv.get_item_count{
                name = item_name,
                quality = quality_name
            }

            if available < count then
                return false, item_name, quality_name, available, count
            end
        end
    end

    return true
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

    local cargo_container = s["platform_replicator_container"]
    local control_container = s["platform_replicator_control_container"]

    local player = pending.player

    if not player or not player.valid then
        player = get_player(entity, cargo_container, control_container)
    end

    local function fail(message)
        print_fail(s, entity, player, message)
        return
    end

    local new_platform = pending.platform

    if not new_platform or not new_platform.valid then
        return fail("pending space platform disappeared before hub spawn.")
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

    local all_min_x = nil
    local all_min_y = nil
    local all_max_x = nil
    local all_max_y = nil

    local marker_min_x = nil
    local marker_min_y = nil
    local marker_max_x = nil
    local marker_max_y = nil

    local function add_all_bounds(x, y)
        all_min_x = all_min_x and math.min(all_min_x, x) or x
        all_min_y = all_min_y and math.min(all_min_y, y) or y
        all_max_x = all_max_x and math.max(all_max_x, x) or x
        all_max_y = all_max_y and math.max(all_max_y, y) or y
    end

    for _, bp_e in ipairs(bp_entities) do
        local x = bp_e.position.x
        local y = bp_e.position.y

        -- Entity position is its placement/origin point.
        add_all_bounds(x, y)

        if bp_e.name == _marker or bp_e.ghost_name == _marker then
            marker_min_x = marker_min_x and math.min(marker_min_x, x) or x
            marker_min_y = marker_min_y and math.min(marker_min_y, y) or y
            marker_max_x = marker_max_x and math.max(marker_max_x, x) or x
            marker_max_y = marker_max_y and math.max(marker_max_y, y) or y
        end
    end

    for _, bp_t in ipairs(bp_tiles) do
        -- Tile position is the left-top corner of a 1x1 cell.
        -- Include both left-top and right-bottom edges, otherwise blueprint
        -- center shifts by 1 when tile bounds parity changes.
        add_all_bounds(bp_t.position.x, bp_t.position.y)
        add_all_bounds(bp_t.position.x + 1, bp_t.position.y + 1)
    end

    if not marker_min_x then
        temp_inv.destroy()
        return fail("blueprint must contain platform center marker ghost.")
    end

    if not all_min_x then
        temp_inv.destroy()
        return fail("cannot determine blueprint bounds.")
    end

    -- Observed Factorio behavior:
    -- after_position = blueprint_position - all_center + build_position
    --
    -- We want marker_center to become {0,0}, so:
    -- 0 = marker_center - all_center + build_position
    -- build_position = all_center - marker_center
    local all_center = {
        x = math.floor((all_min_x + all_max_x) / 2),
        y = math.floor((all_min_y + all_max_y) / 2)
    }

    local marker_center = {
        x = math.floor((marker_min_x + marker_max_x) / 2),
        y = math.floor((marker_min_y + marker_max_y) / 2)
    }

    local build_position = {
        x = all_center.x - marker_center.x,
        y = all_center.y - marker_center.y
    }

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

    for _, ghost in pairs(target_surface.find_entities_filtered{
        name = "entity-ghost",
        ghost_name = _marker
    }) do
        if ghost.valid then
            ghost.destroy()
        end
    end

    for _, marker in pairs(target_surface.find_entities_filtered{
        name = _marker
    }) do
        if marker.valid then
            marker.destroy()
        end
    end

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

    if player and player.valid and player.connected then
        player.set_controller{
            type = defines.controllers.remote,
            surface = target_surface,
            position = hub.position
        }
    end
end

local function on_tick(entity)
    local s = entity_storage(entity)

    if s["platform_replicator_pending"] then
        finish_pending(entity)
        return
    end

    local cargo_container = s["platform_replicator_container"]
    local control_container = s["platform_replicator_control_container"]

    local player = get_player(entity, cargo_container, control_container)

    local function fail(message)
        print_fail(s, entity, player, message)
        return
    end

    if not cargo_container or not cargo_container.valid then
        return fail("missing cargo container.")
    end

    if not control_container or not control_container.valid then
        return fail("missing control container.")
    end

    local cargo_inv = cargo_container.get_inventory(defines.inventory.chest)

    if not cargo_inv then
        return fail("cargo container has no chest inventory.")
    end

    local control_inv = control_container.get_inventory(defines.inventory.chest)

    if not control_inv then
        return fail("control container has no chest inventory.")
    end

    local blueprint = control_inv[1]

    if not blueprint.valid_for_read then
        return fail("put a blueprint into the first slot of the control container.")
    end

    if not blueprint.is_blueprint then
        return fail("first slot of the control container must contain a blueprint.")
    end

    local bp_entities = blueprint.get_blueprint_entities() or {}
    local bp_tiles = blueprint.get_blueprint_tiles() or {}

    if #bp_entities == 0 and #bp_tiles == 0 then
        return fail("blueprint is empty.")
    end

    local has_marker = false

    for _, bp_e in ipairs(bp_entities) do
        if bp_e.name == _marker or bp_e.ghost_name == _marker then
            has_marker = true
            break
        end
    end

    if not has_marker then
        return fail("blueprint must contain platform center marker ghost.")
    end

    local required = {}

    for _, bp_e in ipairs(bp_entities) do
        local entity_name = bp_e.ghost_name or bp_e.name

        if entity_name ~= _marker then
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
            local quality_name = "normal"

            required[item_name] = required[item_name] or {}
            required[item_name][quality_name] = (required[item_name][quality_name] or 0) + item_count
        else
            return fail("cannot determine item required to place tile: " .. bp_t.name)
        end
    end

    local starter_pack_name = nil
    local starter_pack_quality = nil

    for i = 1, #control_inv do
        local stack = control_inv[i]

        if stack and stack.valid_for_read and stack.type == "space-platform-starter-pack" then
            starter_pack_name = stack.name
            starter_pack_quality = stack.quality and stack.quality.name or "normal"
            break
        end
    end

    if not starter_pack_name then
        return fail("missing space platform starter pack in control container.")
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

    local ok, item_name, quality_name, available, count = check_required(cargo_inv, required)

    if not ok then
        return fail(
            "missing item in cargo container: " ..
            item_name ..
            " [" .. quality_name .. "] " ..
            available .. "/" .. count
        )
    end

    if entity.rocket_silo_status ~= defines.rocket_silo_status.rocket_ready then
        return fail("rocket is not ready.")
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

    local cargo = collect_cargo(cargo_inv)

    local new_platform = entity.force.create_space_platform{
        planet = location.name,
        starter_pack = {
            name = starter_pack_name,
            quality = starter_pack_quality
        }
    }

    if not new_platform then
        return fail("failed to create new space platform.")
    end

    local launched = entity.launch_rocket{
        type = defines.cargo_destination.orbit
    }

    if not launched then
        new_platform.destroy(1)
        return fail("rocket launch failed.")
    end

    local removed_starter_pack = control_inv.remove{
        name = starter_pack_name,
        count = 1,
        quality = starter_pack_quality
    }

    if removed_starter_pack < 1 then
        new_platform.destroy(1)
        return fail("failed to remove starter pack from control container after rocket launch.")
    end

    blueprint.clear()
    clear_inventory(cargo_inv)

    s["platform_replicator_pending"] = {
        platform = new_platform,
        starter_pack_name = starter_pack_name,
        starter_pack_quality = starter_pack_quality,
        blueprint_string = blueprint_string,
        cargo = cargo,
        player = player,
        hub_spawn_tick = game.tick + hub_spawn_delay_ticks
    }

    if player and player.valid and player.connected then
        player.print("[Heliara] Platform replicator: rocket launched, hub will spawn in 15 seconds.")
    end
end

local entity = wrap_for_data(
    function()
        local e = util.table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])

        e.name = nil
        e.minable = {mining_time = 1, result = _name}
        e.rocket_parts_required = 8
        e.fixed_recipe = nil
        e.surface_conditions = {
            {property = "gravity", min = 0, max = 0}
        }
        e.to_be_inserted_to_rocket_inventory_size = 0
        e.launch_to_space_platforms = false

        tint_all(e)

        return e
    end
)

entity.on_build = wrap(function(e)
    local cargo_container = e.surface.create_entity{
        name = _container,
        position = {e.position.x - 2, e.position.y + 2},
        force = e.force,
        create_build_effect_smoke = false
    }

    local control_container = e.surface.create_entity{
        name = _control_container,
        position = {e.position.x + 2, e.position.y + 2},
        force = e.force,
        create_build_effect_smoke = false
    }

    local s = entity_storage(e)
    s[_container] = cargo_container
    s[_control_container] = control_container
end)

entity.on_destroy = wrap(function(e)
    local s = entity_storage(e)

    local cargo_container = s[_container]
    if cargo_container and cargo_container.valid then
        cargo_container.destroy()
    end

    local control_container = s[_control_container]
    if control_container and control_container.valid then
        control_container.destroy()
    end

    for _, c in pairs(e.surface.find_entities_filtered{
        name = {_container, _control_container},
        area = {
            {e.position.x - 2.5, e.position.y + 1.5},
            {e.position.x + 2.5, e.position.y + 2.5}
        }
    }) do
        if c.valid then c.destroy() end
    end
end)

entity.on_tick = wrap(on_tick)

local cargo_container_proto = wrap_for_data(
    function()
        local p = util.table.deepcopy(data.raw["container"]["steel-chest"].picture)
        tint_all(p)

        return {
            type = "container",
            name = _container,
            flags = {"not-on-map"},
            hidden = true,
            inventory_size = 100,
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            picture = p
        }
    end
)

local control_container_proto = wrap_for_data(
    function()
        local p = util.table.deepcopy(data.raw["container"]["steel-chest"].picture)
        tint_all(p)

        return {
            type = "container",
            name = _control_container,
            flags = {"not-on-map"},
            hidden = true,
            inventory_size = 2,
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            picture = p
        }
    end
)

local marker_item_proto = wrap_for_data(
    function()
        return {
            type = "item",
            name = _marker,
            icon = "__base__/graphics/terrain/lab-tiles/lab-white.png",
            icon_size = 32,
            subgroup = "space-platform",
            order = "z[heliara]-a[platform-replicator]-b[center-marker]",
            stack_size = 1,
            hidden = false,
            place_result = _marker
        }
    end
)

local marker_entity_proto = wrap_for_data(
    function()
        return {
            type = "simple-entity-with-owner",
            name = _marker,
            icon = "__base__/graphics/terrain/lab-tiles/lab-white.png",
            icon_size = 32,
            flags = {"placeable-neutral", "player-creation", "not-on-map"},
            max_health = 1,
            collision_mask = {layers = {}},
            collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            render_layer = "air-object",
            picture = {
                filename = "__base__/graphics/terrain/lab-tiles/lab-white.png",
                width = 32,
                height = 32,
                scale = 1,
                tint = _blue
            }
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
            cargo_container_proto,
            control_container_proto,
            marker_item_proto,
            marker_entity_proto
        }
    }
}