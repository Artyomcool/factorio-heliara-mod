---@param cargo_pod LuaEntity
function pod_crash(cargo_pod)
    local force = cargo_pod.force

    if cargo_pod.name == "cargo-pod-no-payload" then
        cargo_pod.destroy()
        return
    end

    if cargo_pod.name == "cargo-dyson_swarm_element" then
        cargo_pod.destroy()
        return
    end

    if cargo_pod.get_passenger() then
        -- todo damage?
        return
    end

    if force.technologies["heliara_navigation"].researched then
        return
    end

    local position = cargo_pod.position
    surface.create_entity({
        name = "collapsing-cargo-pod-container",
        position = position,
        force = cargo_pod.force,
        create_build_effect_smoke = true,
    })
    surface.create_entity {
        name = "big-explosion",
        position = position,
        force = game.forces.enemy
    }
    surface.create_entity {
        name = "fire-flame",
        position = position,
        force = game.forces.enemy
    }
    cargo_pod.destroy()
    -- todo translation
    force.print('Pod crashed because of navigation failure')
end