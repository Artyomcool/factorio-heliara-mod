require("__heliara__.prototypes.planet.planet")
require("__heliara__.prototypes.noise")
require("util")
require("__heliara__.technology")

local declare = {
    require("__heliara__.entity.fullerene_solar_panel"),
    require("__heliara__.entity.fullerene_extraction_bath"),
    require("__heliara__.entity.shungite"),
    require("__heliara__.entity.rocks"),
    require("__heliara__.entity.fullerene"),
    require("__heliara__.entity.silicon_substrate"),
    require("__heliara__.entity.graphite"),
    require("__heliara__.entity.graphite_circuit"),
    require("__heliara__.entity.solar_refractor"),
    require("__heliara__.entity.dyson_swarm_element"),
    require("__heliara__.entity.solar_refractor_silo"),
    require("__heliara__.entity.heliara_assembling_machine"),
    require("__heliara__.entity.fullerene-science-pack"),
    require("__heliara__.entity.graphite-automation-science-pack"),
    require("__heliara__.entity.graphite-logistic-science-pack"),
    require("__heliara__.entity.fullerene_lab"),
    require("__heliara__.entity.fast_burner_inserter"),
    require("__heliara__.entity.long_burner_inserter"),
    require("__heliara__.entity.steam_cargo"),
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
        table.insert(results,  { type = "item", name = common.name, amount = 1 });
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
            icons = recipe.icons or common.icons,
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
            icons = item.icons or common.icons,
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
            default_import_location = item.default_import_location or "heliara",
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

local function declare_resource(common, resource)
    if resource == nil then
        return
    end

    local icon_size = common.icon_size
    if resource.icon then
        icon_size = resource.icon_size
    end

    local minable = nil
    if resource.mining_time then
        minable = {
            mining_time = resource.mining_time,
            result = resource.mining_result or common.name
        }
    end

    data:extend({
        {
            type = "resource",
            name = resource.name or common.name,
            order = resource.order or common.order or resource.name or common.name,
            localised_name = resource.localised_name or common.localised_name,
            localised_description = resource.localised_description or common.localised_description,
            factoriopedia_description = resource.factoriopedia_description or common.factoriopedia_description,
            subgroup = resource.subgroup or common.subgroup,
            hidden = resource.hidden,
            hidden_in_factoriopedia = resource.hidden_in_factoriopedia,
            factoriopedia_simulation = resource.factoriopedia_simulation,
            factoriopedia_alternative = resource.factoriopedia_alternative,
            icon = resource.icon or common.icon,
            icons = resource.icons or common.icons,
            icon_size = icon_size,
            collision_box = resource.collision_box or { { -0.1, -0.1 }, { 0.1, 0.1 } },
            collision_mask = resource.collision_mask,
            map_generator_bounding_box = resource.map_generator_bounding_box,
            selection_box = resource.selection_box or { { -0.25, -0.25 }, { 0.25, 0.25 } },
            drawing_box_vertical_extension = resource.drawing_box_vertical_extension,
            sticker_box = resource.sticker_box,
            hit_visualization_box = resource.hit_visualization_box,
            trigger_target_mask = resource.trigger_target_mask,
            flags = resource.flags,
            tile_buildability_rules = resource.tile_buildability_rules,
            minable = minable,
            surface_conditions = resource.surface_conditions,
            deconstruction_alternative = resource.deconstruction_alternative,
            selection_priority = resource.selection_priority,
            build_grid_size = resource.build_grid_size,
            remove_decoratives = resource.remove_decoratives,
            emissions_per_second = resource.emissions_per_second,
            shooting_cursor_size = resource.shooting_cursor_size,
            created_smoke = resource.created_smoke,
            working_sound = resource.working_sound,
            created_effect = resource.created_effect,
            build_sound = resource.build_sound,
            mined_sound = resource.mined_sound,
            mining_sound = resource.mining_sound,
            rotated_sound = resource.rotated_sound,
            impact_category = resource.impact_category,
            open_sound = resource.open_sound,
            close_sound = resource.close_sound,
            placeable_position_visualization = resource.placeable_position_visualization,
            radius_visualisation_specificationo = resource.radius_visualisation_specificationo,
            stateless_visualisation = resource.stateless_visualisation,
            build_base_evolution_requirement = resource.build_base_evolution_requirement,
            alert_icon_shift = resource.alert_icon_shift,
            alert_icon_scale = resource.alert_icon_scale,
            fast_replaceable_group = resource.fast_replaceable_group,
            next_upgrade = resource.next_upgrade,
            protected_from_tile_building = resource.protected_from_tile_building,
            heating_energy = resource.heating_energy,
            allow_copy_paste = resource.allow_copy_paste,
            selectable_in_game = resource.selectable_in_game,
            placeable_by = resource.placeable_by,
            remains_when_mined = resource.remains_when_mined,
            additional_pastable_entities = resource.additional_pastable_entities,
            tile_width = resource.tile_width,
            tile_height = resource.tile_height,
            diagonal_tile_grid_size = resource.diagonal_tile_grid_size,
            autoplace = resource.autoplace,
            map_color = resource.map_color,
            friendly_map_color = resource.friendly_map_color,
            enemy_map_color = resource.enemy_map_color,
            water_reflection = resource.water_reflection,
            ambient_sounds_group = resource.ambient_sounds_group,
            ambient_sounds = resource.ambient_sounds,
            icon_draw_specification = resource.icon_draw_specification,
            icons_positioning = resource.icons_positioning,
            stages = resource.stages,
            stage_counts = resource.stage_counts,
            infinite = resource.infinite,
            highlight = resource.highlight,
            randomize_visual_position = resource.randomize_visual_position,
            map_grid = resource.map_grid,
            draw_stateless_visualisation_under_building = resource.draw_stateless_visualisation_under_building,
            minimum = resource.minimum,
            normal = resource.normal,
            infinite_depletion_amount = resource.infinite_depletion_amount,
            resource_patch_search_radius = resource.resource_patch_search_radius,
            category = resource.category,
            walking_sound = resource.walking_sound,
            driving_sound = resource.driving_sound,
            stages_effect = resource.stages_effect,
            effect_animation_period = resource.effect_animation_period,
            effect_animation_period_deviation = resource.effect_animation_period_deviation,
            effect_darkness_multiplier = resource.effect_darkness_multiplier,
            min_effect_alpha = resource.min_effect_alpha,
            max_effect_alpha = resource.max_effect_alpha,
            tree_removal_probability = resource.tree_removal_probability,
            cliff_removal_probability = resource.cliff_removal_probability,
            tree_removal_max_distance = resource.tree_removal_max_distance,
            mining_visualisation_tint = resource.mining_visualisation_tint,
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
        icons = entity.icons or common.icons,
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

for _, to_declares in ipairs(declare) do
    for _, to_declare in ipairs(to_declares) do
        local common = to_declare.common or {}
        declare_recipe(common, to_declare.recipe)
        declare_item(common, to_declare.item)
        declare_entity(common, to_declare.entity)
        declare_resource(common, to_declare.resource)
    end
end

local collapsing_container = util.table.deepcopy(data.raw["temporary-container"]["cargo-pod-container"])
collapsing_container.name = "collapsing-cargo-pod-container"
collapsing_container.time_to_leave = 1
data:extend({collapsing_container})
