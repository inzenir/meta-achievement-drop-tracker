--[[ ENCOUNTER_END — instanced boss kills ]]

local EncounterEnd = {}
DropTracker.Events = DropTracker.Events or {}
DropTracker.Events.EncounterEnd = EncounterEnd

local DIFFICULTY_TO_VARIANT = {
    [1] = DropTracker.Variant.normal,
    [2] = DropTracker.Variant.heroic,
    [3] = DropTracker.Variant.mythic,
    [14] = DropTracker.Variant.normal,
    [15] = DropTracker.Variant.heroic,
    [16] = DropTracker.Variant.mythic,
    [17] = DropTracker.Variant.lfr,
}

function EncounterEnd.MapDifficultyToVariant(difficultyID)
    return DIFFICULTY_TO_VARIANT[difficultyID] or DropTracker.Variant.normal
end

function EncounterEnd.OnEvent(encounterID, _, difficultyID, _, success)
    if success ~= true then
        return
    end
    local variant = EncounterEnd.MapDifficultyToVariant(difficultyID)
    DropTracker.Attempts.IncrementByEncounter(encounterID, variant, 1)
end
