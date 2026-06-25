--[[ Event frame registration ]]

DropTracker.Events = DropTracker.Events or {}

local eventFrame = nil
local enabled = false

local function onEvent(_, event, ...)
    if event == "ENCOUNTER_END" then
        if DropTracker.Events.EncounterEnd then
            DropTracker.Events.EncounterEnd.OnEvent(...)
        end
    elseif event == "NEW_TOY_ADDED" then
        local itemID = ...
        if DropTracker.Events.Collection then
            DropTracker.Events.Collection.OnNewToy(itemID)
        end
    elseif event == "NEW_MOUNT_ADDED" then
        local mountID = ...
        if DropTracker.Events.Collection then
            DropTracker.Events.Collection.OnNewMount(mountID)
        end
    elseif event == "LOOT_OPENED" then
        if DropTracker.Events.WorldLoot then
            DropTracker.Events.WorldLoot.OnLootOpened()
        end
    end
end

function DropTracker.Events.Enable()
    if enabled then
        return
    end
    eventFrame = eventFrame or CreateFrame("Frame")
    eventFrame:RegisterEvent("ENCOUNTER_END")
    eventFrame:RegisterEvent("NEW_MOUNT_ADDED")
    eventFrame:RegisterEvent("NEW_TOY_ADDED")
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:SetScript("OnEvent", onEvent)
    enabled = true
end
