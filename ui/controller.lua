--[[ Selection state and UI orchestration ]]

local Controller = {}
DropTracker.UI.Controller = Controller

local rootFrame = nil
local expansionList = nil
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
    end
end

local function onExpansionSelected(expansion)
    selectedExpansion = expansion
    local items = DropTracker.Catalog.GetItemsForExpansion(expansion)
    if not selectedItem or selectedItem.expansion ~= expansion then
        selectedItem = items[1]
    end
    persistSelection()
    Controller.Refresh()
end

local function onItemSelected(item)
    selectedItem = item
    persistSelection()
    Controller.Refresh()
end

function Controller.Refresh()
    if not rootFrame then
        return
    end

    local expansions = DropTracker.Catalog.GetExpansions()
    if expansionList then
        expansionList:Rebuild(expansions, selectedExpansion)
    end

    local items = DropTracker.Catalog.GetItemsForExpansion(selectedExpansion or "")
    if itemList then
        itemList:Rebuild(items, selectedItem, function(parent, item)
            local label = DropTracker.UI.ItemList.FormatRowLabel(item)
            return DropTracker.UI.ItemList.BuildSimpleRow(parent, item, label)
        end)
    end

    if detailPanel then
        detailPanel:SetItem(selectedItem)
    end
end

function Controller.OnTabShow(_mainFrame, contentHost)
    if not contentHost then
        return
    end

    if not rootFrame then
        rootFrame = CreateFrame("Frame", nil, contentHost)
        rootFrame:SetAllPoints(contentHost)

        expansionList = DropTracker.UI.ExpansionList.Create(rootFrame, onExpansionSelected)
        itemList = DropTracker.UI.ItemList.Create(rootFrame, onItemSelected)
        detailPanel = DropTracker.UI.DetailPanel.Create(rootFrame)
    end

    rootFrame:Show()
    restoreSelection()
    Controller.Refresh()
end

function Controller.OnTabHide(_mainFrame, contentHost)
    if rootFrame then
        rootFrame:Hide()
    end
end
