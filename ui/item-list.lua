--[[ Center panel: item rows (icon, name, attempts, % ) ]]

local ItemList = {}
DropTracker.UI.ItemList = ItemList

local ROW_HEIGHT = 26
local GROUP_HEADER_HEIGHT = 22
local Util = DropTracker.UI.Util
local ListGroups = DropTracker.ListGroups

local SCROLLBAR_INSET = (DropTracker.UI.Layout and DropTracker.UI.Layout.SCROLLBAR_INSET) or 28
local STATUS_SIZE = 14
local STATUS_MARGIN = 6
local CHANCE_WIDTH = 52
local TRIES_WIDTH = 48
local COL_GAP = 4

local COLUMN = {
    STATUS_RIGHT = -STATUS_MARGIN,
    CHANCE_RIGHT = -(STATUS_MARGIN + STATUS_SIZE + COL_GAP),
    TRIES_RIGHT = -(STATUS_MARGIN + STATUS_SIZE + COL_GAP + CHANCE_WIDTH + COL_GAP),
    NAME_RIGHT = -(STATUS_MARGIN + STATUS_SIZE + COL_GAP + CHANCE_WIDTH + COL_GAP + TRIES_WIDTH + COL_GAP),
}

local COLUMN_HEADER_HEIGHT = 22

local function createColumnHeader(parent, text, rightOffset, width)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    label:SetPoint("RIGHT", parent, "RIGHT", rightOffset, 0)
    label:SetWidth(width)
    label:SetJustifyH("CENTER")
    label:SetText(text)
    return label
end

local function createNameSearchBox(parent, onChanged)
    local searchBox
    local ok = pcall(function()
        searchBox = CreateFrame("EditBox", nil, parent, "SearchBoxTemplate")
    end)
    if not ok or not searchBox then
        searchBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    end

    searchBox:SetHeight(COLUMN_HEADER_HEIGHT)
    searchBox:SetPoint("LEFT", parent, "LEFT", 0, 0)
    searchBox:SetPoint("RIGHT", parent, "RIGHT", COLUMN.NAME_RIGHT, 0)
    searchBox:SetAutoFocus(false)
    if searchBox.SetMaxLetters then
        searchBox:SetMaxLetters(40)
    end

    if DropTracker.UI.Filters and DropTracker.UI.Filters.GetNameSearch then
        local initial = DropTracker.UI.Filters.GetNameSearch()
        if initial ~= "" then
            searchBox:SetText(initial)
        end
    end

    searchBox:SetScript("OnTextChanged", function(self)
        if SearchBoxTemplate_OnTextChanged then
            SearchBoxTemplate_OnTextChanged(self)
        elseif InputBoxInstructions_OnTextChanged then
            InputBoxInstructions_OnTextChanged(self)
        end
        if DropTracker.UI.Filters and DropTracker.UI.Filters.SetNameSearch then
            DropTracker.UI.Filters.SetNameSearch(self:GetText())
        end
        if type(onChanged) == "function" then
            onChanged()
        end
    end)

    return searchBox
end

local function updateRow(row, item, selectedItem, stats)
    stats = stats or Util.GatherItemStats(item)
    if not stats then
        return
    end

    if row.Icon then
        row.Icon:SetTexture(stats.icon)
        row.Icon:Show()
    end

    if row.Name then
        row.Name:SetText(item.name or "?")
        DropTracker.Eligibility.ApplyItemNameColor(row.Name, stats.obtained, stats.lootSummary)
    end

    if row.Attempts then
        row.Attempts:SetText(tostring(stats.totalAttempts))
    end

    if row.Percent then
        if stats.obtained then
            row.Percent:SetText("")
        else
            row.Percent:SetText(Util.FormatPercent(stats.pctChance, 2))
            row.Percent:SetTextColor(0.8, 0.8, 0.8)
        end
    end

    if row.Status then
        row.Status:SetTexture(Util.StatusTexture(stats.obtained))
        local r, g, b = Util.StatusColor(stats.obtained)
        row.Status:SetVertexColor(r, g, b)
    end

    Util.SetSelected(row, selectedItem and selectedItem.collectionId == item.collectionId and selectedItem.collectionType == item.collectionType)
    row.Item = item
end

local function createRow(parent, width)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, ROW_HEIGHT)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", 6, 0)
    row.Icon = icon

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    name:SetPoint("RIGHT", row, "RIGHT", COLUMN.NAME_RIGHT, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    row.Name = name

    local attempts = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    attempts:SetPoint("RIGHT", row, "RIGHT", COLUMN.TRIES_RIGHT, 0)
    attempts:SetWidth(TRIES_WIDTH)
    attempts:SetJustifyH("CENTER")
    row.Attempts = attempts

    local percent = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    percent:SetPoint("RIGHT", row, "RIGHT", COLUMN.CHANCE_RIGHT, 0)
    percent:SetWidth(CHANCE_WIDTH)
    percent:SetJustifyH("CENTER")
    row.Percent = percent

    local status = row:CreateTexture(nil, "ARTWORK")
    status:SetSize(STATUS_SIZE, STATUS_SIZE)
    status:SetPoint("RIGHT", row, "RIGHT", COLUMN.STATUS_RIGHT, 0)
    row.Status = status

    return row
end

local function createGroupHeader(parent, width)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, GROUP_HEADER_HEIGHT)
    row.IsGroupHeader = true

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", 8, 0)
    label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    label:SetJustifyH("LEFT")
    label:SetTextColor(0.85, 0.73, 0.35)
    row.Label = label

    return row
end

local function updateGroupHeader(row, labelText)
    row.Label:SetText(labelText or "")
end

local function acquireHeaderRow(frame, headerIndex, maxWidth)
    frame._headerRows = frame._headerRows or {}
    local row = frame._headerRows[headerIndex]
    if not row then
        row = createGroupHeader(frame.Content, maxWidth)
        frame._headerRows[headerIndex] = row
    end
    row:SetSize(maxWidth, GROUP_HEADER_HEIGHT)
    return row
end

local function acquireItemRow(frame, itemIndex, maxWidth)
    local row = frame._rows[itemIndex]
    if not row or not row._columnLayout then
        row = createRow(frame.Content, maxWidth)
        row._columnLayout = true
        row:SetScript("OnClick", function(clicked)
            if frame._onSelect and clicked.Item then
                frame._onSelect(clicked.Item)
            end
        end)
        frame._rows[itemIndex] = row
    end
    row:SetSize(maxWidth, ROW_HEIGHT)
    return row
end

function ItemList.Create(parent, onSelect)
    local listWidth = DropTracker.UI.Layout and DropTracker.UI.Layout.LIST_PANEL_WIDTH or 340

    local inset = Util.TryCreateInset(parent)
    inset:SetWidth(listWidth)
    inset:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    inset:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    if inset.EnableMouse then
        inset:EnableMouse(false)
    end

    local header = inset:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 12, -10)
    header:SetPoint("RIGHT", inset, "RIGHT", -88, 0)
    header:SetJustifyH("LEFT")
    header:SetText("Mounts & toys")

    if DropTracker.UI.Filters and DropTracker.UI.Filters.CreateFilterButton then
        DropTracker.UI.Filters.CreateFilterButton(inset, function()
            if DropTracker.UI.Controller and DropTracker.UI.Controller.Refresh then
                DropTracker.UI.Controller.Refresh()
            end
        end)
    end

    local columnHeader = CreateFrame("Frame", nil, inset)
    columnHeader:SetHeight(COLUMN_HEADER_HEIGHT)
    columnHeader:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -9)
    columnHeader:SetPoint("RIGHT", inset, "RIGHT", -SCROLLBAR_INSET, 0)

    createNameSearchBox(columnHeader, function()
        if DropTracker.UI.Controller and DropTracker.UI.Controller.Refresh then
            DropTracker.UI.Controller.Refresh()
        end
    end)
    createColumnHeader(columnHeader, "Tries", COLUMN.TRIES_RIGHT, TRIES_WIDTH)
    createColumnHeader(columnHeader, "Chance", COLUMN.CHANCE_RIGHT, CHANCE_WIDTH)

    local scroll, content = Util.CreateModernScrollArea(inset)
    scroll:SetPoint("TOPLEFT", columnHeader, "BOTTOMLEFT", -4, -2)
    scroll:SetPoint("BOTTOMRIGHT", -SCROLLBAR_INSET, 8)

    local empty = inset:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    empty:SetPoint("CENTER")
    empty:SetText("No tracked drops for this expansion.")
    empty:Hide()

    local frame = CreateFrame("Frame", nil, inset)
    frame:SetAllPoints(inset)
    if frame.EnableMouse then
        frame:EnableMouse(false)
    end
    frame.Scroll = scroll
    frame.Content = content
    frame.Empty = empty
    frame._rows = {}
    frame._headerRows = {}
    frame._onSelect = onSelect

    function frame:Rebuild(items, selectedItem, emptyText)
        local sections = ListGroups and ListGroups.BuildSections(items) or {
            {
                label = nil,
                items = items or {},
            },
        }

        local itemCount = 0
        for _, section in ipairs(sections) do
            itemCount = itemCount + #section.items
        end

        local hasItems = itemCount > 0
        self.Empty:SetText(emptyText or "No tracked drops for this expansion.")
        self.Empty:SetShown(not hasItems)
        self.Scroll:SetShown(hasItems)

        for _, row in ipairs(self._rows) do
            row:Hide()
        end
        for _, row in ipairs(self._headerRows or {}) do
            row:Hide()
        end

        if not hasItems then
            return
        end

        local maxWidth = self.Scroll:GetWidth() or 200
        local y = 0
        local itemRowIndex = 0
        local headerRowIndex = 0
        local showSectionHeaders = #sections > 1

        for _, section in ipairs(sections) do
            if showSectionHeaders then
                headerRowIndex = headerRowIndex + 1
                local headerRow = acquireHeaderRow(self, headerRowIndex, maxWidth)
                updateGroupHeader(headerRow, section.label)
                headerRow:SetPoint("TOPLEFT", 0, y)
                headerRow:Show()
                y = y - GROUP_HEADER_HEIGHT
            end

            for _, item in ipairs(section.items) do
                itemRowIndex = itemRowIndex + 1
                local row = acquireItemRow(self, itemRowIndex, maxWidth)
                updateRow(row, item, selectedItem)
                row:SetPoint("TOPLEFT", 0, y)
                row:Show()
                y = y - ROW_HEIGHT
            end
        end

        for i = itemRowIndex + 1, #self._rows do
            self._rows[i]:Hide()
        end
        for i = headerRowIndex + 1, #(self._headerRows or {}) do
            self._headerRows[i]:Hide()
        end

        self.Content:SetSize(maxWidth, math.max(1, -y))
    end

    return frame
end

function ItemList.GatherItemStats(item)
    return Util.GatherItemStats(item)
end
