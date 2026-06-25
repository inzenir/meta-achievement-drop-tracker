--[[ Settings UI via MetaAchievementPlugins.CreateOptionsProvider — Phase 4 ]]

local OptionsProvider = {}

function OptionsProvider.Create()
    if not MetaAchievementPlugins or not MetaAchievementPlugins.CreateOptionsProvider then
        return nil
    end
    return MetaAchievementPlugins.CreateOptionsProvider({
        pluginId = DropTracker.PLUGIN_ID,
        defaults = {},
        definitions = {},
    })
end

DropTracker.OptionsProvider = OptionsProvider
