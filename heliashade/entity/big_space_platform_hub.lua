require("common.common")

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

local function remove_shadows(t)
  if type(t) ~= "table" then return end

  for i = #t, 1, -1 do
    local v = t[i]

    if type(v) == "table" then
      if v.draw_as_shadow then
        table.remove(t, i)
      else
        remove_shadows(v)
      end
    end
  end

  for k, v in pairs(t) do
    if type(k) ~= "number" and type(v) == "table" then
      remove_shadows(v)
    end
  end
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

        local s = entity.graphics_set.picture[4].layers[2].shift
        s[1] = s[1] - 1
        s[2] = s[2] - 1

        table.insert(
            entity.graphics_set.picture[4].layers,
            1,
            {
                filename = "__heliashade__/graphics/entity/big_space_hub/modules.png",
                    width = 1024,
                    height = 1024,
                    scale = 0.5,
                    shift = {0.5,-0.25}
            }
        );

        entity.graphics_set.picture[1] = {
            render_layer = "lower-object",
            layers = {
                {
                    filename = "__heliashade__/graphics/entity/big_space_hub/bg.png",
                    width = 1024,
                    height = 1024,
                    scale = 0.5,
                    shift = {0.5,-0.25}
                },
            }
        }

        return entity
    end
)

return {
    {
        common = {
            name = _name,
            icon = "__heliashade__/graphics/icons/" .. _name ..  ".png",
            icon_size = 128
        },
        entity = entity,
        raw = {
            {
                type = "space-platform-starter-pack",
                name = _name,
                icon = "__heliashade__/graphics/icons/" .. _name ..  ".png",
                icon_size = 128,
                subgroup = "space-rocket",
                order = "b[space-platform-starter-pack-big]",
                inventory_move_sound = item_sounds.mechanical_large_inventory_move,
                pick_sound = item_sounds.mechanical_large_inventory_pickup,
                drop_sound = item_sounds.mechanical_large_inventory_move,
                stack_size = 1,
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
                tiles = make_tile_area({{-8, -8}, {7, 7}}, "space-platform-foundation"),
                -- initial_items = {{type = "item", name = "space-platform-foundation", amount = 0}},
                create_electric_network = true,
            }
        },
        recipe = {
            ingredients = {
                ["space-platform-foundation"] = 256,
                ["tungsten-plate"] = 10,
                ["low-density-structure"] = 40,
                ["processing-unit"] = 40,
                ["carbon-fiber"] = 20,
            },
            energy_required = 200,
            enabled = true,
        },
    },
}
