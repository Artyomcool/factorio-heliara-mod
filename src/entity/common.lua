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

require("util")
require("__base__.prototypes.entity.pipecovers")
require("__base__.prototypes.entity.assemblerpipes")
if data then
    hit_effects = require("__base__.prototypes.entity.hit-effects")
    item_tints = require("__base__.prototypes.item-tints")
    decorative_trigger_effects = require("__base__.prototypes.decorative.decorative-trigger-effects")
else
    hit_effects = stub()
    item_tints = {}
    decorative_trigger_effects = stub()
    volume_multiplier = nil_fn
end

function wrap(func)
    if data then return nil else return func end
end

function req(module)
    if not data then require(module) end
end