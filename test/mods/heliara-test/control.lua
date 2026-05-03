-- Heliara automated test suite
-- Phase 1 (on_init / --create):  prototype checks + runtime placement checks
-- Phase 2 (on_tick 5 / --benchmark): save/load persistence check

local results = { pass = 0, fail = 0 }
local errors  = {}

local function ok(name)
    results.pass = results.pass + 1
    log("[TEST] PASS  " .. name)
end

local function fail(name, reason)
    results.fail = results.fail + 1
    table.insert(errors, name .. ": " .. tostring(reason))
    log("[TEST] FAIL  " .. name .. "  [" .. tostring(reason) .. "]")
end

local function t(name, fn)
    local success, err = pcall(fn)
    if success then ok(name) else fail(name, err) end
end

local function eq(a, b, msg)
    if a ~= b then
        error((msg or "") .. " expected=" .. tostring(b) .. " got=" .. tostring(a), 2)
    end
end

local function truthy(v, msg)
    if not v then error(msg or ("expected non-nil, got " .. tostring(v)), 2) end
end

local function no_copper(ingredients)
    local copper = { ["copper-ore"]=true, ["copper-plate"]=true, ["copper-cable"]=true }
    for _, ing in pairs(ingredients) do
        if copper[ing.name] then error("contains " .. ing.name) end
    end
end

local function finish(phase)
    local total = results.pass + results.fail
    if results.fail == 0 then
        log(string.format("[TEST_PASS] %s — all %d tests passed", phase, total))
    else
        log(string.format("[TEST_FAIL] %s — %d/%d tests failed", phase, results.fail, total))
        for _, e in ipairs(errors) do log("[TEST_FAIL]   " .. e) end
    end
end

-- ─── Prototype checks (no surface needed) ────────────────────────────────

local function run_prototype_tests()
    -- Core items (carbon_coal is resource-only; science pack is type "tool")
    for _, name in ipairs({
        "fullerene", "shungite", "graphite", "graphite_circuit",
        "silicon_substrate", "brick_dust", "osmosis_filter",
        "fast_burner_inserter", "long_burner_inserter",
        "silcrete", "fullerene_solar_panel",
        "fullerene_extraction_bath", "heliara_assembling_machine",
        "dryer", "osmosis_pipejack", "wireless_pole",
    }) do
        local n = name
        t("item/" .. n, function() truthy(prototypes.item[n]) end)
    end
    t("tool/fullerene-science-pack", function()
        truthy(prototypes.item["fullerene-science-pack"])
    end)

    -- Core entities
    for _, name in ipairs({
        "fullerene_solar_panel", "fullerene_extraction_bath",
        "heliara_assembling_machine", "dryer", "osmosis_pipejack",
        "wireless_pole", "shungite", "brackish_vent", "huge_fullerene_rock",
        "solar_refractor_silo", "fullerene_lab",
    }) do
        local n = name
        t("entity/" .. n, function() truthy(prototypes.entity[n]) end)
    end

    -- Core technologies
    for _, name in ipairs({
        "planet-discovery-heliara", "fullerene_extraction_bath",
        "carbon-electrolitic-processing", "silicon_substrate",
        "graphite_circuit", "heliara_assembling_machine", "steam_cargo",
        "osmosis_pipejack", "solar_refractor",
    }) do
        local n = name
        t("tech/" .. n, function() truthy(prototypes.technology[n]) end)
    end

    -- Fuel system
    t("fuel-category/solar_fuel", function()
        -- prototypes["fuel-category"] was removed in Factorio 2.0; verify via item instead
        local item = prototypes.item["fullerene"]
        truthy(item, "fullerene item not found")
        eq(item.fuel_category, "solar_fuel")
    end)

    t("fullerene.fuel_value > 0", function()
        local item = prototypes.item["fullerene"]
        truthy(item, "item not found")
        truthy(item.fuel_value and item.fuel_value > 0,
               "fuel_value=" .. tostring(item and item.fuel_value))
    end)

    t("fullerene_solar_panel entity type == solar-panel", function()
        local proto = prototypes.entity["fullerene_solar_panel"]
        truthy(proto)
        eq(proto.type, "solar-panel")
    end)

    -- No copper in Heliara recipes
    local checked_recipes = {
        "fullerene", "fullerene-from-shungite", "fullerene-from-graphite",
        "graphite", "graphite-from-shungite", "graphite-from-carbon",
        "carbon-from-shungite", "silicon_substrate", "graphite_circuit",
        "fullerene_extraction_bath", "heliara_assembling_machine", "dryer",
        "osmosis_pipejack", "osmosis_filter", "wireless_pole",
        "fullerene_solar_panel", "fullerene_lab", "brick_dust",
        "fast_burner_inserter", "long_burner_inserter",
        "graphite-automation-science-pack", "graphite-logistic-science-pack",
        "graphite-chemical-science-pack", "graphite-production-science-pack",
    }
    for _, rname in ipairs(checked_recipes) do
        local rn = rname
        t("recipe/" .. rn .. " — no copper", function()
            local recipe = prototypes.recipe[rn]
            truthy(recipe, "recipe not found")
            no_copper(recipe.ingredients)
        end)
    end
end

-- ─── Runtime checks (surface needed) ─────────────────────────────────────

local function run_runtime_tests(surface, force)
    t("heliara surface valid", function()
        truthy(surface and surface.valid)
    end)

    t("heliara solar_power_multiplier == 1 on fresh surface", function()
        eq(surface.solar_power_multiplier, 1)
    end)

    -- Lay down a buildable tile patch so find_non_colliding_position can succeed.
    -- Most heliara tiles are non-buildable; use heliara_weathered_siliceous_crust.
    local tiles = {}
    for x = 50, 250 do
        for y = 50, 150 do
            tiles[#tiles + 1] = {name = "heliara_weathered_siliceous_crust", position = {x, y}}
        end
    end
    surface.set_tiles(tiles)

    -- Place & destroy each key entity — verifies build placement works
    local placeable = {
        "fullerene_solar_panel", "fullerene_extraction_bath",
        "heliara_assembling_machine", "osmosis_pipejack", "wireless_pole",
    }
    for _, name in ipairs(placeable) do
        local n = name
        t("place+destroy " .. n, function()
            local pos = surface.find_non_colliding_position(n, {100, 100}, 30, 0.5)
            truthy(pos, "no free position found")
            local e = surface.create_entity{name=n, position=pos, force=force}
            truthy(e and e.valid, "create_entity returned nil")
            e.destroy()
        end)
    end

    -- Bound entity spawned on build: burner-generator appears at same position
    t("bound burner-generator spawned on build", function()
        local pos = surface.find_non_colliding_position(
                "fullerene_solar_panel", {150, 100}, 30, 0.5)
        truthy(pos)
        local e = surface.create_entity{
            name="fullerene_solar_panel", position=pos, force=force, raise_built=true}
        truthy(e and e.valid)
        local generators = surface.find_entities_filtered{
            name="hidden-burner-generator", position=pos, radius=2}
        truthy(#generators > 0, "no burner-generator found at panel position")
        e.destroy()
    end)

    -- Leave one panel alive so --benchmark can verify save/load persistence
    local pos = surface.find_non_colliding_position(
            "fullerene_solar_panel", {200, 100}, 30, 0.5)
    if pos then
        local e = surface.create_entity{
            name="fullerene_solar_panel", position=pos, force=force, raise_built=true}
        if e and e.valid then
            storage._test_persistent_unit = e.unit_number
        end
    end
end

-- ─── on_init (runs during --create) ──────────────────────────────────────

script.on_init(function()
    log("[TEST] ── on_init phase ──────────────────────────")

    run_prototype_tests()

    -- Create heliara surface; fires heliara's on_surface_created synchronously
    if not game.surfaces["heliara"] then
        game.planets["heliara"].create_surface()
    end

    local surface = game.surfaces["heliara"]
    local force   = game.forces["player"]

    run_runtime_tests(surface, force)
    finish("on_init")

    -- Reset for tick phase
    results = {pass = 0, fail = 0}
    errors  = {}
    storage._test_tick_done = false
end)

-- ─── on_tick (runs during --benchmark) ───────────────────────────────────

script.on_event(defines.events.on_tick, function(event)
    if storage._test_tick_done then return end
    if event.tick < 5 then return end
    storage._test_tick_done = true

    log(string.format("[TEST] ── on_tick phase (tick %d) ──────────────────", event.tick))

    local surface = game.surfaces["heliara"]
    local force   = game.forces["player"]

    -- Save/load: entity placed in on_init must survive into --benchmark
    t("persistent entity survives save/load", function()
        truthy(storage._test_persistent_unit ~= nil,
               "unit_number not written during on_init")
        local entities = surface.find_entities_filtered{name="fullerene_solar_panel"}
        local found = false
        for _, e in ipairs(entities) do
            if e.unit_number == storage._test_persistent_unit then
                found = true; break
            end
        end
        truthy(found, "unit=" .. tostring(storage._test_persistent_unit) .. " not found after load")
    end)

    -- Bound generator should also survive save/load alongside the panel
    t("bound burner-generator survives save/load", function()
        local un = storage._test_persistent_unit
        if not un then return end
        local entities = surface.find_entities_filtered{name="fullerene_solar_panel"}
        local panel_pos
        for _, e in ipairs(entities) do
            if e.unit_number == un then panel_pos = e.position; break end
        end
        truthy(panel_pos, "persistent panel not found")
        local generators = surface.find_entities_filtered{
            name="hidden-burner-generator", position=panel_pos, radius=2}
        truthy(#generators > 0, "bound burner-generator missing after save/load")
    end)

    -- Destroying panel (with raise_destroy=true) also removes its bound generator
    t("destroying panel removes bound generator", function()
        local un = storage._test_persistent_unit
        if not un then return end
        local entities = surface.find_entities_filtered{name="fullerene_solar_panel"}
        for _, e in ipairs(entities) do
            if e.unit_number == un then
                local pos = e.position
                e.destroy{raise_destroy=true}
                local generators = surface.find_entities_filtered{
                    name="hidden-burner-generator", position=pos, radius=2}
                truthy(#generators == 0,
                       "bound burner-generator still alive after panel destroy")
                break
            end
        end
    end)

    -- Swarm state should be zero on a fresh game
    t("swarm_size == 0 on fresh game", function()
        local fst = storage.forces and storage.forces[force.index]
        local swarm = fst and fst.swarm_size or 0
        eq(swarm, 0)
    end)

    -- Reflectors state should be zero on a fresh game
    t("reflectors_count == 0 on fresh game", function()
        local sst = storage.surfaces and storage.surfaces[surface.index]
        local count = sst and sst.reflectors_count or 0
        eq(count, 0)
    end)

    finish("on_tick")
end)
