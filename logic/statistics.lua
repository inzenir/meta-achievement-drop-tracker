--[[ Blizzard statistics counters (statistic achievement IDs) ]]

local Statistics = {}
DropTracker.Statistics = Statistics

local function isMissingRaw(raw)
    return raw == nil or raw == "" or raw == "--"
end

function Statistics.ParseCounter(raw)
    if isMissingRaw(raw) then
        return 0
    end
    return tonumber(raw) or 0
end

local function readDirect(statisticAchievementId)
    if not GetStatistic then
        return nil
    end
    return GetStatistic(statisticAchievementId)
end

local function readFromCategories(statisticAchievementId)
    if not GetStatistic or not GetStatisticsCategoryList or not GetCategoryNumAchievements then
        return nil
    end

    local categories = GetStatisticsCategoryList()
    if type(categories) ~= "table" then
        return nil
    end

    for categoryIndex = 1, #categories do
        local categoryId = categories[categoryIndex]
        local numStats = GetCategoryNumAchievements(categoryId, true)
            or GetCategoryNumAchievements(categoryId)
            or 0
        for statIndex = 1, numStats do
            local quantity, skip, id = GetStatistic(categoryId, statIndex)
            if not skip and tonumber(id) == statisticAchievementId then
                return quantity
            end
        end
    end

    return nil
end

-- statisticAchievementId is the statistic's achievement ID (e.g. 61217).
-- GetStatistic(achievementId) returns the live counter string for that statistic.
function Statistics.GetCounter(statisticAchievementId)
    statisticAchievementId = tonumber(statisticAchievementId)
    if not statisticAchievementId then
        return 0
    end

    local raw = readDirect(statisticAchievementId)
    if not isMissingRaw(raw) then
        return Statistics.ParseCounter(raw)
    end

    raw = readFromCategories(statisticAchievementId)
    return Statistics.ParseCounter(raw)
end
