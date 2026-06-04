local function declare_data(lessons)
    for _, lesson in ipairs(lessons) do
        if lesson.category then
            local c = lesson.category
            data:extend({{
                type = "tips-and-tricks-item-category",
                name = c.name,
                order = c.order,
                localised_name = c.localised_name,
            }})
        end
        if lesson.tip then
            local t = lesson.tip
            data:extend({{
                type = "tips-and-tricks-item",
                name = t.name,
                category = t.category,
                order = t.order,
                indent = t.indent or 0,
                is_title = t.is_title or false,
                trigger = t.trigger,
                skip_trigger = t.skip_trigger,
                dependencies = t.dependencies,
                tag = t.tag,
                image = t.image,
                simulation = t.simulation,
                localised_name = t.localised_name,
                localised_description = t.localised_description,
            }})
        end
    end
end

local function setup_events(lessons)
    local on_research = {}
    local on_first_visit = {}

    for _, lesson in ipairs(lessons) do
        for tech, fn in pairs(lesson.on_research or {}) do
            on_research[tech] = fn
        end
        for surface, fn in pairs(lesson.on_first_visit or {}) do
            on_first_visit[surface] = fn
        end
    end

    if next(on_research) then
        script.on_event(defines.events.on_research_finished, function(event)
            local fn = on_research[event.research.name]
            if fn then fn(event.research, event) end
        end)
    end

    if next(on_first_visit) then
        script.on_event(defines.events.on_player_changed_surface, function(event)
            local player = game.get_player(event.player_index)
            if not player then return end
            local surface_name = player.surface.name
            local fn = on_first_visit[surface_name]
            if not fn then return end

            storage.tutorial_first_visit = storage.tutorial_first_visit or {}
            local key = surface_name .. ":" .. event.player_index
            if storage.tutorial_first_visit[key] then return end
            storage.tutorial_first_visit[key] = true

            fn(player, event)
        end)
    end
end

return {
    data = declare_data,
    events = setup_events,
}
