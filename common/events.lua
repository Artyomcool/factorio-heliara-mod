local function setup(entities)
    local stub = function(...) end

    local entity_events = {
        on_build = {},
        on_destroy = {},
        on_gui_opened = {},
        on_gui_destroy = {},
    }
    local on_nth_tick = {}

    for _, to_declares in ipairs(entities) do
        for _, to_declare in ipairs(to_declares) do
            local common = to_declare.common or {}
            local entity = to_declare.entity or {}
            local name = entity.name or common.name

            local function add(e, ename)
                for k, tbl in pairs(entity_events) do
                    local h = e[k]
                    if h then
                        tbl[ename] = h
                    end
                end

                for n, fn in pairs(e.on_nth_tick or {}) do
                    local subn = on_nth_tick[n]
                    if not subn then
                        subn = {}
                        on_nth_tick[n] = subn
                    end
                    subn[ename] = fn
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

    for n, subn in pairs(on_nth_tick) do
        script.on_nth_tick(n, function(event)
            for _, entity in pairs(ticking_nth(n)) do
                if entity.valid then
                    (subn[entity.name] or stub)(entity)
                end
            end
        end)
    end

    return entity_events
end

return setup
