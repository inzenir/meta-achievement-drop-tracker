--[[ Increment per-source attempt counters on linked items ]]

local Attempts = {}
DropTracker.Attempts = Attempts

function Attempts.IncrementBySourceKey(sourceKey, delta)
    if not sourceKey then
        return
    end
    delta = delta or 1
    local links = DropTracker.Catalog.GetLinksBySourceKey(sourceKey)
    for _, link in ipairs(links) do
        local record = DropTracker.Storage.GetItemRecord(link.collectionType, link.collectionId)
        if not record or not record.obtained then
            DropTracker.Storage.AddSourceAttempts(
                link.collectionType,
                link.collectionId,
                sourceKey,
                delta
            )
        end
    end
end

function Attempts.IncrementByEncounter(encounterId, variant, delta)
    local sourceKey = DropTracker.SourceKey.Make(DropTracker.SourceKind.encounter, encounterId, variant)
    Attempts.IncrementBySourceKey(sourceKey, delta)
end
