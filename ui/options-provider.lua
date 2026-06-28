--[[ Settings UI via MetaAchievementPlugins.CreateOptionsProvider ]]

local OptionsProvider = {}

local function defaultSettings()
    return {
        sourceDetailExpanded = false,
    }
end

function OptionsProvider.Create()
    if not MetaAchievementPlugins or not MetaAchievementPlugins.CreateOptionsProvider then
        return nil
    end

    local provider = MetaAchievementPlugins.CreateOptionsProvider({
        pluginId = DropTracker.PLUGIN_ID,
        defaults = defaultSettings(),
        definitions = {
            {
                variable = "sourceDetailExpanded",
                name = "Expanded source details",
                tooltip = "Show drop chance, variant, and waypoint hints for each source in the detail panel.",
                varType = "boolean",
            },
        },
    })

    if not provider then
        return nil
    end

    function provider:Get(key)
        return DropTracker.Storage.GetSetting(key)
    end

    function provider:Set(key, value)
        local oldValue = DropTracker.Storage.GetSetting(key)
        DropTracker.Storage.SetSetting(key, value)
        self:EmitChange(key, value, oldValue)
        if key == "sourceDetailExpanded" and DropTracker.UI and DropTracker.UI.Controller then
            DropTracker.UI.Controller.Refresh()
        end
    end

    function provider:GetDbTable()
        return DropTrackerSettings or {}
    end

    function provider:GetDefaults()
        return defaultSettings()
    end

    provider:RegisterListener("sourceDetailExpanded", function()
        if DropTracker.UI and DropTracker.UI.Controller then
            DropTracker.UI.Controller.Refresh()
        end
    end)

    return provider
end

DropTracker.OptionsProvider = OptionsProvider
