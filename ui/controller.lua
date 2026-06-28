--[[ Selection state and UI orchestration ]]

local Controller = {}
DropTracker.UI.Controller = Controller

local mainFrameRef = nil
local rootFrame = nil
local breadcrumbBar = nil
local itemList = nil
local detailPanel = nil

local selectedExpansion = nil
local selectedItem = nil

local function persistSelection()
    if selectedExpansion then
        DropTracker.Storage.SetSetting("lastExpansion", selectedExpansion)
    end
    if selectedItem then
        DropTracker.Storage.SetSetting("lastCollectionType", selectedItem.collectionType)
        DropTracker.Storage.SetSetting("lastCollectionId", selectedItem.collectionId)
    end
end

local function itemInExpansion(item, expansion)
    return item and expansion and item.expansion == expansion
end

local function getExpansionItems()
    return DropTracker.Catalog.GetItemsForExpansion(selectedExpansion or "")
end

local function getFilteredItems()
    local items = getExpansionItems()
    if DropTracker.UI.Filters and DropTracker.UI.Filters.Apply then
        return DropTracker.UI.Filters.Apply(items), items
    end
    return items, items
end

local function ensureSelectedItemVisible(filteredItems)
    if not selectedItem then
        selectedItem = filteredItems[1]
        return
    end
    for _, item in ipairs(filteredItems) do
        if item.collectionId == selectedItem.collectionId and item.collectionType == selectedItem.collectionType then
            return
        end
    end
    selectedItem = filteredItems[1]
end

local function restoreSelection()
    selectedExpansion = DropTracker.Storage.GetSetting("lastExpansion")
    local expansions = DropTracker.Catalog.GetExpansions()
    if not selectedExpansion or not tContains(expansions, selectedExpansion) then
        selectedExpansion = expansions[1]
    end

    selectedItem = nil
    local lastType = DropTracker.Storage.GetSetting("lastCollectionType")
    local lastId = DropTracker.Storage.GetSetting("lastCollectionId")
    if lastType and lastId ~= nil then
        selectedItem = DropTracker.Catalog.GetItem(lastType, lastId)
        if not itemInExpansion(selectedItem, selectedExpansion) then
            selectedItem = nil
        end
    end

    local filteredItems, allItems = getFilteredItems()
    if not selectedItem and filteredItems[1] then
        selectedItem = filteredItems[1]
    elseif selectedItem then
        ensureSelectedItemVisible(filteredItems)
    end
end

local function onExpansionSelected(expansion)
    if selectedExpansion ~= expansion then
        selectedExpansion = expansion
        local filteredItems = getFilteredItems()
        selectedItem = filteredItems[1]
    end
    persistSelection()
    Controller.Refresh()
end

local function onItemSelected(item)
    selectedItem = item
    persistSelection()
    Controller.Refresh()
end

local function destroyUi()
    if breadcrumbBar then
        breadcrumbBar:Hide()
        breadcrumbBar:SetParent(nil)
    end
    if rootFrame then
        rootFrame:Hide()
        rootFrame:SetParent(nil)
    end
    rootFrame = nil
    breadcrumbBar = nil
    itemList = nil
    detailPanel = nil
end

local function ensureUi(mainFrame, contentHost)
    if mainFrame then
        mainFrameRef = mainFrame
    end
    if rootFrame and breadcrumbBar and itemList and detailPanel then
        return
    end

    destroyUi()

    if mainFrameRef and DropTracker.UI.Breadcrumbs then
        breadcrumbBar = DropTracker.UI.Breadcrumbs.Create(mainFrameRef)
    end

    rootFrame = CreateFrame("Frame", nil, contentHost)
    rootFrame:SetAllPoints(contentHost)

    itemList = DropTracker.UI.ItemList.Create(rootFrame, onItemSelected)
    detailPanel = DropTracker.UI.DetailPanel.Create(rootFrame)
end

function Controller.RefreshBreadcrumbs()
    if breadcrumbBar then
        breadcrumbBar:Update(selectedExpansion, onExpansionSelected)
    end
end

function Controller.Refresh()
    if not rootFrame then
        return
    end

    Controller.RefreshBreadcrumbs()

    local filteredItems, allItems = getFilteredItems()
    ensureSelectedItemVisible(filteredItems)

    local emptyText = (#allItems > 0 and #filteredItems == 0) and "No items match the current filters." or nil
    if itemList then
        itemList:Rebuild(filteredItems, selectedItem, emptyText)
    end

    if detailPanel then
        detailPanel:SetItem(selectedItem)
    end
end

function Controller.OnTabShow(mainFrame, contentHost)
    if not contentHost then
        return
    end

    ensureUi(mainFrame, contentHost)
    if breadcrumbBar then
        if mainFrameRef then
            breadcrumbBar:SetFrameStrata(mainFrameRef:GetFrameStrata())
            breadcrumbBar:SetFrameLevel(mainFrameRef:GetFrameLevel() + 20)
        end
        breadcrumbBar:Show()
        if breadcrumbBar._nav then
            breadcrumbBar._nav:Show()
        end
    end
    rootFrame:Show()
    restoreSelection()
    Controller.Refresh()
end

function Controller.OnTabHide()
    if breadcrumbBar then
        breadcrumbBar:Hide()
    end
    if rootFrame then
        rootFrame:Hide()
    end
end
