require("common.common")

local _name = "packed_roboport"

return {
    {
        common = {
            name = _name,
            icon = "__heliashade__/graphics/icons/" .. _name .. ".png",
            icon_size = 128,
            order = "z[packed-roboport]-a[pack]",
        },
        item = {
            color_hint = { text = "T" },
            stack_size = 5,
            place_as_equipment_result = _name,
            subgroup = "utility-equipment",
        },
        recipe = {
            category = "advanced-crafting",
            energy_required = 1,
            enabled = true,
            ingredients = {
                ["personal-roboport-mk2-equipment"] = 1,
                ["construction-robot"] = 16,
                ["tungsten-plate"] = 4,
                ["carbon-fiber"] = 4,
                ["plastic-bar"] = 8,
            },
            results = {
                [_name] = 1
            },
            allow_productivity = false,
            allow_decomposition = false,
            auto_recycle = false,
        },
        entity = {
            type = "movement-bonus-equipment",
            sprite =
            {
                filename = "__heliashade__/graphics/icons/" .. _name .. ".png",
                width = 128,
                height = 128,
                priority = "medium",
            },
            shape =
            {
                width = 3,
                height = 3,
                type = "full",
            },
            energy_source =
            {
                type = "electric",
                usage_priority = "primary-input"
            },
            energy_consumption = "1kW",
            movement_bonus = 0,
            categories = {"armor"}
        },
    },
    {
        recipe = {
            name = "packed_roboport_unpack",
            icon = "__heliashade__/graphics/icons/packed_roboport_unpack.png",
            icon_size = 64,
            subgroup = "utility-equipment",
            order = "z[packed-roboport]-b[unpack]",
            category = "crafting",
            energy_required = 1,
            enabled = true,
            ingredients = {
                [_name] = 1,
            },
            results = {
                ["personal-roboport-mk2-equipment"] = 1,
                ["construction-robot"] = {14, 16},
            },
            main_product = "",
            allow_productivity = false,
        },
    }
}
