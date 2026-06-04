game.simulation.camera_position = {0, 1.5}
game.simulation.camera_zoom = 0.62

local s = game.surfaces[1]
s.freeze_daytime = true
s.daytime = 0.18

-- Let Heliara's real map generator paint the scene. Hand-placing only a small
-- patch leaves the simulation checkerboard visible and looks unlike planet tips.
s.request_to_generate_chunks({0, 0}, 4)
s.force_generate_chunk_requests()

for _, entity in pairs(s.find_entities_filtered{area = {{-45, -30}, {45, 30}}}) do
    if entity.valid and entity.type ~= "character" then
        entity.destroy()
    end
end

for _, entity in pairs({
    {name = "huge_fullerene_rock", position = {-18, -5}},
    {name = "huge_fullerene_rock", position = {15, 1}},
    {name = "huge_fullerene_rock", position = {30, -10}},
    {name = "brackish_vent", position = {-24, 10}, amount = 1000000},
    {name = "shungite", position = {-5, -6}, amount = 9000},
    {name = "shungite", position = {-3, -7}, amount = 9000},
    {name = "shungite", position = {-1, -5}, amount = 8000},
    {name = "carbon_coal", position = {10, 8}, amount = 7000},
    {name = "carbon_coal", position = {12, 9}, amount = 7000},
    {name = "calcite", position = {-12, 6}, amount = 5000},
}) do
    s.create_entity(entity)
end

local decoratives = {}
for _, p in pairs({
    {-36, -16}, {-30, -9}, {-24, 6}, {-18, -14}, {-12, 10}, {-7, -1},
    {-2, 5}, {4, -13}, {8, 3}, {14, -7}, {20, 11}, {27, -2}, {34, 8},
}) do
    decoratives[#decoratives + 1] = {name = "heliara_tiny_rock_1", position = p, amount = 1}
end
for _, p in pairs({
    {-7, 2}, {-5, 2}, {-3, 3}, {-1, 3}, {1, 4}, {3, 4},
    {14, -6}, {16, -5}, {18, -5}, {-22, 4}, {-20, 5},
}) do
    decoratives[#decoratives + 1] = {name = "heliara_cracks", position = p, amount = 1}
end
s.create_decoratives{decoratives = decoratives}
