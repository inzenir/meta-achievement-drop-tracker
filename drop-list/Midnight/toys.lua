--[[
  Midnight transformation / raid toys.
  collectionId is the toy item id (PlayerHasToy).
  Raid encounter sources omit variant so kills on any difficulty count.
]]

DropTrackerCatalog:RegisterList("Midnight", DropTracker.CollectionType.toy, {
    {
        name = "Saptor Salve",
        collectionId = 268728,
        dropItemId = 268728,
        sources = {
            {
                kind = DropTracker.SourceKind.encounter,
                id = 3202,
                variant = DropTracker.Variant.mythic,
                contentType = DropTracker.SourceContentType.dungeon,
                chance = 1 / 100,
                label = "Ziekket",
                locations = { { mapId = DropTracker.Maps.midnight.blinding_vale } },
            },
        },
    },
    {
        name = "Cosmic Ritual Stone",
        collectionId = 264672,
        dropItemId = 264672,
        sources = {
            {
                kind = DropTracker.SourceKind.encounter,
                id = 3179,
                chance = 1 / 20,
                label = "Fallen-King Salhadaar",
                locations = { { mapId = DropTracker.Maps.midnight.voidspire } },
            },
        },
    },
    {
        name = "Madcap Redcap",
        collectionId = 264313,
        dropItemId = 264313,
        sources = {
            {
                kind = DropTracker.SourceKind.encounter,
                id = 3159,
                chance = 1 / 20,
                label = "Rotmire",
                locations = { { mapId = DropTracker.Maps.midnight.sporefall } },
            },
        },
    },
    {
        name = "Mycomancer's Hearthspore",
        collectionId = 264367,
        dropItemId = 264367,
        sources = {
            {
                kind = DropTracker.SourceKind.encounter,
                id = 3159,
                chance = 1 / 20,
                label = "Rotmire",
                locations = { { mapId = DropTracker.Maps.midnight.sporefall } },
            },
        },
    },
})
