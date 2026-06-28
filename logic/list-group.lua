--[[ Resolve list groups for item list sections ]]

local ListGroup = {}
DropTracker.ListGroups = ListGroup

local GROUP_SEQUENCE = {
    DropTracker.ListGroup.raid,
    DropTracker.ListGroup.dungeon,
    DropTracker.ListGroup.world,
    DropTracker.ListGroup.paragon,
    DropTracker.ListGroup.other,
}

local GROUP_LABELS = {
    [DropTracker.ListGroup.raid] = "Raid",
    [DropTracker.ListGroup.dungeon] = "Dungeons",
    [DropTracker.ListGroup.world] = "World Drops",
    [DropTracker.ListGroup.paragon] = "Paragon Chests",
    [DropTracker.ListGroup.other] = "Other",
}

local GROUP_ORDER = {}
for index, groupId in ipairs(GROUP_SEQUENCE) do
    GROUP_ORDER[groupId] = index
end

local function groupPriority(groupId)
    return GROUP_ORDER[groupId] or #GROUP_SEQUENCE + 1
end

function ListGroup.GetLabel(groupId)
    return GROUP_LABELS[groupId] or GROUP_LABELS[DropTracker.ListGroup.other]
end

function ListGroup.GetSequence()
    return GROUP_SEQUENCE
end

function ListGroup.FromSource(sourceDef)
    if not sourceDef then
        return DropTracker.ListGroup.other
    end

    if sourceDef.listGroup then
        return sourceDef.listGroup
    end

    local kind = sourceDef.kind
    if kind == DropTracker.SourceKind.encounter then
        if sourceDef.contentType == DropTracker.SourceContentType.dungeon then
            return DropTracker.ListGroup.dungeon
        end
        return DropTracker.ListGroup.raid
    end

    if kind == DropTracker.SourceKind.bonusroll or kind == DropTracker.SourceKind.satchel then
        return DropTracker.ListGroup.raid
    end

    if kind == DropTracker.SourceKind.item then
        if sourceDef.paragon then
            return DropTracker.ListGroup.paragon
        end
        local label = (sourceDef.label or ""):lower()
        if label:find("paragon", 1, true) then
            return DropTracker.ListGroup.paragon
        end
        if sourceDef.statId then
            return DropTracker.ListGroup.dungeon
        end
        return DropTracker.ListGroup.other
    end

    if kind == DropTracker.SourceKind.npc then
        local lock = sourceDef.lootLock
        if lock and lock.type == DropTracker.LootLockType.worldBoss then
            return DropTracker.ListGroup.world
        end
        if sourceDef.variant == DropTracker.Variant.world then
            return DropTracker.ListGroup.world
        end
        return DropTracker.ListGroup.world
    end

    return DropTracker.ListGroup.other
end

function ListGroup.Resolve(item)
    if not item then
        return DropTracker.ListGroup.other
    end

    if item.listGroup then
        return item.listGroup
    end

    local bestGroup = DropTracker.ListGroup.other
    local bestOrder = groupPriority(bestGroup)

    for _, sourceDef in ipairs(item.sources or {}) do
        local groupId = ListGroup.FromSource(sourceDef)
        local order = groupPriority(groupId)
        if order < bestOrder then
            bestOrder = order
            bestGroup = groupId
        end
    end

    return bestGroup
end

function ListGroup.BuildSections(items)
    local byGroup = {}

    for _, item in ipairs(items or {}) do
        local groupId = ListGroup.Resolve(item)
        byGroup[groupId] = byGroup[groupId] or {}
        table.insert(byGroup[groupId], item)
    end

    local sections = {}
    for _, groupId in ipairs(GROUP_SEQUENCE) do
        local groupItems = byGroup[groupId]
        if groupItems and #groupItems > 0 then
            table.sort(groupItems, function(a, b)
                return (a.name or ""):lower() < (b.name or ""):lower()
            end)
            sections[#sections + 1] = {
                groupId = groupId,
                label = ListGroup.GetLabel(groupId),
                items = groupItems,
            }
        end
    end

    return sections
end
