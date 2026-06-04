table.insert(data.raw.lab["lab"].inputs, "fullerene-science-pack")

local function copy_decal(from, to, tint)
    local decal = table.deepcopy(data.raw["optimized-decorative"][from])
    for _, p in pairs(decal.pictures) do
        p.tint = tint
    end
    decal.render_layer = "decals"
    decal.tile_layer = 255
    decal.name = to
    decal.autoplace = {
        order = "d[" .. to .. "]",
        probability_expression = to
    }
    data.raw["optimized-decorative"][to] = decal
end

copy_decal("calcite-stain",       "heliara_calcite_stain", {1, 0.85, 0.7})
copy_decal("calcite-stain-small", "heliara_calcite_small", {1, 0.85, 0.7})

require("decal.iron_carbon_slag")
require("decal.weathered_siliceous_crust")

local wsc_decals = {}
local wsc_autoplace = data.raw["planet"]["heliara"].map_gen_settings.autoplace_settings["decorative"].settings
for name in pairs(data.raw["optimized-decorative"]) do
    if name:find("^heliara_wsc_decal_") then
        table.insert(wsc_decals, name)
        wsc_autoplace[name] = {}
    end
end
data.raw["tile"]["heliara_weathered_siliceous_crust"].bound_decoratives = wsc_decals

table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_dust")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_rusty_sand")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_clay_shale")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "heliara_ferocalcite_crust")
data.raw["item"]["stone-brick"].place_as_tile.condition.layers["fragile"] = true
