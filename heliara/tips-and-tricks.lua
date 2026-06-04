require("common.common")

return {
    {
        on_research = {
            ["planet-discovery-heliara"] = wrap(function(research, event)
                game.print({"heliara-message.discovered"})
            end),
        },
    },
    {
        on_first_visit = {
            ["heliara"] = wrap(function(player, event)
                player.print({"heliara-message.first-landing"})
            end),
        },
    },
    {
        on_research = {
            ["graphite_circuit"] = wrap(function(research, event)
                game.print({"heliara-message.graphite-circuit"})
            end),
        },
    },
    {
        tip = {
            name = "heliara-briefing",
            tag = "[planet=heliara]",
            category = "space-age",
            order = "e-a",
            -- trigger = {
            --     type = "research",
            --     technology = "planet-discovery-heliara",
            -- },
            -- skip_trigger = {
            --     type = "change-surface",
            --     surface = "heliara",
            -- },
            simulation = {
                planet = "heliara",
                mute_wind_sounds = false,
                init_file = "__heliara__/simulation/heliara_briefing.lua",
            },
        },
    },
    {
        tip = {
            name = "heliara-fullerene-solar-panel",
            tag = "[entity=fullerene_solar_panel]",
            category = "space-age",
            order = "e-b",
            indent = 1,
            dependencies = {"heliara-briefing"},
            -- trigger = {
            --     type = "change-surface",
            --     surface = "heliara",
            -- },
            -- skip_trigger = {
            --     type = "build-entity",
            --     entity = "fullerene_solar_panel",
            --     count = 1,
            --     match_type_only = true,
            -- },
            simulation = {
                init_file = "__heliara__/simulation/wireless_pole.lua",
            },
        },
    },
    {
        tip = {
            name = "heliara-solar-reflectors",
            tag = "[item=solar_reflector]",
            category = "space-age",
            order = "e-c",
            indent = 1,
            dependencies = {"heliara-briefing"},
            -- trigger = {
            --     type = "research",
            --     technology = "solar_reflector",
            -- },
        },
    },
}
