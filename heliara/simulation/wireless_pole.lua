game.simulation.camera_position = {0, 0.75}
game.simulation.camera_zoom = 0.85
local s = game.surfaces[1]
s.freeze_daytime = true
s.daytime = 0.18

s.request_to_generate_chunks({0, 0}, 3)
s.force_generate_chunk_requests()

for _, entity in pairs(s.find_entities_filtered{area = {{-25, -18}, {25, 18}}}) do
    if entity.valid and entity.type ~= "character" then
        entity.destroy()
    end
end

s.create_decoratives{decoratives = {
    {name = "heliara_tiny_rock_1", position = {-8, -3}, amount = 1},
    {name = "heliara_tiny_rock_2", position = {-6, 4}, amount = 1},
    {name = "heliara_tiny_rock_3", position = {8, -2}, amount = 1},
    {name = "heliara_cracks", position = {5, 4}, amount = 1},
}}

local function feed(p)
    local h = s.find_entities_filtered{
        name = "hidden-burner-generator",
        position = p.position,
        radius = 1,
    }[1]
    if h and h.valid then h.insert{name = "fullerene", count = 100} end
end

local panel = s.create_entity{
    name = "fullerene_solar_panel",
    position = {-6, -1},
    force = "player",
    raise_built = true,
}
feed(panel)
script.on_nth_tick(600, function() if panel.valid then feed(panel) end end)

local source_pole = s.create_entity{name = "wireless_pole", position = {-3.5, -1}, force = "player"}
local powered_pole = s.create_entity{name = "wireless_pole", position = {-1, -1}, force = "player"}

local powered_lamp_1 = s.create_entity{name = "small-lamp", position = {-4.5, 1.5}, force = "player"}
local powered_lamp_2 = s.create_entity{name = "small-lamp", position = {-2.5, 1.5}, force = "player"}
powered_lamp_1.always_on = true
powered_lamp_2.always_on = true

local chained_pole = s.create_entity{name = "wireless_pole", position = {1.5, -1}, force = "player"}
local dark_lamp_1 = s.create_entity{name = "small-lamp", position = {1.5, 1.5}, force = "player"}
local dark_lamp_2 = s.create_entity{name = "small-lamp", position = {3.5, 1.5}, force = "player"}
dark_lamp_1.always_on = true
dark_lamp_2.always_on = true

local assembler = s.create_entity{
    name = "assembling-machine-2",
    position = {-3.5, 4},
    force = "player",
}
assembler.set_recipe("copper-cable")
assembler.insert{name = "copper-plate", count = 20}

local starve_pos = {7, -1}
local starving
local function spawn_starving()
    starving = s.create_entity{
        name = "fullerene_solar_panel",
        position = starve_pos,
        force = "player",
        raise_built = true,
    }
end
spawn_starving()

script.on_nth_tick(240, function()
    if starving and starving.valid then return end
    for _, e in pairs(s.find_entities_filtered{
        name = "fullerene-solar-panel-remnants",
        position = starve_pos,
        radius = 3,
    }) do e.destroy() end
    spawn_starving()
end)
