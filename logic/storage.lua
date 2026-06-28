--[[ DropTrackerDB, DropTrackerCharDB, DropTrackerSettings ]]

local Storage = {}
DropTracker.Storage = Storage

local function defaultSettings()
    return {
        lastExpansion = nil,
        lastCollectionType = nil,
        lastCollectionId = nil,
        sourceDetailExpanded = false,
        hideCollectedMounts = false,
        hideFarmed = false,
    }
end

function Storage.Init()
    DropTrackerDB = DropTrackerDB or {}
    DropTrackerDB.schemaVersion = DropTrackerDB.schemaVersion or DropTracker.SCHEMA_VERSION
    DropTrackerDB.items = DropTrackerDB.items or {}

    DropTrackerSettings = DropTrackerSettings or defaultSettings()

    DropTrackerCharDB = DropTrackerCharDB or {}
    DropTrackerCharDB.statMerged = DropTrackerCharDB.statMerged or {}
end

function Storage.GetSettings()
    return DropTrackerSettings
end

function Storage.GetSetting(key)
    local settings = DropTrackerSettings or {}
    if settings[key] ~= nil then
        return settings[key]
    end
    return defaultSettings()[key]
end

function Storage.SetSetting(key, value)
    DropTrackerSettings = DropTrackerSettings or defaultSettings()
    DropTrackerSettings[key] = value
end

function Storage.EnsureItemRecord(collectionType, collectionId)
    DropTrackerDB.items[collectionType] = DropTrackerDB.items[collectionType] or {}
    local bucket = DropTrackerDB.items[collectionType]
    if not bucket[collectionId] then
        bucket[collectionId] = {
            obtained = false,
            obtainedAt = nil,
            sources = {},
        }
    end
    return bucket[collectionId]
end

function Storage.GetItemRecord(collectionType, collectionId)
    local typeBucket = DropTrackerDB and DropTrackerDB.items and DropTrackerDB.items[collectionType]
    return typeBucket and typeBucket[collectionId] or nil
end

function Storage.GetSourceAttempts(collectionType, collectionId, sourceKey)
    local record = Storage.GetItemRecord(collectionType, collectionId)
    if not record or not record.sources then
        return 0
    end
    local source = record.sources[sourceKey]
    return source and (source.attempts or 0) or 0
end

function Storage.AddSourceAttempts(collectionType, collectionId, sourceKey, delta)
    delta = delta or 1
    local record = Storage.EnsureItemRecord(collectionType, collectionId)
    record.sources[sourceKey] = record.sources[sourceKey] or { attempts = 0 }
    record.sources[sourceKey].attempts = (record.sources[sourceKey].attempts or 0) + delta
end

function Storage.GetStatMerged(statId)
    return DropTrackerCharDB.statMerged and DropTrackerCharDB.statMerged[statId]
end

function Storage.SetStatMerged(statId, value)
    DropTrackerCharDB.statMerged[statId] = value
end
