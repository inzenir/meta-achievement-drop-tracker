--[[ Drop Tracker bootstrap ]]

function DropTracker.Bootstrap()
    DropTracker.Storage.Init()
    DropTracker.Catalog.BuildIndexes()
    DropTracker.RegisterPlugin()
end

function DropTracker.OnPlayerEnteringWorld()
    DropTracker.StatMerge.RunForCurrentCharacter()
    DropTracker.Obtained.ScanAll()
    DropTracker.Events.Enable()

    if DropTracker.UI and DropTracker.UI.Controller then
        DropTracker.UI.Controller.Refresh()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MetaAchievement_DropTracker" then
        DropTracker.Bootstrap()
    elseif event == "PLAYER_ENTERING_WORLD" then
        DropTracker.OnPlayerEnteringWorld()
    end
end)
