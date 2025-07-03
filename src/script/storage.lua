
---@alias EntityStorage { burner:LuaEntity|nil, panel:LuaEntity|nil, pole:LuaEntity|nil, silo:LuaEntity|nil, dyson_launcher:LuaEntity|nil }
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

---@param entity LuaEntity
function entity_storage_destroy(entity)
    -- todo maybe assign destructors somehow? or 'join' entities?
    local entities = substorage(storage, 'entities')
    local e = entities[entity.unit_number]
    if not e then
        return
    end
    if e.burner then
        e.burner.destroy()
    end
    if e.panel then
        e.panel.destroy()
    end
    if e.pole then
        e.pole.destroy()
    end
    if e.silo then
        e.silo.destroy()
    end
    if e.dyson_launcher then
        e.dyson_launcher.destroy()
    end
    storage.entities[entity.unit_number] = nil
end

---@param fun fun(e: EntityStorage): nil
function each_entity_storage(fun)
    for _, e in pairs(substorage(storage, 'entities')) do
        fun(e)
    end
end