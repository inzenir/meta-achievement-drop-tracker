--[[ Load drop-list files and build runtime indexes ]]

DropTrackerCatalog = DropTrackerCatalog or { _lists = {} }

local Catalog = {}
DropTracker.Catalog = Catalog

local lists = DropTrackerCatalog._lists

function DropTrackerCatalog:RegisterList(expansion, collectionType, entries)
    if type(expansion) ~= "string" or type(collectionType) ~= "string" or type(entries) ~= "table" then
        return
    end
    lists[expansion] = lists[expansion] or {}
    lists[expansion][collectionType] = entries
end

local function resolveCollectionId(collectionType, entry)
    if entry.collectionId ~= nil then
        return entry.collectionId
    end
    if collectionType ~= DropTracker.CollectionType.mount or not C_MountJournal then
        return entry.collectionId
    end
    if entry.dropItemId and C_MountJournal.GetMountFromItem then
        local mountId = C_MountJournal.GetMountFromItem(entry.dropItemId)
        if mountId and mountId > 0 then
            return mountId
        end
    end
    return nil
end

local function normalizeItem(expansion, collectionType, entry)
    local collectionId = resolveCollectionId(collectionType, entry)
    local item = {
        expansion = expansion,
        collectionType = collectionType,
        collectionId = collectionId,
        name = entry.name,
        dropItemId = entry.dropItemId,
        listGroup = entry.listGroup,
        sources = entry.sources or {},
    }
    if not item.listGroup and DropTracker.ListGroups and DropTracker.ListGroups.Resolve then
        item.listGroup = DropTracker.ListGroups.Resolve(item)
    end
    return item
end

function Catalog.BuildIndexes()
    Catalog.expansions = {}
    Catalog.itemsByExpansion = {}
    Catalog.itemByKey = {}
    Catalog.bySourceKey = {}
    Catalog.byStatId = {}

    local expansionSet = {}
    for expansion, types in pairs(lists) do
        expansionSet[expansion] = true
        Catalog.itemsByExpansion[expansion] = Catalog.itemsByExpansion[expansion] or {}

        for collectionType, entries in pairs(types) do
            Catalog.itemByKey[collectionType] = Catalog.itemByKey[collectionType] or {}

            for _, entry in ipairs(entries) do
                local item = normalizeItem(expansion, collectionType, entry)
                local collectionId = item.collectionId
                if collectionId ~= nil then
                    Catalog.itemByKey[collectionType][collectionId] = item
                    table.insert(Catalog.itemsByExpansion[expansion], item)

                    for _, sourceDef in ipairs(item.sources) do
                        local sourceKey = DropTracker.SourceKey.FromSourceDef(sourceDef)
                        if sourceKey then
                            local link = {
                                expansion = expansion,
                                collectionType = collectionType,
                                collectionId = collectionId,
                                item = item,
                                sourceDef = sourceDef,
                                sourceKey = sourceKey,
                            }
                            Catalog.bySourceKey[sourceKey] = Catalog.bySourceKey[sourceKey] or {}
                            table.insert(Catalog.bySourceKey[sourceKey], link)

                            if sourceDef.statId ~= nil then
                                local statId = sourceDef.statId
                                Catalog.byStatId[statId] = Catalog.byStatId[statId] or {}
                                table.insert(Catalog.byStatId[statId], link)
                            end
                        end
                    end
                end
            end
        end
    end

    for expansion in pairs(expansionSet) do
        table.insert(Catalog.expansions, expansion)
    end
    table.sort(Catalog.expansions)
end

function Catalog.GetExpansions()
    return Catalog.expansions or {}
end

function Catalog.GetItemsForExpansion(expansion)
    return Catalog.itemsByExpansion and Catalog.itemsByExpansion[expansion] or {}
end

function Catalog.GetItem(collectionType, collectionId)
    local bucket = Catalog.itemByKey and Catalog.itemByKey[collectionType]
    return bucket and bucket[collectionId] or nil
end

function Catalog.GetLinksBySourceKey(sourceKey)
    return Catalog.bySourceKey and Catalog.bySourceKey[sourceKey] or {}
end

function Catalog.GetLinksByStatId(statId)
    return Catalog.byStatId and Catalog.byStatId[statId] or {}
end
