--[[ Register main-window plugin tab ]]

local function registerPlugin()
    if not MetaAchievementPlugins or not MetaAchievementPlugins.Register then
        return
    end

    local optionsProvider = DropTracker.OptionsProvider.Create()

    MetaAchievementPlugins.Register({
        id = DropTracker.PLUGIN_ID,
        title = "Drop Tracker",
        order = 50,
        optionsProvider = optionsProvider,
        onShow = function(mainFrame, contentHost)
            DropTracker.UI.Controller.OnTabShow(mainFrame, contentHost)
        end,
        onHide = function(mainFrame, contentHost)
            DropTracker.UI.Controller.OnTabHide()
        end,
    })
end

DropTracker.RegisterPlugin = registerPlugin
