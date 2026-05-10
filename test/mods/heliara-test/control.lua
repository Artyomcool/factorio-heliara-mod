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
        "platform_replicator_blueprint_tool", "platform_replicator_blueprint",
    }) do
        local n = name
        t("item/" .. n, function() truthy(prototypes.item[n]) end)
    end
    t("tool/fullerene-science-pack", function()
        truthy(prototypes.item["fullerene-science-pack"])
    end)
    t("shortcut/platform_replicator_blueprint_tool", function()
        truthy(prototypes.shortcut["platform_replicator_blueprint_tool"])
    end)
    t("recipe/platform_replicator_blueprint_tool absent", function()
        if prototypes.recipe["platform_replicator_blueprint_tool"] then
            error("tool must be spawned by shortcut, not crafted")
        end
    end)
    t("platform_replicator_blueprint is blueprint", function()
        local inv = game.create_inventory(1)
        inv[1].set_stack{name = "platform_replicator_blueprint", count = 1}
        truthy(inv[1].is_blueprint, "item stack is not a blueprint")
        inv.destroy()
    end)
    t("platform_replicator_blueprint supports snapshot grid", function()
        local inv = game.create_inventory(1)
        inv[1].set_stack{name = "platform_replicator_blueprint", count = 1}
        inv[1].set_blueprint_entities{
            {entity_number = 1, name = "iron-chest", position = {3, 2}},
        }
        inv[1].blueprint_snap_to_grid = {x = 6, y = 4}
        inv[1].blueprint_absolute_snapping = false
        eq(inv[1].blueprint_absolute_snapping, false, "absolute snapping should be disabled")
        eq(inv[1].blueprint_snap_to_grid.x, 6)
        eq(inv[1].blueprint_snap_to_grid.y, 4)
        eq(inv[1].blueprint_position_relative_to_grid, nil)

        local exported = inv[1].export_stack()
        local imported = game.create_inventory(1)
        eq(imported[1].import_stack(exported), 0)
        eq(imported[1].blueprint_absolute_snapping, false, "relative snapping was not preserved")
        eq(imported[1].blueprint_snap_to_grid.x, 6)
        eq(imported[1].blueprint_snap_to_grid.y, 4)
        eq(imported[1].blueprint_position_relative_to_grid, nil)
        imported.destroy()
        inv.destroy()
    end)

    -- Core entities
    for _, name in ipairs({
        "fullerene_solar_panel", "fullerene_extraction_bath",
        "heliara_assembling_machine", "dryer", "osmosis_pipejack",
        "wireless_pole", "shungite", "brackish_vent", "huge_fullerene_rock",
        "solar_refractor_silo", "fullerene_lab", "platform_replicator",
        "space_platform_rocket",
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

-- ─── Platform replicator setup (runs during --create) ────────────────────

local function setup_platform_replicator_test(force)
    local test_platform
    t("create space platform for replicator test", function()
        test_platform = force.create_space_platform{
            name = "heliara-test-platform",
            planet = "nauvis",
            starter_pack = "space-platform-starter-pack"
        }
        truthy(test_platform and test_platform.valid, "create_space_platform failed")
    end)
    if not test_platform or not test_platform.valid then return end

    local sp_surface
    t("get space platform surface and set tiles", function()
        test_platform.apply_starter_pack()
        sp_surface = test_platform.surface
        truthy(sp_surface and sp_surface.valid, "platform has no valid surface")
        local tiles = {}
        for x = -15, 15 do
            for y = -15, 15 do
                tiles[#tiles + 1] = {name = "space-platform-foundation", position = {x, y}}
            end
        end
        sp_surface.set_tiles(tiles)
    end)
    if not sp_surface or not sp_surface.valid then return end

    local replicator
    t("place platform_replicator on space platform", function()
        local pos = sp_surface.find_non_colliding_position("platform_replicator", {10, 10}, 20, 0.5)
        truthy(pos, "no free position for platform_replicator")
        replicator = sp_surface.create_entity{
            name = "platform_replicator",
            position = pos,
            force = force,
            raise_built = true
        }
        truthy(replicator and replicator.valid, "failed to create platform_replicator")
    end)
    if not replicator or not replicator.valid then return end

    local blueprint_container, cargo_container, starter_pack_container
    t("platform_replicator spawns 3 bound containers on build", function()
        local rx, ry = replicator.position.x, replicator.position.y

        local bp_found = sp_surface.find_entities_filtered{
            name = "platform_replicator_blueprint_container",
            position = {rx - 1.5, ry + 2.5}, radius = 1
        }
        local cargo_found = sp_surface.find_entities_filtered{
            name = "platform_replicator_cargo_container",
            position = {rx, ry + 2.5}, radius = 1
        }
        local sp_found = sp_surface.find_entities_filtered{
            name = "platform_replicator_starter_pack_container",
            position = {rx + 1.5, ry + 2.5}, radius = 1
        }

        truthy(#bp_found > 0, "no blueprint container found")
        truthy(#cargo_found > 0, "no cargo container found")
        truthy(#sp_found > 0, "no starter pack container found")

        blueprint_container = bp_found[1]
        cargo_container = cargo_found[1]
        starter_pack_container = sp_found[1]
    end)
    if not blueprint_container or not cargo_container or not starter_pack_container then return end

    t("setup blueprint, cargo and starter pack in replicator containers", function()
        local bp_inv = blueprint_container.get_inventory(defines.inventory.chest)
        truthy(bp_inv, "blueprint container has no chest inventory")
        bp_inv[1].set_stack{name = "platform_replicator_blueprint", count = 1}
        bp_inv[1].set_blueprint_entities{
            {entity_number = 1, name = "space-platform-hub", position = {3, 3}},
            {entity_number = 2, name = "iron-chest", position = {5, 3}},
        }
        bp_inv[1].blueprint_snap_to_grid = {x = 6, y = 6}
        bp_inv[1].blueprint_absolute_snapping = false

        local cargo_inv = cargo_container.get_inventory(defines.inventory.chest)
        truthy(cargo_inv, "cargo container has no chest inventory")
        cargo_inv.insert{name = "iron-chest", count = 1}

        local sp_inv = starter_pack_container.get_inventory(defines.inventory.chest)
        truthy(sp_inv, "starter pack container has no chest inventory")
        sp_inv.insert{name = "space-platform-starter-pack", count = 1}
    end)
end

local function run_platform_snapshot_tool_tests(force)
    local player = game.players[1]

    if not player then
        log("[TEST] SKIP  platform snapshot tool player-flow  [no player exists in headless --benchmark]")
        return
    end

    local platform
    local sp_surface

    t("snapshot tool test platform created", function()
        platform = force.create_space_platform{
            name = "heliara-test-snapshot-platform",
            planet = "nauvis",
            starter_pack = "space-platform-starter-pack"
        }
        truthy(platform and platform.valid, "create_space_platform failed")
        platform.apply_starter_pack()
        sp_surface = platform.surface
        truthy(sp_surface and sp_surface.valid, "platform has no valid surface")

        local tiles = {}
        for x = -8, 8 do
            for y = -8, 8 do
                tiles[#tiles + 1] = {name = "space-platform-foundation", position = {x, y}}
            end
        end
        sp_surface.set_tiles(tiles)

        local chest = sp_surface.create_entity{
            name = "iron-chest",
            position = {2, 0},
            force = force
        }
        truthy(chest and chest.valid, "failed to create chest for snapshot")
    end)

    if not sp_surface or not sp_surface.valid then return end

    t("platform snapshot tool creates blueprint with entities, tiles and grid", function()
        truthy(player and player.valid, "missing test player")
        truthy(player.cursor_stack, "test player has no cursor stack")

        player.clear_cursor()
        player.teleport({0, 0}, sp_surface)

        script.raise_event(defines.events.on_lua_shortcut, {
            player_index = player.index,
            prototype_name = "platform_replicator_blueprint_tool"
        })

        local cursor = player.cursor_stack
        truthy(cursor and cursor.valid_for_read, "tool did not create cursor stack")
        eq(cursor.name, "platform_replicator_blueprint", "cursor stack is not the platform blueprint item")
        truthy(cursor.is_blueprint, "cursor stack is not a blueprint")

        local entities = cursor.get_blueprint_entities() or {}
        local tiles = cursor.get_blueprint_tiles() or {}
        local snap_to_grid = cursor.blueprint_snap_to_grid
        local has_chest = false

        for _, bp_e in ipairs(entities) do
            if bp_e.name == "iron-chest" then
                has_chest = true
            end
        end

        truthy(has_chest, "snapshot blueprint does not contain test chest")
        truthy(#tiles > 0, "snapshot blueprint does not contain platform tiles")
        eq(cursor.blueprint_absolute_snapping, false, "snapshot blueprint should use relative snapping")
        truthy(snap_to_grid and snap_to_grid.x > 0 and snap_to_grid.y > 0, "snapshot blueprint has no grid size")
        eq(cursor.blueprint_position_relative_to_grid, nil, "relative grid should not have absolute offset")
        player.clear_cursor()
    end)
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
    setup_platform_replicator_test(force)
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

    run_platform_snapshot_tool_tests(force)

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
