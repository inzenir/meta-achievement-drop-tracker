--[[ World boss / outdoor npc — increment when looting the corpse ]]

DropTracker.Events = DropTracker.Events or {}
local WorldLoot = {}
DropTracker.Events.WorldLoot = WorldLoot

local lastLootKey = nil
local lastLootTime = 0
local DEDUPE_SECONDS = 2

local function npcIdFromGuid(guid)
    if type(guid) ~= "string" then
        return nil
    end
    local unitType, _, _, _, _, id = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(id)
    end
    return nil
end

local function lootSourceGuid()
    if not GetNumLootItems or not GetLootSourceInfo then
        return nil
    end
    local numLoot = GetNumLootItems()
    for slot = 1, numLoot do
        local guid = GetLootSourceInfo(slot)
        if guid and guid ~= "" then
            return guid
        end
    end
    return nil
end

function WorldLoot.OnLootOpened()
    local guid = lootSourceGuid()
    local npcId = npcIdFromGuid(guid)
    if not npcId then
        return
    end

    local dedupeKey = guid
    local now = GetTime()
    if dedupeKey == lastLootKey and (now - lastLootTime) < DEDUPE_SECONDS then
        return
    end
    lastLootKey = dedupeKey
    lastLootTime = now

    local links = DropTracker.Catalog.bySourceKey
    if not links then
        return
    end

    -- World rares use variant=world; try that first, then variant-less key.
    local keys = {
        DropTracker.SourceKey.Make(DropTracker.SourceKind.npc, npcId, DropTracker.Variant.world),
        DropTracker.SourceKey.Make(DropTracker.SourceKind.npc, npcId, nil),
    }
    for _, sourceKey in ipairs(keys) do
        if links[sourceKey] then
            DropTracker.Attempts.IncrementBySourceKey(sourceKey, 1)
            return
        end
    end
end
