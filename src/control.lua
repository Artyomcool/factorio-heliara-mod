local function serializeUi(ui, depth)
    if ui == nil then return "nil" end
    if not ui.visible then return "invisible" end
    local tmp = "{\n"

    for _ = 0, depth do
        tmp = tmp .. " "
    end
    tmp = tmp .. "name = " .. ui.name .. "\n"

    for _ = 0, depth do
        tmp = tmp .. " "
    end
    tmp = tmp .. "caption = " .. tostring(ui.caption) .. "\n"

    for _ = 0, depth do
        tmp = tmp .. " "
    end
    tmp = tmp .. "type = " .. ui.type .. "\n"


    if ui.type == "list-box" then
        for _ = 0, depth do
            tmp = tmp .. " "
        end
        tmp = tmp .. "items = {\n"

        for n, v in pairs(ui.items) do
            for _ = 0, depth do
                tmp = tmp .. " "
            end
            tmp = tmp .. n .. " = " .. serializeUi(v, depth + 1) .. "\n"
        end
        for _ = 0, depth do
            tmp = tmp .. " "
        end
        tmp = tmp .. "}\n"
    end
    for _ = 0, depth do
        tmp = tmp .. " "
    end
    tmp = tmp .. "children = {\n"

    for n, v in pairs(ui.children) do
        for _ = 0, depth do
            tmp = tmp .. " "
        end
        tmp = tmp .. n .. " = " .. serializeUi(v, depth + 1) .. "\n"
    end
    for _ = 0, depth do
        tmp = tmp .. " "
    end
    tmp = tmp .. "}\n"

    for _ = 1, depth do
        tmp = tmp .. " "
    end
    return tmp .. "}"
end

local function serializeUiTable(ui, depth)
    if ui == nil then return "nil" end

    local tmp = "{\n"

    for n, v in pairs(ui) do
        for i = 1, depth do
            tmp = tmp .. " "
        end
        tmp = tmp .. n .. " = " .. serializeUi(v, depth + 1) .. "\n"
    end

    for _ = 1, depth do
        tmp = tmp .. " "
    end
    return tmp .. "}"

end

script.on_event(defines.events.on_selected_entity_changed , function(event)
    local entity = event.last_entity
    --if entity == nil then return end
    --if game.player == nil or event.player_index ~= game.player.index then return end
    local gui = game.get_player(event.player_index).gui
    --log("{\n top = " .. serializeUi(gui.top, 1) .. "\n left = " .. serializeUi(gui.left, 1) .. "\n center = " ..
    --        serializeUi(gui.center, 1) .. "\n goal = " .. serializeUi(gui.goal, 1)  .. "\n screen  = " ..
    --        serializeUi(gui.screen , 1) .. "\n relative = " .. serializeUi(gui.relative , 1) ..
    --        "\n children  = " .. serializeUiTable(gui.children , 1) .. "\n}")
end)

script.on_event(defines.events.on_tick, function(event)
    if (storage.links == nil) then
        return
    end
    for _, v in pairs(storage.links) do
        local burner = v.burner
        burner.energy = 0
        local was_active = v.panel ~= nil
        local now_active = burner.burner.currently_burning ~= nil

        if was_active then
            if not now_active then
                v.pole.destroy()
                v.panel.destroy()
                v.pole = nil
                v.panel = nil
            end
        elseif now_active then
            local surface = burner.surface
            local position = burner.position

            v.panel = surface.create_entity {
                name = "solar-panel-hidden-panel",
                position = burner.position,
                force = burner.force,
                create_build_effect_smoke = false
            }

            v.pole = surface.create_entity {
                name = "solar-panel-hidden-pole",
                position = position,
                force = burner.force,
                create_build_effect_smoke = false,
                auto_connect = false
            }
        end

    end
end)

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity or event.entity
    if not entity.valid then
        return
    end

    if entity.name == "fullerene_solar_panel" then
        storage.links = storage.links or {}
        storage.links[entity.unit_number] = { burner = entity }
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity.name == "fullerene_solar_panel" then
        local links = storage.links[entity.unit_number]
        if links.panel then links.panel.destroy() end
        if links.pole then links.pole.destroy() end
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity.name == "fullerene_solar_panel" then
        local links = storage.links[entity.unit_number]
        if links.panel then links.panel.destroy() end
        if links.pole then links.pole.destroy() end
        storage.links[entity.unit_number] = null
    end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    if not surface or surface.name ~= "heliara" then
        return
    end

    local area = event.area
    local seed = (event.area.left_top.x + 10000) * 7919 + (event.area.left_top.y + 10000) * 1543
    local rng = game.create_random_generator(seed % 4294967296)

    -- chance of a puddle on the chunk
    if rng(1, 100) > 4 then
        return
    end  -- 4% chance

    -- random position in a chunk (within the area)
    local x = rng(area.left_top.x, area.left_top.x + 31)
    local y = rng(area.left_top.y, area.left_top.y + 31)

    -- puddle size (1–3 tiles)
    local size = rng(1, 3)

    local tiles = {}
    for dx = 0, size - 1 do
        for dy = 0, size - 1 do
            table.insert(tiles, { name = "water", position = { x + dx, y + dy } })
        end
    end

    surface.set_tiles(tiles, true)
end)
