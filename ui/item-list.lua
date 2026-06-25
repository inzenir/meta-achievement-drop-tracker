--[[ Center panel: item rows (icon, name, attempts, % ) — Phase 3 ]]

local ItemList = {}
DropTracker.UI.ItemList = ItemList

function ItemList.Create(parent, onSelect)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 148, 0)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -220, 0)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)

    frame.Scroll = scroll
    frame.Content = content
    frame._rows = {}
    frame._onSelect = onSelect

    function frame:Rebuild(items, selectedItem, rowBuilder)
        for _, row in ipairs(self._rows) do
            row:Hide()
        end
        wipe(self._rows)

        local y = 0
        local maxWidth = self:GetWidth() or 200
        for _, item in ipairs(items or {}) do
            local row = rowBuilder(self.Content, item, maxWidth)
            if row then
                row:SetPoint("TOPLEFT", 0, y)
                row:SetScript("OnClick", function()
                    if self._onSelect then
                        self._onSelect(item)
                    end
                end)
                table.insert(self._rows, row)
                y = y - (row:GetHeight() or 24) - 2
            end
        end
        self.Content:SetSize(maxWidth, math.max(1, -y))
    end

    return frame
end

function ItemList.BuildSimpleRow(parent, item, display)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(parent:GetWidth() or 200, 24)
    row:SetNormalFontObject("GameFontHighlight")

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 4, 0)
    text:SetText(display or item.name or "?")

    row.Item = item
  row.Label = text
    return row
end

function ItemList.FormatRowLabel(item)
    local collectionType = item.collectionType
    local collectionId = item.collectionId
    local record = DropTracker.Storage.GetItemRecord(collectionType, collectionId)
    local sourceRows = {}

    for _, sourceDef in ipairs(item.sources or {}) do
        local sourceKey = DropTracker.SourceKey.FromSourceDef(sourceDef)
        local attempts = DropTracker.Storage.GetSourceAttempts(collectionType, collectionId, sourceKey)
        sourceRows[#sourceRows + 1] = {
            chance = sourceDef.chance,
            attempts = attempts,
        }
    end

    local total = DropTracker.Probability.TotalAttempts(sourceRows)
    local pct = DropTracker.Probability.CombinedRemainingPercent(sourceRows)
    local obtained = record and record.obtained
    local suffix = obtained and " (obtained)" or ""
    return string.format("%s — %d tries, %.2f%% missing%s", item.name or "?", total, pct, suffix)
end
