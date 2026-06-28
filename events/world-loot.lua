--[[ LOOT_OPENED — world rare corpses and chest / cache objects ]]

DropTracker.Events = DropTracker.Events or {}
local WorldLoot = {}
DropTracker.Events.WorldLoot = WorldLoot

local lastLootKey = nil
local lastLootTime = 0
local DEDUPE_SECONDS = 2

local function idFromGuid(guid, unitTypes)
    if type(guid) ~= "string" then
        return nil
    end
    local unitType, _, _, _, _, id = strsplit("-", guid)
    for index = 1, #unitTypes do
        if unitType == unitTypes[index] then
            return tonumber(id)
        end
    end
    return nil
end

local function npcIdFromGuid(guid)
    return idFromGuid(guid, { "Creature", "Vehicle" })
end

local function objectIdFromGuid(guid)
    return idFromGuid(guid, { "GameObject" })
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

local function shouldDedupe(dedupeKey)
    local now = GetTime()
    if dedupeKey == lastLootKey and (now - lastLootTime) < DEDUPE_SECONDS then
        return true
    end
    lastLootKey = dedupeKey
    lastLootTime = now
    return false
end

local function tryIncrementKeys(keys)
    local links = DropTracker.Catalog.bySourceKey
    if not links then
        return false
    end

    for _, sourceKey in ipairs(keys) do
        if links[sourceKey] then
            DropTracker.Attempts.IncrementBySourceKey(sourceKey, 1)
            return true
        end
    end
    return false
end

local function tryIncrementItem(objectId)
    return tryIncrementKeys({
        DropTracker.SourceKey.Make(DropTracker.SourceKind.item, objectId, DropTracker.Variant.mythic),
        DropTracker.SourceKey.Make(DropTracker.SourceKind.item, objectId, nil),
    })
end

local function tryIncrementNpc(npcId)
    return tryIncrementKeys({
        DropTracker.SourceKey.Make(DropTracker.SourceKind.npc, npcId, DropTracker.Variant.world),
        DropTracker.SourceKey.Make(DropTracker.SourceKind.npc, npcId, nil),
    })
end

function WorldLoot.OnLootOpened()
    local guid = lootSourceGuid()
    if not guid or shouldDedupe(guid) then
        return
    end

    local objectId = objectIdFromGuid(guid)
    if objectId and tryIncrementItem(objectId) then
        return
    end

    local npcId = npcIdFromGuid(guid)
    if npcId then
        tryIncrementNpc(npcId)
    end
end
