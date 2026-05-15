require("common.storage")
require("script.dyson_swarm")

---@param player LuaPlayer
function make_dyson_swarm_ui(player)
    local existed = player.gui.relative['dyson_swarm_info']
    if existed then
        existed.destroy();
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local swarm = swarm_state(player.force)

    local anchor = {gui=defines.relative_gui_type.rocket_silo_gui, position=defines.relative_gui_position.right}
    local frame = player.gui.relative.add{type="frame", anchor=anchor, name='dyson_swarm_info', caption='Dyson Swarm Info'}
    local table = frame.add{type="table", column_count=2}
    table.style.column_alignments[2] = "right"

    table.add{type="label", caption='Swarm size'}
    table.add{type="label", caption=swarm.swarm_size}
    table.add{type="label", caption='Electricity bonus'}
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
