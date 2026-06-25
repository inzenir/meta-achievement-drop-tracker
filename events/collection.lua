--[[ NEW_MOUNT_ADDED, NEW_TOY_ADDED ]]

DropTracker.Events = DropTracker.Events or {}
DropTracker.Events.Collection = DropTracker.Events.Collection or {}

function DropTracker.Events.Collection.OnNewMount(mountID)
    if not DropTracker.Obtained or not mountID then
        return
    end
    DropTracker.Obtained.OnCollectionAdded(DropTracker.CollectionType.mount, mountID)
end

function DropTracker.Events.Collection.OnNewToy(itemID)
    if DropTracker.Obtained then
        DropTracker.Obtained.OnCollectionAdded(DropTracker.CollectionType.toy, itemID)
    end
end
