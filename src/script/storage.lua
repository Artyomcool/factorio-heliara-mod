
---@alias EntityStorage { burner:LuaEntity|nil, panel:LuaEntity|nil, pole:LuaEntity|nil, silo:LuaEntity|nil, dyson_launcher:LuaEntity|nil }
---@alias SurfaceStorage { reflectors_count: int32 }

---@param surface LuaSurface
---@return SurfaceStorage
function surface_storage(surface)
    local index = surface.index

    if not storage.surfaces then
        storage.surfaces = {}
    end
    local result = storage.surfaces[index]
    if not result then
        result = {}
        storage.surfaces[index] = result
    end
    return result
end

function surface_storage_destroy(surface_index)
    if storage.surfaces then
        storage.surfaces[surface_index] = nil
    end
end

---@param entity LuaEntity
---@return EntityStorage
function entity_storage(entity)
    ---@type int
    local index = entity.unit_number

    if not storage.entities then
        storage.entities = {}
    end
    local result = storage.surfaces[index]
    if not result then
        result = {}
        storage.surfaces[index] = result
    end
    return result
end

---@param entity LuaEntity
function entity_storage_destroy(entity)
    if not storage.entities then
        return
    end
    local entities = storage.entities[entity.unit_number]
    if not entities then
        return
    end
    if entities.burner then
        entities.burner.destroy()
    end
    if entities.panel then
        entities.panel.destroy()
    end
    if entities.pole then
        entities.pole.destroy()
    end
    if entities.silo then
        entities.silo.destroy()
    end
    storage.entities[entity.unit_number] = nil
end

---@param fun fun(e: EntityStorage): nil
function each_entity_storage(fun)
    for _, e in pairs(storage.entities or {}) do
        fun(e)
    end
end