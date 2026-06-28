--[[ List filters: profession-style filter button + apply logic ]]

local Filters = {}
DropTracker.UI.Filters = Filters

local SETTING_HIDE_COLLECTED_MOUNTS = "hideCollectedMounts"
local SETTING_HIDE_FARMED = "hideFarmed"
local SETTING_HIDE_TOYS = "hideToys"
local SETTING_HIDE_MOUNTS = "hideMounts"

local nameSearchText = ""

function Filters.GetNameSearch()
    return nameSearchText
end

function Filters.SetNameSearch(text)
    nameSearchText = text or ""
end

function Filters.MatchesNameSearch(item)
    if nameSearchText == "" then
        return true
    end
    local name = (item.name or ""):lower()
    return name:find(nameSearchText:lower(), 1, true) ~= nil
end

function Filters.IsHideCollectedMountsEnabled()
    return DropTracker.Storage.GetSetting(SETTING_HIDE_COLLECTED_MOUNTS) == true
end

function Filters.IsHideFarmedEnabled()
    return DropTracker.Storage.GetSetting(SETTING_HIDE_FARMED) == true
end

function Filters.SetHideCollectedMounts(enabled)
    DropTracker.Storage.SetSetting(SETTING_HIDE_COLLECTED_MOUNTS, enabled == true)
end

function Filters.SetHideFarmed(enabled)
    DropTracker.Storage.SetSetting(SETTING_HIDE_FARMED, enabled == true)
end

function Filters.IsHideToysEnabled()
    return DropTracker.Storage.GetSetting(SETTING_HIDE_TOYS) == true
end

function Filters.IsHideMountsEnabled()
    return DropTracker.Storage.GetSetting(SETTING_HIDE_MOUNTS) == true
end

function Filters.SetHideToys(enabled)
    DropTracker.Storage.SetSetting(SETTING_HIDE_TOYS, enabled == true)
end

function Filters.SetHideMounts(enabled)
    DropTracker.Storage.SetSetting(SETTING_HIDE_MOUNTS, enabled == true)
end

function Filters.AreDefault()
    return not Filters.IsHideCollectedMountsEnabled()
        and not Filters.IsHideFarmedEnabled()
        and not Filters.IsHideToysEnabled()
        and not Filters.IsHideMountsEnabled()
end

function Filters.ResetToDefault(onChanged)
    Filters.SetHideCollectedMounts(false)
    Filters.SetHideFarmed(false)
    Filters.SetHideToys(false)
    Filters.SetHideMounts(false)
    if type(onChanged) == "function" then
        onChanged()
    end
end

function Filters.ShouldShowItem(item)
    if not item then
        return false
    end

    if not Filters.MatchesNameSearch(item) then
        return false
    end

    if Filters.IsHideToysEnabled() and item.collectionType == DropTracker.CollectionType.toy then
        return false
    end

    if Filters.IsHideMountsEnabled() and item.collectionType == DropTracker.CollectionType.mount then
        return false
    end

    if Filters.IsHideCollectedMountsEnabled()
        and item.collectionType == DropTracker.CollectionType.mount
    then
        local record = DropTracker.Storage.GetItemRecord(item.collectionType, item.collectionId)
        if record and record.obtained then
            return false
        end
    end

    if Filters.IsHideFarmedEnabled() then
        local summary = DropTracker.Eligibility.SummarizeItem(item.expansion, item)
        if summary and summary.allLocked then
            return false
        end
    end

    return true
end

function Filters.Apply(items)
    local filtered = {}
    for _, item in ipairs(items or {}) do
        if Filters.ShouldShowItem(item) then
            filtered[#filtered + 1] = item
        end
    end
    return filtered
end

local function toggleSetting(key, onChanged)
    local current = DropTracker.Storage.GetSetting(key) == true
    DropTracker.Storage.SetSetting(key, not current)
    if type(onChanged) == "function" then
        onChanged()
    end
end

local function setupFilterMenu(button, onChanged)
    if not button or type(button.SetupMenu) ~= "function" then
        return
    end

    button:SetupMenu(function(_, rootDescription)
        rootDescription:CreateCheckbox("Hide collected mounts", function()
            return Filters.IsHideCollectedMountsEnabled()
        end, function()
            toggleSetting(SETTING_HIDE_COLLECTED_MOUNTS, onChanged)
        end)

        rootDescription:CreateCheckbox("Hide farmed", function()
            return Filters.IsHideFarmedEnabled()
        end, function()
            toggleSetting(SETTING_HIDE_FARMED, onChanged)
        end)

        if rootDescription.CreateDivider then
            rootDescription:CreateDivider()
        end

        rootDescription:CreateCheckbox("Hide toys", function()
            return Filters.IsHideToysEnabled()
        end, function()
            toggleSetting(SETTING_HIDE_TOYS, onChanged)
        end)

        rootDescription:CreateCheckbox("Hide mounts", function()
            return Filters.IsHideMountsEnabled()
        end, function()
            toggleSetting(SETTING_HIDE_MOUNTS, onChanged)
        end)
    end)
end

local function ensureFilterDropdownTemplateLoaded()
    if WowStyle1FilterDropdownMixin then
        return true
    end
    if C_AddOns and C_AddOns.LoadAddOn then
        local ok = pcall(C_AddOns.LoadAddOn, "Blizzard_Menu")
        return ok and WowStyle1FilterDropdownMixin ~= nil
    end
    if LoadAddOn then
        local ok = pcall(LoadAddOn, "Blizzard_Menu")
        return ok and WowStyle1FilterDropdownMixin ~= nil
    end
    return false
end

function Filters.CreateFilterButton(parent, onChanged)
    if not parent or type(CreateFrame) ~= "function" then
        return nil
    end
    if not ensureFilterDropdownTemplateLoaded() then
        return nil
    end

    local ok, button = pcall(CreateFrame, "DropdownButton", nil, parent, "WowStyle1FilterDropdownTemplate")
    if not ok or not button then
        return nil
    end

    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -9)

    if button.SetDefaultCallback then
        button:SetDefaultCallback(function()
            Filters.ResetToDefault(onChanged)
        end)
    end
    if button.SetUpdateCallback then
        button:SetUpdateCallback(function()
            if type(onChanged) == "function" then
                onChanged()
            end
        end)
    end
    if button.SetIsDefaultCallback then
        button:SetIsDefaultCallback(function()
            return Filters.AreDefault()
        end)
    end

    setupFilterMenu(button, onChanged)
    return button
end

-- Backward-compatible alias for callers not yet updated.
Filters.CreateCogButton = Filters.CreateFilterButton
