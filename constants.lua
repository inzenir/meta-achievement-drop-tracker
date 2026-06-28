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

DropTracker.LootLockType = {
    quest = "quest",
    encounter = "encounter",
    worldBoss = "worldBoss",
}

-- Item list grouping (explicit listGroup on item/source overrides inference).
DropTracker.ListGroup = {
    raid = "raid",
    dungeon = "dungeon",
    world = "world",
    paragon = "paragon",
    other = "other",
}

DropTracker.SourceContentType = {
    raid = "raid",
    dungeon = "dungeon",
}

DropTracker.Maps = {
    midnight = {
        harandar = 2413,
        eversong_woods = 2395,
        zulaman = 2437,
        voidstorm = 2405,
        slayers_rise = 2444,
        windrunner_spire = 2805,
        magisters_terrace = 2811,
        march_on_queldanas = 2913,
        voidspire = 2912,
        sporefall = 16279,
        blinding_vale = 2859,
    },
    the_war_within = {
        isle_of_dorn = 2248,
        ringing_deeps = 2214,
        hallowfall = 2215,
        azj_kahet = 2255,
        undermine = 2346,
        siren_isle = 2369,
        karesh = 2371,
        tazavesh = 2472,
        nerub_ar_palace = 2657,
        liberation_of_undermine = 2769,
        stonevault = 2652,
        darkflame_cleft = 2651,
        manaforge_omega = 2810,
    },
}
