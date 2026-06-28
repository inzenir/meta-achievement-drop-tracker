--[[ Whether a source is still loot-eligible (daily / weekly lockouts) ]]

local Eligibility = {}
DropTracker.Eligibility = Eligibility

local function isQuestLootEligible(lock)
    local questId = lock.id
    if questId == nil then
        return nil
    end
    if C_QuestLog then
        if lock.account and C_QuestLog.IsQuestFlaggedCompletedOnAccount then
            return not C_QuestLog.IsQuestFlaggedCompletedOnAccount(questId)
        end
        if C_QuestLog.IsQuestFlaggedCompleted then
            return not C_QuestLog.IsQuestFlaggedCompleted(questId)
        end
    end
    return nil
end

function Eligibility.IsLootEligible(expansion, sourceDef)
    local lock = sourceDef and sourceDef.lootLock
    if not lock then
        return nil
    end

    local lockType = lock.type or DropTracker.LootLockType.quest
    if lockType == DropTracker.LootLockType.quest then
        return isQuestLootEligible(lock)
    end

    return nil
end

function Eligibility.ApplySourceRowColor(fontString, eligible)
    if eligible == false then
        fontString:SetTextColor(0.5, 0.5, 0.5)
    elseif eligible == true then
        fontString:SetTextColor(0.78, 0.88, 0.78)
    else
        fontString:SetTextColor(0.9, 0.9, 0.9)
    end
end

function Eligibility.SummarizeItem(expansion, item)
    local eligibleCount = 0
    local knownCount = 0

    for _, sourceDef in ipairs(item and item.sources or {}) do
        local eligible = Eligibility.IsLootEligible(expansion, sourceDef)
        if eligible ~= nil then
            knownCount = knownCount + 1
            if eligible then
                eligibleCount = eligibleCount + 1
            end
        end
    end

    return {
        eligibleCount = eligibleCount,
        knownCount = knownCount,
        allLocked = knownCount > 0 and eligibleCount == 0,
    }
end

function Eligibility.ApplyItemNameColor(fontString, obtained, lootSummary)
    if obtained then
        fontString:SetTextColor(0.5, 0.9, 0.5)
    elseif lootSummary and lootSummary.allLocked then
        fontString:SetTextColor(0.5, 0.5, 0.5)
    else
        fontString:SetTextColor(1, 0.82, 0)
    end
end
