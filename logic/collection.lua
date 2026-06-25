--[[ Whether the player owns a tracked mount or toy ]]

local Collection = {}
DropTracker.Collection = Collection

function Collection.IsMountCollected(mountId)
    mountId = tonumber(mountId)
    if not mountId then
        return false
    end
    if C_MountJournal and C_MountJournal.GetMountInfoByID then
        local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountId)
        return isCollected == true
    end
    return false
end

function Collection.IsToyCollected(itemId)
    itemId = tonumber(itemId)
    if not itemId then
        return false
    end
    if PlayerHasToy then
        return PlayerHasToy(itemId) == true
    end
    return false
end

function Collection.IsCollected(collectionType, collectionId)
    if collectionType == DropTracker.CollectionType.mount then
        return Collection.IsMountCollected(collectionId)
    end
    if collectionType == DropTracker.CollectionType.toy then
        return Collection.IsToyCollected(collectionId)
    end
    return false
end
