require("__heliara__.prototypes.planet.planet")
require("__heliara__.prototypes.entity.shungite")
require("__heliara__.prototypes.item.shungite")

require("util")

local declare = {
    require("__heliara__.entity.fullerene_solar_panel")
}

local function declare_recipe(common, recipe)
    if recipe == nil then
        return
    end

    local ingredients = {}

    for k, v in pairs(recipe.ingredients or {}) do
        table.insert(ingredients, { type = "item", name = k, amount = v })
    end

    for k, v in pairs(recipe.fluid_ingredients or {}) do
        table.insert(ingredients, { type = "fluid", name = k, amount = v })
    end

    local results = {}

    if recipe.results or recipe.fluid_results then
        for k, v in pairs(recipe.results or {}) do
            table.insert(results, { type = "item", name = k, amount = v })
        end

        for k, v in pairs(recipe.fluid_results or {}) do
            table.insert(results, { type = "fluid", name = k, amount = v })
        end
    else
        results = { type = "item", name = common.name, amount = 1 }
    end

    local icon_size = common.icon_size
    if recipe.icon then
        icon_size = recipe.icon_size
    end

    data:extend({
        {
            type = "recipe",
            name = recipe.name or common.name,
            order = recipe.order or common.order or recipe.name or common.name,
            localised_name = recipe.localised_name or common.localised_name,
            localised_description = recipe.localised_description or common.localised_description,
            factoriopedia_description = recipe.factoriopedia_description or common.factoriopedia_description,
            subgroup = recipe.subgroup or common.subgroup,
            hidden = recipe.hidden,
            hidden_in_factoriopedia = recipe.hidden_in_factoriopedia,
            factoriopedia_simulation = recipe.factoriopedia_simulation,
            factoriopedia_alternative = recipe.factoriopedia_alternative,
            category = recipe.category or "crafting",
            icon = recipe.icon or common.icon,
            icon_size = icon_size,
            ingredients = ingredients,
            results = results,
            main_product = recipe.main_product or common.name,
            energy_required = recipe.energy_required,
            emissions_multiplier = recipe.emissions_multiplier,
            maximum_productivity = recipe.maximum_productivity,
            requester_paste_multiplier = recipe.requester_paste_multiplier,
            overload_multiplier = recipe.overload_multiplier,
            allow_inserter_overload = recipe.allow_inserter_overload,
            enabled = recipe.enabled,
            hide_from_stats = recipe.hide_from_stats,
            hide_from_player_crafting = recipe.hide_from_player_crafting,
            allow_decomposition = recipe.allow_decomposition,
            allow_as_intermediate = recipe.allow_as_intermediate,
            allow_intermediates = recipe.allow_intermediates,
            always_show_made_in = recipe.always_show_made_in,
            show_amount_in_title = recipe.show_amount_in_title,
            always_show_products = recipe.always_show_products,
            unlock_results = recipe.unlock_results,
            preserve_products_in_machine_output = recipe.preserve_products_in_machine_output,
            result_is_always_fresh = recipe.result_is_always_fresh,
            allow_consumption_message = recipe.allow_consumption_message,
            allow_speed_message = recipe.allow_speed_message,
            allow_productivity_message = recipe.allow_productivity_message,
            allow_pollution_message = recipe.allow_pollution_message,
            allow_quality_message = recipe.allow_quality_message,
            surface_conditions = recipe.surface_conditions,
            hide_from_signal_gui = recipe.hide_from_signal_gui,
            allow_consumption = recipe.allow_consumption,
            allow_speed = recipe.allow_speed,
            allow_productivity = recipe.allow_productivity,
            allow_pollution = recipe.allow_pollution,
            allow_quality = recipe.allow_quality,
            allowed_module_categories = recipe.allowed_module_categories,
            alternative_unlock_methods = recipe.alternative_unlock_methods,
            auto_recycle = recipe.auto_recycle
        }
    })
end

local function declare_item(common, item)
    if item == nil then
        return
    end

    local icon_size = common.icon_size
    if item.icon then
        icon_size = item.icon_size
    end

    data:extend({
        {
            type = "item",
            name = item.name or common.name,
            order = item.order or common.order or item.name or common.name,
            localised_name = item.localised_name or common.localised_name,
            localised_description = item.localised_description or common.localised_description,
            factoriopedia_description = item.factoriopedia_description or common.factoriopedia_description,
            subgroup = item.subgroup or common.subgroup,
            hidden = item.hidden,
            hidden_in_factoriopedia = item.hidden_in_factoriopedia,
            factoriopedia_simulation = item.factoriopedia_simulation,
            factoriopedia_alternative = item.factoriopedia_alternative,
            icon = item.icon or common.icon,
            icon_size = icon_size,
            stack_size = item.stack_size,
            dark_background_icons = item.dark_background_icons,
            dark_background_icon = item.dark_background_icon,
            dark_background_icon_size = item.dark_background_icon_size,
            place_result = item.place_result,
            place_as_equipment_result = item.place_as_equipment_result,
            fuel_category = item.fuel_category,
            burnt_result = item.burnt_result,
            spoil_result = item.spoil_result,
            plant_result = item.plant_result,
            place_as_tile = item.place_as_tile,
            pictures = item.pictures,
            flags = item.flags,
            spoil_ticks = item.spoil_ticks,
            fuel_value = item.fuel_value,
            fuel_acceleration_multiplier = item.fuel_acceleration_multiplier,
            fuel_top_speed_multiplier = item.fuel_top_speed_multiplier,
            fuel_emissions_multiplier = item.fuel_emissions_multiplier,
            fuel_acceleration_multiplier_quality_bonus = item.fuel_acceleration_multiplier_quality_bonus,
            fuel_top_speed_multiplier_quality_bonus = item.fuel_top_speed_multiplier_quality_bonus,
            weight = item.weight,
            ingredient_to_weight_coefficient = item.ingredient_to_weight_coefficient,
            fuel_glow_color = item.fuel_glow_color,
            open_sound = item.open_sound,
            close_sound = item.close_sound,
            pick_sound = item.pick_sound,
            drop_sound = item.drop_sound,
            inventory_move_sound = item.inventory_move_sound,
            default_import_location = item.default_import_location,
            color_hint = item.color_hint,
            has_random_tint = item.has_random_tint,
            spoil_to_trigger_result = item.spoil_to_trigger_result,
            destroyed_by_dropping_trigger = item.destroyed_by_dropping_trigger,
            rocket_launch_products = item.rocket_launch_products,
            send_to_orbit_mode = item.send_to_orbit_mode,
            random_tint_color = item.random_tint_color,
            spoil_level = item.spoil_level,
            auto_recycle = item.auto_recycle
        }
    })
end

local function declare_entity(common, entity)
    if entity == nil then
        return
    end

    local icon_size = common.icon_size
    if entity.icon then
        icon_size = entity.icon_size
    end

    local result = {
        name = entity.name or common.name,
        order = entity.order or common.order or entity.name or common.name,
        localised_name = entity.localised_name or common.localised_name,
        localised_description = entity.localised_description or common.localised_description,
        factoriopedia_description = entity.factoriopedia_description or common.factoriopedia_description,
        subgroup = entity.subgroup or common.subgroup,
        icon = entity.icon or common.icon,
        icon_size = icon_size,
    }

    for k, v in pairs(entity) do
        if result[k] == nil then
            result[k] = v
        end
    end

    data:extend({
        result
    })
end

for _, to_declare in ipairs(declare) do
    declare_recipe(to_declare.common, to_declare.recipe)
    declare_item(to_declare.common, to_declare.item)
    declare_entity(to_declare.common, to_declare.entity)
end

data:extend({
    --BASICS
    {
        type = "technology",
        name = "planet-discovery-heleria",
        icons = util.technology_icon_constant_planet("__heliara__/graphics/icons/heliara.png"),
        icon_size = 256,
        essential = true,
        effects = {
            {
                type = "unlock-space-location",
                space_location = "heliara",
                use_icon_overlay_constant = true
            },
        },
        prerequisites = { "space-platform-thruster" },
        unit = {
            count = 1000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack", 1 },
                { "chemical-science-pack", 1 },
                { "production-science-pack", 1 },
                { "utility-science-pack", 1 },
                { "space-science-pack", 1 },
            },
            time = 60
        }
    },


}
)