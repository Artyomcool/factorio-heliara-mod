require("common")

local _name = "big_space_platform_hub"

local make_tile_area = function(area, name)
    local result = {}
    local left_top = area[1]
    local right_bottom = area[2]
    for x = left_top[1], right_bottom[1] do
        for y = left_top[2], right_bottom[2] do
            table.insert(result,
                    {
                        position = {x, y},
                        tile = name
                    })
        end
    end
    return result
end

local entity = wrap_for_data(
    function ()
        local entity = table.deepcopy(data.raw["space-platform-hub"]["space-platform-hub"])
        entity.name = nil
        entity.order = entity.order .. '-big'
        entity.collision_box = {{-7.7, -7.9}, {7.9, 7.9}}
        entity.selection_box = {{-8, -8}, {8, 8}}
        entity.max_health = entity.max_health * 4
        entity.weight = entity.weight * 4
        entity.inventory_size = entity.inventory_size * 4
        entity.circuit_wire_max_distance = entity.circuit_wire_max_distance * 2
        entity.platform_repair_speed_modifier = entity.platform_repair_speed_modifier * 5
        entity.graphics_set.picture[1] = {
            render_layer = "lower-object",
            layers = {
                {
                    filename = "__heliara__/graphics/entity/big_space_hub/platform-hub.png",
                    width = 1024,
                    height = 1024,
                    shift = {0, -0.25},
                    scale = 0.5
                },
            }
        }
        local s = entity.graphics_set.picture[4].layers[2].shift
        s[1] = s[1] - 1
        s[2] = s[2] - 1

        return entity
    end,
    function ()
        return {}
    end
)

return {
    {
        common = {
            name = _name,
            icon = "__space-age__/graphics/icons/space-platform-starter-pack.png",    -- fixme
            icon_size = 64,
        },
        entity = entity,
        raw = {
            {
                type = "space-platform-starter-pack",
                name = _name,
                icon = "__space-age__/graphics/icons/space-platform-starter-pack.png",    -- fixme
                icon_size = 64,
                subgroup = "space-rocket",
                order = "b[space-platform-starter-pack-big]",
                inventory_move_sound = item_sounds.mechanical_large_inventory_move,
                pick_sound = item_sounds.mechanical_large_inventory_pickup,
                drop_sound = item_sounds.mechanical_large_inventory_move,
                stack_size = 1,
                weight = 1*tons,
                surface = "space-platform",
                trigger = {
                    {
                        type = "direct",
                        action_delivery = {
                            type = "instant",
                            source_effects = {
                                {
                                    type = "create-entity",
                                    entity_name = _name
                                }
                            }
                        }
                    }
                },
                tiles = make_tile_area({{-15, -15}, {14, 14}}, "space-platform-foundation"),
                initial_items = {{type = "item", name = "space-platform-foundation", amount = 100}},
                create_electric_network = true,
            }
        },
        recipe = {
            ingredients = {
                ["space-platform-foundation"] = 1000,
                ["tungsten-plate"] = 10,
                ["low-density-structure"] = 40,
                ["processing-unit"] = 20,
                ["graphite_circuit"] = 20,
                ["carbon-fiber"] = 20,
            },
            energy_required = 200,
            enabled = true,
        },
    },
}