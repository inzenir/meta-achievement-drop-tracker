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

function Collection.GetIcon(collectionType, collectionId, dropItemId)
    collectionId = tonumber(collectionId)
    dropItemId = tonumber(dropItemId)

    if collectionType == DropTracker.CollectionType.mount and collectionId and C_MountJournal and C_MountJournal.GetMountInfoByID then
        local _, _, icon = C_MountJournal.GetMountInfoByID(collectionId)
        if icon then
            return icon
        end
    end

    if dropItemId then
        if C_Item and C_Item.GetItemIconByID then
            local icon = C_Item.GetItemIconByID(dropItemId)
            if icon then
                return icon
            end
        end
        if GetItemIcon then
            return GetItemIcon(dropItemId)
        end
    end

    return 134400 -- question mark icon
end
