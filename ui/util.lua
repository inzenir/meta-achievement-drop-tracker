--[[ Shared UI helpers ]]

DropTracker.UI = DropTracker.UI or {}
local UIUtil = {}
DropTracker.UI.Util = UIUtil

-- Match main journal layout (main-frame.xml).
DropTracker.UI.Layout = {
    LIST_PANEL_WIDTH = 340,
    BREADCRUMB_HEIGHT = 34,
    BREADCRUMB_TOPLEFT_X = 54,
    BREADCRUMB_TOP_Y = -24,
    BREADCRUMB_TOPRIGHT_X = 0,
    SCROLLBAR_GAP = 6,
    SCROLLBAR_WIDTH = 12,
    SCROLLBAR_INSET = 28,
}

local HIGHLIGHT_TEXTURE = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local STOP_TEXTURE = "Interface\\Buttons\\UI-StopButton"

function UIUtil.EnsureSelectionHighlight(frame)
    if not frame._selectionHighlight then
        local tex = frame:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(HIGHLIGHT_TEXTURE)
        tex:SetBlendMode("ADD")
        tex:SetAllPoints(frame)
        tex:Hide()
        frame._selectionHighlight = tex
    end
    return frame._selectionHighlight
end

function UIUtil.SetSelected(frame, selected)
    local tex = UIUtil.EnsureSelectionHighlight(frame)
    if selected then
        tex:Show()
    else
        tex:Hide()
    end
end

function UIUtil.FormatPercent(value, decimals)
    decimals = decimals or 2
    local fmt = "%." .. tostring(decimals) .. "f%%"
    return string.format(fmt, value or 0)
end

function UIUtil.FormatChance(chance)
    local c = tonumber(chance) or 0
    return UIUtil.FormatPercent(c * 100, 2)
end

function UIUtil.FormatObtainedAt(obtainedAt)
    if obtainedAt == nil or obtainedAt == DropTracker.OBTAINED_AT_UNKNOWN then
        return "Unknown"
    end
    if type(obtainedAt) == "number" then
        return date("%Y-%m-%d", obtainedAt) or tostring(obtainedAt)
    end
    return tostring(obtainedAt)
end

local function humanizeMapKey(key)
    return key:gsub("_", " "):gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

local mapIdLabels

local function ensureMapIdLabels()
    if mapIdLabels then
        return mapIdLabels
    end
    mapIdLabels = {}
    for _, zones in pairs(DropTracker.Maps or {}) do
        for key, mapId in pairs(zones) do
            mapIdLabels[mapId] = humanizeMapKey(key)
        end
    end
    return mapIdLabels
end

function UIUtil.GetSourceZoneName(expansion, sourceDef)
    local locations = sourceDef and sourceDef.locations
    local loc = locations and locations[1]
    local mapId = loc and tonumber(loc.mapId)
    if not mapId then
        return ""
    end
    local label = ensureMapIdLabels()[mapId]
    if label and label ~= "" then
        return label
    end
    if C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapId)
        if info and info.name and info.name ~= "" then
            return info.name
        end
    end
    return ""
end

function UIUtil.GatherItemStats(item)
    if not item then
        return nil
    end

    local collectionType = item.collectionType
    local collectionId = item.collectionId
    local record = DropTracker.Storage.GetItemRecord(collectionType, collectionId)
    local sourceRows = {}

    for _, sourceDef in ipairs(item.sources or {}) do
        local sourceKey = DropTracker.SourceKey.FromSourceDef(sourceDef)
        local attempts = DropTracker.Storage.GetSourceAttempts(collectionType, collectionId, sourceKey)
        sourceRows[#sourceRows + 1] = {
            sourceDef = sourceDef,
            sourceKey = sourceKey,
            chance = sourceDef.chance,
            attempts = attempts,
        }
    end

    local obtained = record and record.obtained
    local totalAttempts = DropTracker.Probability.TotalAttempts(sourceRows)
    local pctChance = obtained and 100 or DropTracker.Probability.CombinedObtainedPercent(sourceRows)
    local lootSummary = DropTracker.Eligibility.SummarizeItem(item.expansion, item)

    return {
        sourceRows = sourceRows,
        totalAttempts = totalAttempts,
        pctChance = pctChance,
        obtained = obtained,
        obtainedAt = record and record.obtainedAt,
        icon = DropTracker.Collection.GetIcon(collectionType, collectionId, item.dropItemId),
        lootSummary = lootSummary,
    }
end

local function clampScrollOffset(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function attachBasicMouseWheelScroll(scroll)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        local current = self:GetVerticalScroll() or 0
        local step = (self.GetPanExtent and self:GetPanExtent()) or 30
        self:SetVerticalScroll(clampScrollOffset(current - (delta * step), 0, range))
    end)
end

function UIUtil.CreateModernScrollArea(parent)
    local layout = DropTracker.UI.Layout or {}
    local gap = layout.SCROLLBAR_GAP or 6
    local barWidth = layout.SCROLLBAR_WIDTH or 12

    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetClipsChildren(true)

    local scrollBar
    local ok, bar = pcall(CreateFrame, "EventFrame", nil, parent, "MinimalScrollBar")
    if ok and bar then
        scrollBar = bar
        scrollBar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", gap, 0)
        scrollBar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", gap, 0)
        if scrollBar.SetWidth then
            scrollBar:SetWidth(barWidth)
        end
    end

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)

    if scrollBar and ScrollUtil and type(ScrollUtil.InitScrollFrameWithScrollBar) == "function" then
        ScrollUtil.InitScrollFrameWithScrollBar(scroll, scrollBar)
    else
        attachBasicMouseWheelScroll(scroll)
    end

    return scroll, content, scrollBar
end

function UIUtil.TryCreateInset(parent, width)
    local ok, inset = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate3")
    if ok and inset then
        if width then
            inset:SetWidth(width)
        end
        return inset
    end

    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    if width then
        frame:SetWidth(width)
    end
    return frame
end

function UIUtil.StatusTexture(obtained)
    return obtained and CHECK_TEXTURE or STOP_TEXTURE
end

function UIUtil.StatusColor(obtained)
    if obtained then
        return 0.2, 0.9, 0.2
    end
    return 1, 0.2, 0.2
end
