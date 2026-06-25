--[[ Drop Tracker — shared constants and enums ]]

DropTracker = DropTracker or {}

DropTracker.PLUGIN_ID = "drop-tracker"
DropTracker.SCHEMA_VERSION = 1

DropTracker.CollectionType = {
    mount = "mount",
    toy = "toy",
}

DropTracker.SourceKind = {
    encounter = "encounter",
    npc = "npc",
    item = "item",
    bonusroll = "bonusroll",
    satchel = "satchel",
}

-- Maps ENCOUNTER_END difficultyID → variant enum (extend as needed).
DropTracker.Variant = {
    world = "world",
    normal = "normal",
    heroic = "heroic",
    mythic = "mythic",
    lfr = "lfr",
}

DropTracker.OBTAINED_AT_UNKNOWN = "unknown"

DropTracker.Maps = {
    midnight = {
        harandar = 2413,
        eversong_woods = 2395,
        zulaman = 2437,
        voidstorm = 2405,
    },
}
