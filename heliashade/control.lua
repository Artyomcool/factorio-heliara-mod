require("common.storage")
require("script.ui")
require("script.dyson_swarm")
require("script.dyson_launcher")

require("common.events")(require("entities"))

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
    local center_x = math.floor(center.x)
    local center_y = math.floor(center.y)
    local half_width = math.max(center_x - math.floor(min_x), math.ceil(max_x) - center_x)
    local half_height = math.max(center_y - math.floor(min_y), math.ceil(max_y) - center_y)

    shift_blueprint_content(blueprint, half_width - center_x, half_height - center_y)

    blueprint.blueprint_snap_to_grid = {
        x = half_width * 2,
        y = half_height * 2
    }
    blueprint.blueprint_absolute_snapping = false
end

local function create_platform_snapshot_blueprint(blueprint, force, surface)
    local min_x, min_y, max_x, max_y
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

    blueprint.create_blueprint{
        surface = surface,
        force = force,
        area = make_area(min_x, min_y, max_x, max_y),
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
        player.print("[Heliashade] Platform replicator: no cursor stack available.")
        return
    end

    local ok, err = create_platform_snapshot_blueprint(player.cursor_stack, player.force, surface)

    if not ok then
        player.print("[Heliashade] Platform replicator: " .. err)
        return
    end

    player.print("[Heliashade] Platform replicator: platform snapshot blueprint created.")
end

local function on_platform_blueprint_tool_selected(event)
    if event.item ~= platform_blueprint_tool then
        return
    end

    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end

    local surface = event.surface
    if not surface or not surface.valid then return end

    if not surface.platform then
        player.print("[Heliashade] Platform replicator: use this tool on a space platform.")
        return
    end

    build_platform_snapshot_blueprint(player, surface)
end

local function on_platform_blueprint_shortcut(event)
    if event.prototype_name ~= platform_blueprint_tool then
        return
    end

    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end

    local surface = player.surface
    if not surface or not surface.valid then return end

    if not surface.platform then
        player.print("[Heliashade] Platform replicator: use this shortcut while viewing a space platform.")
        return
    end

    player.clear_cursor()
    build_platform_snapshot_blueprint(player, surface)
end

script.on_event(defines.events.on_lua_shortcut, on_platform_blueprint_shortcut)
script.on_event(defines.events.on_player_selected_area, on_platform_blueprint_tool_selected)
script.on_event(defines.events.on_player_alt_selected_area, on_platform_blueprint_tool_selected)

script.on_event(defines.events.on_surface_deleted, function(event)
    surface_storage_destroy(event.surface_index)
end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]

    if surface.name == "heliashade" then
        surface.daytime = (surface.evening + surface.morning) / 2
        surface.freeze_daytime = true
        surface.show_clouds = false

        local s = table.deepcopy(surface.map_gen_settings)
        s.width = 256 + 128
        s.height = 128 + 128
        surface.map_gen_settings = s
    end
end)

script.on_event(defines.events.on_forces_merging, function(event)
    force_storage_destroy(event.source)
end)
