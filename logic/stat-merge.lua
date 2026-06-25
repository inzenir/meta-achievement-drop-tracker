--[[ One-time per-character Blizzard statistic import ]]

local StatMerge = {}
DropTracker.StatMerge = StatMerge

local function readStatisticValue(statId)
    if not GetStatistic then
        return 0
    end
    local value = GetStatistic(statId)
    if value == nil or value == "" or value == "--" then
        return 0
    end
    return tonumber(value) or 0
end

function StatMerge.RunForCurrentCharacter()
    if not DropTracker.Catalog or not DropTracker.Catalog.byStatId then
        return
    end

    for statId, links in pairs(DropTracker.Catalog.byStatId) do
        if DropTracker.Storage.GetStatMerged(statId) == nil then
            local count = readStatisticValue(statId)
            DropTracker.Storage.SetStatMerged(statId, count)

            for _, link in ipairs(links) do
                local record = DropTracker.Storage.GetItemRecord(link.collectionType, link.collectionId)
                if not record or not record.obtained then
                    DropTracker.Storage.AddSourceAttempts(
                        link.collectionType,
                        link.collectionId,
                        link.sourceKey,
                        count
                    )
                end
            end
        end
    end
end
