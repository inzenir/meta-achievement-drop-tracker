--[[ Right panel: per-source detail — Phase 3 ]]

local DetailPanel = {}
DropTracker.UI.DetailPanel = DetailPanel

function DetailPanel.Create(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(210)
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.Title:SetPoint("TOPLEFT", 8, -8)
    frame.Title:SetPoint("RIGHT", -8, 0)
    frame.Title:SetJustifyH("LEFT")

    frame.Body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.Body:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -8)
    frame.Body:SetPoint("RIGHT", -8, 0)
    frame.Body:SetJustifyH("LEFT")
    frame.Body:SetWordWrap(true)

    function frame:SetItem(item)
        if not item then
            self.Title:SetText("")
            self.Body:SetText("")
            return
        end

        local lines = {}
        local collectionType = item.collectionType
        local collectionId = item.collectionId
        local record = DropTracker.Storage.GetItemRecord(collectionType, collectionId)

        for _, sourceDef in ipairs(item.sources or {}) do
            local sourceKey = DropTracker.SourceKey.FromSourceDef(sourceDef)
            local attempts = DropTracker.Storage.GetSourceAttempts(collectionType, collectionId, sourceKey)
            local missing = DropTracker.Probability.PerSourceMissing(sourceDef.chance, attempts) * 100
            local title = sourceDef.label or sourceKey
            lines[#lines + 1] = string.format(
                "%s\n  %d tries, %.1f%% drop, %.2f%% still missing",
                title,
                attempts,
                (sourceDef.chance or 0) * 100,
                missing
            )
        end

        if record and record.obtained then
            lines[#lines + 1] = ""
            lines[#lines + 1] = "Obtained: " .. tostring(record.obtainedAt)
        end

        self.Title:SetText(item.name or "?")
        self.Body:SetText(table.concat(lines, "\n\n"))
    end

    return frame
end
