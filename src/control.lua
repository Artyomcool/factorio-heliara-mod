require("script.ui")
require("script.reflectors")
require("script.storage")
require("script.dyson_launcher")

local stub = function(...)
end

local platform_blueprint_tool = "platform_replicator_blueprint_tool"
local platform_blueprint = "platform_replicator_blueprint"

local function is_platform_hub_entity(entity)
    return entity and entity.valid and entity.prototype and entity.prototype.type == "space-platform-hub"
end

local blueprintable_tile_names = nil

local function get_blueprintable_tile_names()
    if blueprintable_tile_names then
        return blueprintable_tile_names
    end

    blueprintable_tile_names = {}

    for name, proto in pairs(prototypes.tile) do
        if proto.items_to_place_this and proto.items_to_place_this[1] then
            blueprintable_tile_names[#blueprintable_tile_names + 1] = name
        end
    end

    return blueprintable_tile_names
end

local function make_area(min_x, min_y, max_x, max_y)
    return {
        {math.floor(min_x), math.floor(min_y)},
        {math.ceil(max_x), math.ceil(max_y)}
    }
end

local function shift_blueprint_content(blueprint, dx, dy)
    local entities = blueprint.get_blueprint_entities()

    if entities then
        for _, entity in ipairs(entities) do
            entity.position = {
                x = entity.position.x + dx,
                y = entity.position.y + dy
            }
        end

        blueprint.set_blueprint_entities(entities)
    end

    local tiles = blueprint.get_blueprint_tiles()

    if tiles then
        for _, tile in ipairs(tiles) do
            tile.position = {
                x = tile.position.x + dx,
                y = tile.position.y + dy
            }
        end

        blueprint.set_blueprint_tiles(tiles)
    end
end

local function set_platform_snapshot_grid(blueprint, center, min_x, min_y, max_x, max_y)
    local content_left = math.floor(min_x)
    local content_top = math.floor(min_y)
    local content_right = math.ceil(max_x)
    local content_bottom = math.ceil(max_y)
    local center_x = math.floor(center.x)
    local center_y = math.floor(center.y)
    local half_width = math.max(center_x - content_left, content_right - center_x)
    local half_height = math.max(center_y - content_top, content_bottom - center_y)

    shift_blueprint_content(blueprint, half_width - center_x, half_height - center_y)

    blueprint.blueprint_snap_to_grid = {
        x = half_width * 2,
        y = half_height * 2
    }
    blueprint.blueprint_absolute_snapping = false
end

local function create_platform_snapshot_blueprint(blueprint, force, surface)
    local min_x = nil
    local min_y = nil
    local max_x = nil
    local max_y = nil
    local platform = surface.platform
    local hub = platform and platform.hub

    local function add_bounds(left_top, right_bottom)
        min_x = min_x and math.min(min_x, left_top.x) or left_top.x
        min_y = min_y and math.min(min_y, left_top.y) or left_top.y
        max_x = max_x and math.max(max_x, right_bottom.x) or right_bottom.x
        max_y = max_y and math.max(max_y, right_bottom.y) or right_bottom.y
    end

    for _, entity in pairs(surface.find_entities()) do
        if entity.prototype and entity.prototype.items_to_place_this and entity.prototype.items_to_place_this[1] then
            add_bounds(entity.bounding_box.left_top, entity.bounding_box.right_bottom)
        elseif is_platform_hub_entity(entity) then
            add_bounds(entity.bounding_box.left_top, entity.bounding_box.right_bottom)
        end
    end

    for _, tile in pairs(surface.find_tiles_filtered{name = get_blueprintable_tile_names()}) do
        add_bounds(tile.position, {x = tile.position.x + 1, y = tile.position.y + 1})
    end

    if not is_platform_hub_entity(hub) then
        return false, "current surface has no space platform hub."
    end

    if not min_x then
        return false, "nothing blueprintable found on this platform."
    end

    blueprint.set_stack{name = platform_blueprint, count = 1}
    local area = make_area(min_x, min_y, max_x, max_y)

    blueprint.create_blueprint{
        surface = surface,
        force = force,
        area = area,
        always_include_tiles = true,
        include_entities = true,
        include_modules = true,
        include_station_names = true,
        include_fuel = true
    }

    set_platform_snapshot_grid(blueprint, hub.position, min_x, min_y, max_x, max_y)

    blueprint.label = "Platform snapshot"
    return true
end

local function build_platform_snapshot_blueprint(player, surface)
    if not player.cursor_stack then
        player.print("[Heliara] Platform replicator: no cursor stack available.")
        return
    end

    local ok, err = create_platform_snapshot_blueprint(player.cursor_stack, player.force, surface)

    if not ok then
        player.print("[Heliara] Platform replicator: " .. err)
        return
    end

    player.print("[Heliara] Platform replicator: platform snapshot blueprint created.")
end

local entity_events = {
    on_build = {},
    on_destroy = {},
    on_gui_opened = {},
    on_gui_destroy = {},
}

local on_nth_tick = {}

for _, to_declares in ipairs(require("entities")) do
    for _, to_declare in ipairs(to_declares) do
        local common = to_declare.common or {}
        local entity = to_declare.entity or {}
        local name = entity.name or common.name

        local function add(e, name)
            for k, table in pairs(entity_events) do
                local h = e[k]
                if h then
                    table[name] = h
                end
            end

            for n, fn in pairs(e.on_nth_tick or {}) do
                local subn = on_nth_tick[n]
                if not subn then
                    subn = {}
                    on_nth_tick[n] = subn
                end
                subn[name] = fn
            end
        end

        add(entity, name)

        for _, child in ipairs(entity.bound_entities or {}) do
            add(child, child.name)
        end

        local nth_tick = entity.on_nth_tick
        if entity.bound_entities or nth_tick then
            local f1 = entity_events.on_build[name] or stub
            entity_events.on_build[name] = function(e)
                for n, fn in pairs(nth_tick or {}) do
                    ticking_nth(n)[e.unit_number] = e
                end
                local s = entity_storage(e)
                s.entity = e
                for _, child in ipairs(entity.bound_entities or {}) do
                    local offset = child.offset or {0, 0}
                    s[child.name] = e.surface.create_entity {
                        name = child.name,
                        position = {e.position.x + offset[1], e.position.y + offset[2]},
                        force = e.force,
                        create_build_effect_smoke = false
                    }
                end
                f1(e)
            end

            local f2 = entity_events.on_destroy[name] or stub
            entity_events.on_destroy[name] = function(e)
                for n, fn in pairs(nth_tick or {}) do
                    ticking_nth(n)[e.unit_number] = e
                end
                local s = entity_storage(e)
                for _, child in ipairs(entity.bound_entities or {}) do
                    local c = s[child.name]
                    if c then
                        c.destroy()
                    end
                end
                entity_storage_destroy(e)
                f2(e)
            end
        elseif name then
            entity_events.on_build[name] = function(e)
                if e.unit_number then
                    entity_storage(e).entity = e
                end
            end
            entity_events.on_destroy[name] = function(e)
                if e.unit_number then
                    entity_storage_destroy(e)
                end
            end
        end
    end
end

script.on_event(defines.events.on_surface_deleted, function(event)
    surface_storage_destroy(event.surface_index)
end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]

    if surface.name == "heliara" then
        -- we want a precise control here
        surface.daytime_parameters = daytime_parameters(0.2, 0.2)
        surface.solar_power_multiplier = 1
    --[[ elseif surface.name == "heliashade" then
        surface.daytime = (surface.evening + surface.morning) / 2
        surface.freeze_daytime = true
        surface.show_clouds = false

        local s = table.deepcopy(surface.map_gen_settings)
        s.width = 256 + 128
        s.height = 128 + 128
        surface.map_gen_settings = s ]]
    end
end)

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    local cargo_pod = event.cargo_pod
    if cargo_pod.name == "cargo-pod-no-payload" then
        cargo_pod.destroy()
        return
    end

    local container = event.spawned_container
    if not container then
        return
    end

end)

local function on_platform_blueprint_tool_selected(event)
    if event.item ~= platform_blueprint_tool then
        return
    end

    local player = game.get_player(event.player_index)

    if not player or not player.valid then
        return
    end

    local surface = event.surface

    if not surface or not surface.valid then
        return
    end

    if not surface.platform then
        player.print("[Heliara] Platform replicator: use this tool on a space platform.")
        return
    end

    build_platform_snapshot_blueprint(player, surface)
end

local function on_platform_blueprint_shortcut(event)
    if event.prototype_name ~= platform_blueprint_tool then
        return
    end

    local player = game.get_player(event.player_index)

    if not player or not player.valid then
        return
    end

    local surface = player.surface

    if not surface or not surface.valid then
        return
    end

    if not surface.platform then
        player.print("[Heliara] Platform replicator: use this shortcut while viewing a space platform.")
        return
    end

    player.clear_cursor()
    build_platform_snapshot_blueprint(player, surface)
end

script.on_event(defines.events.on_lua_shortcut, on_platform_blueprint_shortcut)
script.on_event(defines.events.on_player_selected_area, on_platform_blueprint_tool_selected)
script.on_event(defines.events.on_player_alt_selected_area, on_platform_blueprint_tool_selected)

script.on_event(
        {
            defines.events.on_built_entity,
            defines.events.on_robot_built_entity,
            defines.events.script_raised_built,
            defines.events.script_raised_revive,
            defines.events.on_space_platform_built_entity
        }, function(event)
            local entity = event.created_entity or event.entity
            if not entity or not entity.valid then
                return
            end
            local f = entity_events.on_build[entity.name]
            if f then
                f(entity)
            end
        end)

script.on_event(
        {
            defines.events.on_player_mined_entity,
            defines.events.on_robot_mined_entity,
            defines.events.on_entity_died,
            defines.events.script_raised_destroy,
            defines.events.on_space_platform_mined_entity
        }, function(event)
            local f = entity_events.on_destroy[event.entity.name]
            if f then
                f(event.entity)
            end
        end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity then
        local f = entity_events.on_gui_opened[event.entity.name]
        if f then
            f(game.players[event.player_index], event.entity)
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity then
        local f = entity_events.on_gui_destroy[event.entity.name]
        if f then
            f(game.players[event.player_index], event.entity)
        end
    end
end)

script.on_event(defines.events.on_forces_merging, function(event)
    force_storage_destroy(event.source)
end)

for n, subn in pairs(on_nth_tick) do
    script.on_nth_tick(n, function(event)
        for _, entity in pairs(ticking_nth(n)) do
            if entity.valid then
                -- fixme cleanup?
                (subn[entity.name] or stub)(entity)
            end
        end
    end)
end
