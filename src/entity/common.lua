local function nil_fn(...) return nil end

local function stub()
    local t = {}
    setmetatable(t, {
        __index = function(_, _)
            return nil_fn
        end
    })
    return t
end

local function req_for_data(name, default)
    if data then return require(name) else return default end
end

require("util")
require("__base__.prototypes.entity.pipecovers")
require("__base__.prototypes.entity.assemblerpipes")
require ("sound-util")
require ("circuit-connector-sprites")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")

hit_effects = req_for_data("__base__.prototypes.entity.hit-effects", stub())
item_tints = req_for_data("__base__.prototypes.item-tints", {})
item_sounds = req_for_data("__base__.prototypes.item_sounds", {})
decorative_trigger_effects = req_for_data("__base__.prototypes.decorative.decorative-trigger-effects", stub())
sounds = req_for_data("__base__.prototypes.entity.sounds", {})
procession_graphic_catalogue_types = req_for_data("__base__/prototypes/planet/procession-graphic-catalogue-types", {})

if not data then
    volume_multiplier = nil_fn
    platform_upper_hatch = nil_fn
    platform_lower_hatch = nil_fn
    platform_upper_giga_hatch = nil_fn
    platform_lower_giga_hatch = nil_fn
end

function wrap(func)
    if data then return nil else return func end
end

function wrap_for_data(for_data, for_no_data)
    if data then return for_data() else return for_no_data() end
end

function req(module)
    if not data then require(module) end
end

function values(table)
    local key
    function nxt()
        local k, v = next(table, key)
        key = k
        return v
    end
    return nxt
end