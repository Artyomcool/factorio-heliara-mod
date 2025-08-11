require("script.ui")
require("script.reflectors")
require("script.storage")
require("script.dyson_launcher")

local stub = function (...) end

local entity_events = {
    on_build = {},
    on_destroy = {},
    on_gui_opened = {},
    on_gui_destroy = {},
    on_tick = {},
}

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
        end

        add(entity, name)

        for _, child in ipairs(entity.bound_entities or {}) do
            add(child, child.name)
        end

        local tick = entity.on_tick
        if entity.bound_entities or tick then
            local f1 = entity_events.on_build[name] or stub
            entity_events.on_build[name] = function (e)
                if tick then
                    ticking()[e.unit_number] = e
                end
                local s = entity_storage(e)
                s.entity = e
                for _, child in ipairs(entity.bound_entities or {}) do
                    s[child.name] = e.surface.create_entity {
                        name = child.name,
                        position = e.position,
                        force = e.force,
                        create_build_effect_smoke = false
                    }
                end
                f1(e)
            end

            local f2 = entity_events.on_destroy[name] or stub
            entity_events.on_destroy[name] = function (e)
                if tick then
                    ticking()[e.unit_number] = nil
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
            entity_events.on_build[name] = function (e)
                if e.unit_number then
                    entity_storage(e).entity = e
                end
            end
            entity_events.on_destroy[name] = function (e)
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
  end
end)

create_heliara_for_player = nil
next_tick = {}

folders_open = {}

local function split_by_slash(input)
  local result = {}
  for part in string.gmatch(input, "[^/]+") do
    table.insert(result, part)
  end
  return result
end

local function show_gui()
    local player = game.get_player(1)
    local root = player.gui.screen
    root.clear()
    local frame = root.add{type="frame", name='relfectors_info', caption='[item=solar_refractor] Reflectors Info'}
    frame.style.natural_width = 400
    --frame.style.maximal_height = player.display_resolution.height
    local parent = frame.add{type="scroll-pane", name="pparent"}
    local planets = parent.add{type = "list-box", name="planets"}
    local platforms = parent.add{type = "list-box", name="platforms"}
    platforms.style.font = "mono"
    local platforms_tree = {children = {}}
    for _, value in pairs(game.surfaces) do
        if value.planet then
            planets.add_item({"", "[planet=" .. value.planet.prototype.name .. "] ", value.planet.prototype.localised_name})
        elseif value.platform then
            local name = value.platform.name
            local name_splited = split_by_slash(name)
            local current_name = ''
            local node = platforms_tree.children
            for i, p in ipairs(name_splited) do
                if i == table_size(name_splited) then
                    node[p] = {level = i, full_name=name, short_name=p, platform=value.platform}
                else
                    local pp = p .. '/'
                    current_name = current_name .. pp
                    local children = nil
                    if not node[pp] then
                        children = {}
                        node[pp] = {level = i, full_name=current_name, short_name=p, children=children}
                    else
                        children = node[pp].children
                    end
                    node = children
                end
            end
        end
    end

    local queue = {platforms_tree}
    while queue[1] do
        local now = table.remove(queue, 1)
            game.print(now.short_name)
        if now.short_name then
            local e = ''
            for _ = 2, now.level, 1 do
                e = e .. '[virtual-signal=shape-vertical]'
            end
            e = e .. '[virtual-signal=shape-t-4]'
            if now.children then
                e = e .. '[virtual-signal=shape-t]'
            else
                e = e .. '[virtual-signal=shape-horizontal]'
            end
            platforms.add_item(e .. now.short_name)
        end

        if now.children then
            local lst = {}
            for _, value in pairs(now.children) do
                table.insert(lst, value)
            end

            table.sort(lst, function (a, b)
                return a.short_name > b.short_name
            end)

            for _, value in ipairs(lst) do
                table.insert(queue, 1, value)
            end
        end
    end
end


local function show_drag_gui()
    local player = game.get_player(1)
    local root = player.gui.screen
    root.clear()
   local frame = root.add{
    type = "frame",
    name = "source_frame",
    direction = "vertical",
    caption = "Source"
  }
  frame.location = {200, 200}

  frame.add{
    type = "sprite-button",
    name = "item_iron_plate",
    sprite = "item/iron-plate",
    style = "slot_button"
  }

  local drop = root.add{
    type = "frame",
    name = "target_frame",
    direction = "vertical",
    caption = "Target"
  }
  drop.location = {600, 200}

end

local function after_reload()
    game.print("Reloaded!")
end

-- remove on release
commands.add_command("re", nil, function(command)
    storage["reload"] = command.player_index
    game.reload_mods()
end)

script.on_load(function()
    if storage["reload"] then
        table.insert(next_tick, function ()
            local pi = storage["reload"]
            storage["reload"] = nil
            if game.surfaces["heliara"] then
                create_heliara_for_player = game.get_player(pi)
                game.delete_surface("heliara")
            else
                game.planets["heliara"].create_surface()
                game.players[pi].teleport({0,0}, "heliara")
            end
            after_reload()
        end);
    end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
    if create_heliara_for_player ~= nil then
        game.planets["heliara"].create_surface()
        create_heliara_for_player.teleport({0,0}, "heliara")
        create_heliara_for_player = nil
    end
end)

script.on_event(defines.events.on_tick, function(event)
    for _, entity in pairs(ticking()) do
        if entity.valid then    -- fixme cleanup?
            (entity_events.on_tick[entity.name] or stub)(entity)
        end
    end
    local t = next_tick
    next_tick = {}
    for _, value in ipairs(t) do
        value()
    end
end)

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
    if f then f(entity) end
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
    if f then f(event.entity) end
end)

next_player = nil

script.on_event(defines.events.on_player_controller_changed, function (event)
    next_player = game.get_player(event.player_index)
    if next_player.controller_type == defines.controllers.remote then
        --show_gui()
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity then
        local f = entity_events.on_gui_opened[event.entity.name]
        if f then f(game.players[event.player_index], event.entity) end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity then
        local f = entity_events.on_gui_destroy[event.entity.name]
        if f then f(game.players[event.player_index], event.entity) end
    end
end)

script.on_event(defines.events.on_forces_merging, function (event)
    force_storage_destroy(event.source)
end)