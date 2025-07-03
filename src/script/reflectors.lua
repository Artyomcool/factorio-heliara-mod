require("__heliara__.script.storage")

local function interpolate(from, to, current)
    if current >= 1 then
        return to
    end
    
    return from + (to - from) * current
end

local function day_duration(reflectors_count)
    local count_to_make_it_always_day = 1000
    return interpolate(0.2, 1, reflectors_count / count_to_make_it_always_day)
end

local function night_duration(reflectors_count)
    local count_to_make_it_never_night = 500
    return interpolate(0.2, 0, reflectors_count / count_to_make_it_never_night)
end

---@param day_duration double
---@param night_duration double
---@return {dusk:double, evening:double, morning:double, dawn:double}
function daytime_parameters(day_duration, night_duration)
    local min_distance = 0.000001
    local dusk_dawn_duration = (1 - night_duration - day_duration) / 2
    
    -- 0 -> dusk = day
    -- dusk -> evening = sunset process
    -- evening -> morning = night
    -- morning -> dawn = sunrise process (???)
    -- dawn -> 1 = sunrise process (???)

    return {
        dusk = day_duration - min_distance * 3,
        evening = day_duration + dusk_dawn_duration - min_distance * 2,
        morning = day_duration + dusk_dawn_duration + night_duration - min_distance,
        dawn = 1,
    }
end

---@param surface LuaSurface
---@param delta int32
function add_reflectors(surface, delta)

    local surface_storage = surface_storage(surface)
    local prev_count = surface_storage.reflectors_count or 0
    local now_count = math.max(0, prev_count + delta)

    if now_count == prev_count then
        return
    end

    surface_storage.reflectors_count = now_count
    surface.solar_power_multiplier = 1 + math.pow(now_count, 0.5) * 0.05


    surface.daytime_parameters = daytime_parameters(day_duration(now_count), night_duration(now_count))
end

---@param surface LuaSurface
---@return {day_duration:double, night_duration:double, reflectors_count:int}
function reflectors_state(surface)
    local surface_storage = surface_storage(surface)
    
    local reflectors_count = surface_storage.reflectors_count or 0
    return {
        day_duration = day_duration(reflectors_count),
        night_duration = night_duration(reflectors_count),
        reflectors_count = reflectors_count
    }
end