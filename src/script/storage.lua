
---@alias EntityStorage table
---@alias SurfaceStorage { reflectors_count:int|nil, cached_solar_multiplier:int|nil }
---@alias ForceStorage { swarm_size:int }

local function substorage(storage, id)
    local s = storage[id]
    if not s then
        s = {}
        storage[id] = s
    end

    return s
end

---@param surface LuaSurface
---@return SurfaceStorage
function surface_storage(surface)
    return substorage(substorage(storage, 'surfaces'), surface.index)
end

---@param surface_index int
function surface_storage_destroy(surface_index)
    substorage(storage, 'surfaces')[surface_index] = nil
end

---@param force LuaForce
---@return ForceStorage
function force_storage(force)
    return substorage(substorage(storage, 'forces'), force.index)
end

---@param force LuaForce
function force_storage_destroy(force)
    substorage(storage, 'forces')[force.index] = nil
end

---@param entity LuaEntity
---@return EntityStorage
function entity_storage(entity)
    return substorage(substorage(storage, 'entities'), entity.unit_number)
end

function ticking()
    return substorage(storage, 'ticking_entity')
end

---@param entity LuaEntity
function entity_storage_destroy(entity)
    if storage.entities then
        storage.entities[entity.unit_number] = nil
    end
end

---@param fun fun(e: EntityStorage): nil
function each_entity_storage(fun)
    for _, e in pairs(substorage(storage, 'entities')) do
        fun(e)
    end
end