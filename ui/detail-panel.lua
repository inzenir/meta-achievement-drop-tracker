--[[ Right panel: per-source detail ]]

local DetailPanel = {}
DropTracker.UI.DetailPanel = DetailPanel

local Util = DropTracker.UI.Util

local HEADER_ROW_HEIGHT = 18
local DATA_ROW_HEIGHT = 22
local ROW_GAP = 2
local SUMMARY_ROW_HEIGHT = 16
local SUMMARY_ROW_GAP = 2

local NARROW_COL_WIDTH = 60
local SCROLLBAR_INSET = (DropTracker.UI.Layout and DropTracker.UI.Layout.SCROLLBAR_INSET) or 28
-- MinimalScrollBar sits outside the scroll frame (gap + width reserved by SCROLLBAR_INSET).
local RIGHT_MARGIN = 4
local FIXED_RIGHT_WIDTH = RIGHT_MARGIN + (NARROW_COL_WIDTH * 3)

local COLUMN = {
    CHANCE_RIGHT = -RIGHT_MARGIN,
    DROP_RIGHT = -RIGHT_MARGIN - NARROW_COL_WIDTH,
    TRIES_RIGHT = -RIGHT_MARGIN - (NARROW_COL_WIDTH * 2),
}

local function computeSharedTextColumns(rowWidth)
    rowWidth = rowWidth or 0
    local available = math.max(0, rowWidth - FIXED_RIGHT_WIDTH)
    local zoneWidth = math.floor(available / 2)
    local sourceWidth = available - zoneWidth
    return {
        zoneWidth = zoneWidth,
        sourceWidth = sourceWidth,
        zoneRight = -FIXED_RIGHT_WIDTH,
        sourceRight = -(FIXED_RIGHT_WIDTH + zoneWidth),
    }
end

local function applySharedTextColumnLayout(nameTarget, zoneTarget, parent, layout)
    nameTarget:SetWidth(layout.sourceWidth)
    nameTarget:ClearAllPoints()
    nameTarget:SetPoint("RIGHT", parent, "RIGHT", layout.sourceRight, 0)

    zoneTarget:SetWidth(layout.zoneWidth)
    zoneTarget:ClearAllPoints()
    zoneTarget:SetPoint("RIGHT", parent, "RIGHT", layout.zoneRight, 0)
end

local function createColumnHeader(parent, text, rightOffset, width, justify)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    label:SetPoint("RIGHT", parent, "RIGHT", rightOffset, 0)
    label:SetWidth(width or NARROW_COL_WIDTH)
    label:SetJustifyH(justify or "CENTER")
    label:SetText(text)
    return label
end

local function createSummaryRow(parent, labelText, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(SUMMARY_ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 0, yOffset)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

    row.Label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.Label:SetPoint("LEFT", 0, 0)
    row.Label:SetJustifyH("LEFT")
    row.Label:SetText(labelText)

    row.Value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.Value:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.Value:SetJustifyH("RIGHT")

    return row
end

local function createTableRow(parent, width)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, DATA_ROW_HEIGHT)
    row:SetClipsChildren(true)

    row.Zone = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Zone:SetJustifyH("LEFT")
    row.Zone:SetWordWrap(false)

    row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Name:SetJustifyH("LEFT")
    row.Name:SetWordWrap(false)

    row.Attempts = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Attempts:SetPoint("RIGHT", row, "RIGHT", COLUMN.TRIES_RIGHT, 0)
    row.Attempts:SetWidth(NARROW_COL_WIDTH)
    row.Attempts:SetJustifyH("CENTER")

    row.Drop = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Drop:SetPoint("RIGHT", row, "RIGHT", COLUMN.DROP_RIGHT, 0)
    row.Drop:SetWidth(NARROW_COL_WIDTH)
    row.Drop:SetJustifyH("CENTER")

    row.Chance = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Chance:SetPoint("RIGHT", row, "RIGHT", COLUMN.CHANCE_RIGHT, 0)
    row.Chance:SetWidth(NARROW_COL_WIDTH)
    row.Chance:SetJustifyH("CENTER")

    row.Detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.Detail:SetPoint("TOPLEFT", row.Name, "BOTTOMLEFT", 0, -1)
    row.Detail:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.Detail:SetJustifyH("LEFT")
    row.Detail:Hide()

    return row
end

local function applyTableRowLayout(row, rowWidth)
    local layout = computeSharedTextColumns(rowWidth)
    applySharedTextColumnLayout(row.Name, row.Zone, row, layout)
    row.Detail:ClearAllPoints()
    row.Detail:SetPoint("TOPLEFT", row.Name, "BOTTOMLEFT", 0, -1)
    row.Detail:SetPoint("RIGHT", row, "RIGHT", layout.zoneRight, 0)
    return layout
end

local function updateTableRow(row, sourceRow, expanded, expansion)
    local sourceDef = sourceRow.sourceDef
    local attempts = sourceRow.attempts or 0
    local title = sourceDef.label or sourceRow.sourceKey or "?"
    local obtainedPct = DropTracker.Probability.PerSourceObtainedPercent(sourceDef.chance, attempts)
    local lootEligible = DropTracker.Eligibility.IsLootEligible(expansion, sourceDef)

    row.Name:SetText(title)
    row.Zone:SetText(Util.GetSourceZoneName(expansion, sourceDef))
    row.Attempts:SetText(tostring(attempts))
    row.Drop:SetText(Util.FormatChance(sourceDef.chance))
    row.Chance:SetText(Util.FormatPercent(obtainedPct, 2))

    DropTracker.Eligibility.ApplySourceRowColor(row.Name, lootEligible)
    DropTracker.Eligibility.ApplySourceRowColor(row.Zone, lootEligible)
    DropTracker.Eligibility.ApplySourceRowColor(row.Attempts, lootEligible)
    DropTracker.Eligibility.ApplySourceRowColor(row.Drop, lootEligible)
    DropTracker.Eligibility.ApplySourceRowColor(row.Chance, lootEligible)

    if expanded then
        local details = {}
        if sourceDef.variant and sourceDef.variant ~= "" then
            details[#details + 1] = tostring(sourceDef.variant)
        end
        if sourceDef.locations and #sourceDef.locations > 0 then
            local loc = sourceDef.locations[1]
            if loc and loc.x and loc.y then
                details[#details + 1] = string.format("%.1f, %.1f", loc.x, loc.y)
            end
        end
        if #details > 0 then
            row.Detail:SetText(table.concat(details, " · "))
            row.Detail:Show()
            row:SetHeight(DATA_ROW_HEIGHT + 12)
        else
            row.Detail:Hide()
            row:SetHeight(DATA_ROW_HEIGHT)
        end
    else
        row.Detail:Hide()
        row:SetHeight(DATA_ROW_HEIGHT)
    end
end

function DetailPanel.Create(parent)
    local listWidth = DropTracker.UI.Layout and DropTracker.UI.Layout.LIST_PANEL_WIDTH or 340

    local inset = Util.TryCreateInset(parent)
    inset:SetPoint("TOPLEFT", parent, "TOPLEFT", listWidth, 0)
    inset:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    if inset.EnableMouse then
        inset:EnableMouse(false)
    end

    local frame = CreateFrame("Frame", nil, inset)
    frame:SetPoint("TOPLEFT", 8, -8)
    frame:SetPoint("BOTTOMRIGHT", -8, 8)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(36, 36)
    frame.Icon:SetPoint("TOPLEFT", 4, -4)

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.Title:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 8, -2)
    frame.Title:SetPoint("RIGHT", -4, 0)
    frame.Title:SetJustifyH("LEFT")

    frame.SummaryBlock = CreateFrame("Frame", nil, frame)
    frame.SummaryBlock:SetPoint("TOPLEFT", frame.Icon, "BOTTOMLEFT", 0, -8)
    frame.SummaryBlock:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
    frame.SummaryBlock:SetHeight((SUMMARY_ROW_HEIGHT * 3) + (SUMMARY_ROW_GAP * 2))

    frame.SummaryTable = CreateFrame("Frame", nil, frame.SummaryBlock)
    frame.SummaryTable:SetAllPoints()

    local summaryRowStep = -(SUMMARY_ROW_HEIGHT + SUMMARY_ROW_GAP)
    frame.SummaryTable.TotalTries = createSummaryRow(frame.SummaryTable, "Total tries", 0)
    frame.SummaryTable.Sources = createSummaryRow(frame.SummaryTable, "Sources", summaryRowStep)
    frame.SummaryTable.Chance = createSummaryRow(frame.SummaryTable, "Chance to obtain", summaryRowStep * 2)

    frame.SummaryTable.Collected = createSummaryRow(frame.SummaryTable, "Status", 0)
    frame.SummaryTable.DateAcquired = createSummaryRow(frame.SummaryTable, "Date acquired", summaryRowStep)
    frame.SummaryTable.AttemptsWhenCollected = createSummaryRow(
        frame.SummaryTable,
        "Attempts when collected",
        summaryRowStep * 2
    )
    frame.SummaryTable.Collected:Hide()
    frame.SummaryTable.DateAcquired:Hide()
    frame.SummaryTable.AttemptsWhenCollected:Hide()

    local function setSummaryRowColor(row, r, g, b)
        row.Label:SetTextColor(r, g, b)
        row.Value:SetTextColor(r, g, b)
    end
    frame.SetFarmingSummary = function(self, stats)
        self.SummaryTable.Collected:Hide()
        self.SummaryTable.DateAcquired:Hide()
        self.SummaryTable.AttemptsWhenCollected:Hide()
        self.SummaryTable.TotalTries:Show()
        self.SummaryTable.Sources:Show()
        self.SummaryTable.Chance:Show()

        self.SummaryTable.TotalTries.Value:SetText(tostring(stats.totalAttempts))
        self.SummaryTable.Sources.Value:SetText(tostring(#stats.sourceRows))
        self.SummaryTable.Chance.Value:SetText(Util.FormatPercent(stats.pctChance, 2))
        setSummaryRowColor(self.SummaryTable.TotalTries, 0.9, 0.9, 0.9)
        setSummaryRowColor(self.SummaryTable.Sources, 0.9, 0.9, 0.9)
        setSummaryRowColor(self.SummaryTable.Chance, 0.9, 0.9, 0.9)
    end
    frame.SetCollectedSummary = function(self, stats)
        self.SummaryTable.TotalTries:Hide()
        self.SummaryTable.Sources:Hide()
        self.SummaryTable.Chance:Hide()
        self.SummaryTable.Collected:Show()
        self.SummaryTable.DateAcquired:Show()
        self.SummaryTable.AttemptsWhenCollected:Show()

        self.SummaryTable.Collected.Value:SetText("Collected")
        self.SummaryTable.DateAcquired.Value:SetText(Util.FormatObtainedAt(stats.obtainedAt))
        self.SummaryTable.AttemptsWhenCollected.Value:SetText(tostring(stats.totalAttempts))
        setSummaryRowColor(self.SummaryTable.Collected, 0.5, 0.9, 0.5)
        setSummaryRowColor(self.SummaryTable.DateAcquired, 0.5, 0.9, 0.5)
        setSummaryRowColor(self.SummaryTable.AttemptsWhenCollected, 0.5, 0.9, 0.5)
    end

    local sourcesHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourcesHeader:SetPoint("TOPLEFT", frame.SummaryBlock, "BOTTOMLEFT", 0, -12)
    sourcesHeader:SetText("Sources")

    local columnHeader = CreateFrame("Frame", nil, frame)
    columnHeader:SetHeight(HEADER_ROW_HEIGHT)
    columnHeader:SetPoint("TOPLEFT", sourcesHeader, "BOTTOMLEFT", 0, -4)
    columnHeader:SetPoint("RIGHT", frame, "RIGHT", -SCROLLBAR_INSET, 0)

    local sourceHeader = columnHeader:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sourceHeader:SetJustifyH("LEFT")
    sourceHeader:SetText("Source")

    local zoneHeader = columnHeader:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    zoneHeader:SetJustifyH("LEFT")
    zoneHeader:SetText("Zone")

    createColumnHeader(columnHeader, "Tries", COLUMN.TRIES_RIGHT)
    createColumnHeader(columnHeader, "Drop", COLUMN.DROP_RIGHT)
    createColumnHeader(columnHeader, "Chance", COLUMN.CHANCE_RIGHT)

    local scroll, content = Util.CreateModernScrollArea(frame)
    scroll:SetPoint("TOPLEFT", columnHeader, "BOTTOMLEFT", 0, -2)
    scroll:SetPoint("BOTTOMRIGHT", -SCROLLBAR_INSET, 0)

    frame.Scroll = scroll
    frame.Content = content
    frame._sourceRows = {}

    frame.Placeholder = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.Placeholder:SetPoint("CENTER", scroll, "CENTER")
    frame.Placeholder:SetText("Select an item to see drop sources.")
    frame.Placeholder:Show()

    function frame:SetItem(item)
        if not item then
            self.Icon:SetTexture(nil)
            self.Title:SetText("")
            self.SummaryTable:Hide()
            self.SummaryTable.TotalTries:Hide()
            self.SummaryTable.Sources:Hide()
            self.SummaryTable.Chance:Hide()
            self.SummaryTable.Collected:Hide()
            self.SummaryTable.DateAcquired:Hide()
            self.SummaryTable.AttemptsWhenCollected:Hide()
            self.Placeholder:Show()
            self.Scroll:Hide()
            columnHeader:Hide()
            for _, row in ipairs(self._sourceRows) do
                row:Hide()
            end
            return
        end

        self.Placeholder:Hide()
        self.Scroll:Show()
        columnHeader:Show()

        local stats = Util.GatherItemStats(item)
        local expanded = DropTracker.Storage.GetSetting("sourceDetailExpanded") == true

        self.Icon:SetTexture(stats.icon)
        self.Title:SetText(item.name or "?")

        if stats.obtained then
            self.SummaryTable:Show()
            self:SetCollectedSummary(stats)
        else
            self.SummaryTable:Show()
            self:SetFarmingSummary(stats)
        end

        local maxWidth = self.Scroll:GetWidth() or 240
        applySharedTextColumnLayout(sourceHeader, zoneHeader, columnHeader, computeSharedTextColumns(maxWidth))
        local y = 0
        local rowIndex = 0

        local sortedSources = {}
        for _, sourceRow in ipairs(stats.sourceRows) do
            sortedSources[#sortedSources + 1] = sourceRow
        end
        table.sort(sortedSources, function(a, b)
            local nameA = (a.sourceDef and a.sourceDef.label) or ""
            local nameB = (b.sourceDef and b.sourceDef.label) or ""
            return nameA:lower() < nameB:lower()
        end)

        for _, sourceRow in ipairs(sortedSources) do
            rowIndex = rowIndex + 1
            local row = self._sourceRows[rowIndex]
            if not row or not row.Zone then
                row = createTableRow(self.Content, maxWidth)
                self._sourceRows[rowIndex] = row
            end

            updateTableRow(row, sourceRow, expanded, item.expansion)
            row:SetWidth(maxWidth)
            applyTableRowLayout(row, maxWidth)
            row:SetPoint("TOPLEFT", 0, y)
            row:Show()

            y = y - row:GetHeight() - ROW_GAP
        end

        for i = rowIndex + 1, #self._sourceRows do
            self._sourceRows[i]:Hide()
        end

        self.Content:SetSize(maxWidth, math.max(1, -y))
    end

    return frame
end
