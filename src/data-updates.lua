table.insert(data.raw.lab["lab"].inputs, "fullerene-science-pack")

local function copy_decal(from, to, tint)
    local decal = table.deepcopy(data.raw["optimized-decorative"][from])
    for _, p in pairs(decal.pictures) do
        p.tint = tint
    end
    decal.render_layer = "decals"
    decal.tile_layer =  255
    decal.name = to
    decal.autoplace = {
        order = "d[" .. to .. "]",
        probability_expression = to
    }
    data.raw["optimized-decorative"][to] = decal
end

copy_decal("tiny-volcanic-rock", "heliara_tiny_rock_1", {0.35, 0.2, 0.15})
copy_decal("tiny-volcanic-rock", "heliara_tiny_rock_2", {0.15, 0.2, 0.35})
copy_decal("tiny-volcanic-rock", "heliara_tiny_rock_3", {0.2, 0.2, 0.22})
copy_decal("waves-decal", "heliara_waves_decal", nil)
copy_decal("calcite-stain-small", "heliara_calcite_small", {0.9, 0.9, 0.9})

table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_dust")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_rusty_sand")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_clay_shale")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_ferocalcite_crust")
data.raw["item"]["stone-brick"].place_as_tile.condition.layers["fragile"] = true

--