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
    local kind = DropTracker.SourceKind.encounter
    local variantKey = DropTracker.SourceKey.Make(kind, encounterId, variant)
    local baseKey = DropTracker.SourceKey.Make(kind, encounterId, nil)

    if #DropTracker.Catalog.GetLinksBySourceKey(variantKey) > 0 then
        Attempts.IncrementBySourceKey(variantKey, delta)
    end
    if #DropTracker.Catalog.GetLinksBySourceKey(baseKey) > 0 then
        Attempts.IncrementBySourceKey(baseKey, delta)
    end
end
