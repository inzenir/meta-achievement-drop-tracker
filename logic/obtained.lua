--[[ Obtained state: poll journal/toy box and freeze counters ]]

local Obtained = {}
DropTracker.Obtained = Obtained

function Obtained.Mark(collectionType, collectionId, obtainedAt)
    local record = DropTracker.Storage.EnsureItemRecord(collectionType, collectionId)
    if record.obtained then
        return
    end
    record.obtained = true
    record.obtainedAt = obtainedAt or DropTracker.OBTAINED_AT_UNKNOWN
end

function Obtained.ScanItem(item)
    if not item then
        return
    end
    local collectionType = item.collectionType
    local collectionId = item.collectionId
    if DropTracker.Collection.IsCollected(collectionType, collectionId) then
        local record = DropTracker.Storage.GetItemRecord(collectionType, collectionId)
        local obtainedAt = record and record.obtainedAt
        if not record or not record.obtained then
            Obtained.Mark(collectionType, collectionId, obtainedAt or DropTracker.OBTAINED_AT_UNKNOWN)
        end
    end
end

function Obtained.ScanAll()
    if not DropTracker.Catalog or not DropTracker.Catalog.itemsByExpansion then
        return
    end
    for _, items in pairs(DropTracker.Catalog.itemsByExpansion) do
        for _, item in ipairs(items) do
            Obtained.ScanItem(item)
        end
    end
end

function Obtained.OnCollectionAdded(collectionType, collectionId)
    Obtained.Mark(collectionType, collectionId, time())
end
