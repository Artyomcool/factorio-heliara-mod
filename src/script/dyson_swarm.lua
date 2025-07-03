require("script.storage")

local function swarm_solar_bonus(count)
    return math.pow(count, 0.25) * 0.10
end

---@param force LuaForce
---@param delta int32
function increase_swarm(force, delta)
    local force_storage = force_storage(force)

    local prev_count = force_storage.swarm_size or 0
    local now_count = math.max(0, prev_count + delta)

    if now_count == prev_count then
        return
    end

    force_storage.swarm_size = now_count
    local solar_multiplier = 1 + swarm_solar_bonus(now_count)

    for _, platform in pairs(force.platforms) do
        local surface = platform.surface
        local st = surface_storage(surface)
        local m = st.cached_solar_multiplier or 1
        local d = surface.solar_power_multiplier - m

        surface.solar_power_multiplier = solar_multiplier + d
        st.cached_solar_multiplier = surface.solar_power_multiplier
    end
end

---@param force LuaForce
---@return {swarm_size:int, electricity_bonus:double}
function swarm_state(force)
    local swarm_size = force_storage(force).swarm_size or 0
    return {
        swarm_size = swarm_size,
        electricity_bonus = swarm_solar_bonus(swarm_size)
    }
end