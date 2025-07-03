require("script.storage")
require("script.reflectors")
require("script.dyson_swarm")

---@param player LuaPlayer
---@param surface LuaSurface
function make_reflectors_ui(player, surface)
    local existed = player.gui.relative['relfectors_info']
    if existed then
        existed.destroy();
    end

    local reflectors = reflectors_state(surface)

    local anchor = {gui=defines.relative_gui_type.entity_with_energy_source_gui, position=defines.relative_gui_position.right}
    local frame = player.gui.relative.add{type="frame", anchor=anchor, name='relfectors_info', caption='[item=solar_refractor] Reflectors Info'}
    local table = frame.add{type="table", column_count=2}
    table.style.column_alignments[2] = "right"

    table.add{type="label", caption='Count in atmosphere'}
    table.add{type="label", caption=reflectors.reflectors_count}
    table.add{type="label", caption='Electicity bonus'}
    table.add{type="label", caption=string.format("%.1f", (surface.solar_power_multiplier - 1) * 100) .. '%'}
    table.add{type="label", caption='Day duration'}
    table.add{type="label", caption=string.format("%.1f", reflectors.day_duration * 100) .. '%'}
    table.add{type="label", caption='Night duration'}
    table.add{type="label", caption=string.format("%.1f", reflectors.night_duration * 100) .. '%'}

    return frame
end

---@param player LuaPlayer
function destroy_reflectors_ui(player)
    local existed = player.gui.relative['relfectors_info']
    if existed then
        existed.destroy();
    end
end

---@param player LuaPlayer
function make_dyson_swarm_ui(player)
    local existed = player.gui.relative['dyson_swarm_info']
    if existed then
        existed.destroy();
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local swarm = swarm_state(player.force)

    local anchor = {gui=defines.relative_gui_type.rocket_silo_gui, position=defines.relative_gui_position.right}
    --todo swarm icon
    local frame = player.gui.relative.add{type="frame", anchor=anchor, name='dyson_swarm_info', caption='[item=solar_refractor] Reflectors Info'}
    local table = frame.add{type="table", column_count=2}
    table.style.column_alignments[2] = "right"

    table.add{type="label", caption='Swarm size'}
    table.add{type="label", caption=swarm.swarm_size}
    table.add{type="label", caption='Electicity bonus'}
    table.add{type="label", caption=string.format("%.1f", swarm.electricity_bonus * 100) .. '%'}

    return frame
end

---@param player LuaPlayer
function destroy_dyson_swarm_ui(player)
    local existed = player.gui.relative['dyson_swarm_info']
    if existed then
        existed.destroy();
    end
end