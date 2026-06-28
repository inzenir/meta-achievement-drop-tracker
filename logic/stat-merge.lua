--[[ One-time per-character Blizzard statistic import ]]

local StatMerge = {}
DropTracker.StatMerge = StatMerge

function StatMerge.RunForCurrentCharacter()
    if not DropTracker.Catalog or not DropTracker.Catalog.byStatId then
        return
    end

    for statId, links in pairs(DropTracker.Catalog.byStatId) do
        if DropTracker.Storage.GetStatMerged(statId) == nil then
            local count = DropTracker.Statistics.GetCounter(statId)
            DropTracker.Storage.SetStatMerged(statId, count)

            for _, link in ipairs(links) do
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
