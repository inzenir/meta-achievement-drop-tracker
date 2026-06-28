--[[ Per-source and combined drop probability helpers ]]

local Probability = {}
DropTracker.Probability = Probability

function Probability.PerSourceMissing(chance, attempts)
    local c = tonumber(chance) or 0
    local n = tonumber(attempts) or 0
    if c <= 0 or n <= 0 then
        return 1
    end
    if c >= 1 then
        return 0
    end
    return (1 - c) ^ n
end

--- Combined P(still missing) across independent sources.
--- @param sources table[] { chance = number, attempts = number }
function Probability.CombinedMissing(sources)
    local combined = 1
    for _, row in ipairs(sources or {}) do
        combined = combined * Probability.PerSourceMissing(row.chance, row.attempts)
    end
    return combined
end

function Probability.CombinedRemainingPercent(sources)
    return Probability.CombinedMissing(sources) * 100
end

function Probability.PerSourceObtained(chance, attempts)
    return 1 - Probability.PerSourceMissing(chance, attempts)
end

function Probability.CombinedObtained(sources)
    return 1 - Probability.CombinedMissing(sources)
end

function Probability.CombinedObtainedPercent(sources)
    return Probability.CombinedObtained(sources) * 100
end

function Probability.PerSourceObtainedPercent(chance, attempts)
    return Probability.PerSourceObtained(chance, attempts) * 100
end

function Probability.TotalAttempts(sources)
    local total = 0
    for _, row in ipairs(sources or {}) do
        total = total + (tonumber(row.attempts) or 0)
    end
    return total
end
