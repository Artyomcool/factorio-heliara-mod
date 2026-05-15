require("script.dyson_swarm")

---@param v EntityStorage
function tick_dyson_launcher(v)
    local silo = v.dyson_launcher
    if not silo or not silo.valid or not silo.rocket then
        return
    end

    if not silo.launch_rocket() then
        return
    end

    ---@type LuaForce
    ---@diagnostic disable-next-line: assign-type-mismatch
    local f = silo.force
    increase_swarm(f, 1)
end