--[[ Plugin-owned breadcrumb bar (NavBar look, not the journal breadcrumbs frame) ]]

local HOME_LABEL = "Drops"

local Breadcrumbs = {}
DropTracker.UI.Breadcrumbs = Breadcrumbs

local function sortExpansionItems(expansions)
    local sources = {}
    for _, expansion in ipairs(expansions or {}) do
        sources[#sources + 1] = {
            key = expansion,
            name = expansion,
            expansion = expansion,
        }
    end

    if JournalSourceExpansions and type(JournalSourceExpansions.SortSources) == "function" then
        return JournalSourceExpansions.SortSources(sources)
    end

    table.sort(sources, function(a, b)
        return (a.name or "") < (b.name or "")
    end)
    return sources
end

local function hookDropdownArrow(bar, nav, segmentButton)
    if not bar or not nav or not segmentButton then
        return false
    end

    local hooked = false
    for _, child in ipairs({ segmentButton:GetChildren() }) do
        local name = child:GetName() or ""
        if name:find("Dropdown") or name:find("MenuArrow") or (child:IsVisible() and child:GetWidth() and child:GetWidth() < 30) then
            child:SetScript("OnClick", function(_, mouseButton)
                if mouseButton == "LeftButton" then
                    Breadcrumbs.OpenExpansionMenu(bar, segmentButton)
                end
            end)
            hooked = true
        end
    end
    return hooked
end

local function ensureNavBar(bar)
    if bar._navInit then
        return bar._nav ~= nil or bar.home ~= nil
    end

    if not NavBar_Initialize or not NavBar_AddButton then
        return false
    end

    local nav = bar._nav or bar
    if nav ~= bar then
        nav:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        nav:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        bar._nav = nav
    end

    NavBar_Initialize(nav, "NavButtonTemplate", {
        name = HOME_LABEL,
        OnClick = function() end,
    }, nav.home, nav.overflow)

    if nav.homeButton then
        nav.homeButton:EnableMouse(false)
    end

    bar._nav = nav
    bar._navInit = true
    return true
end

function Breadcrumbs.OpenExpansionMenu(bar, ownerButton)
    if not MenuUtil or type(MenuUtil.CreateContextMenu) ~= "function" then
        return
    end

    if bar._dropdownMenu then
        bar._dropdownMenu:Close()
        bar._dropdownMenu = nil
    end

    bar._dropdownMenu = MenuUtil.CreateContextMenu(ownerButton, function(_, rootDescription)
        local items = bar._items or {}
        if #items == 0 then
            rootDescription:CreateTitle("No expansions registered")
            return
        end

        local function isSelected(key)
            return bar._selected == key
        end

        local function setSelected(key)
            bar._selected = key
            if bar._onSelect then
                bar._onSelect(key)
            end
            if bar._dropdownMenu then
                bar._dropdownMenu:Close()
                bar._dropdownMenu = nil
            end
        end

        for _, src in ipairs(items) do
            local key = src.key or src.name
            local label = src.name or key
            rootDescription:CreateRadio(label, isSelected, setSelected, key)
        end
    end)
end

function Breadcrumbs.Create(parent)
    local layout = DropTracker.UI.Layout or {}
    local height = layout.BREADCRUMB_HEIGHT or 34
    local topLeftX = layout.BREADCRUMB_TOPLEFT_X or 54
    local topY = layout.BREADCRUMB_TOP_Y or -24
    local topRightX = layout.BREADCRUMB_TOPRIGHT_X or 0

    local bar
    local ok, navBar = pcall(CreateFrame, "Frame", "DropTrackerBreadcrumbBar", parent, "NavBarTemplate")
    if ok and navBar then
        bar = navBar
    else
        bar = CreateFrame("Frame", "DropTrackerBreadcrumbBar", parent)
    end

    bar:SetHeight(height)
    bar:SetPoint("TOPLEFT", parent, "TOPLEFT", topLeftX, topY)
    bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", topRightX, topY)

    if ok and navBar then
        bar._nav = bar
    else
        bar._nav = nil
    end
    bar._navInit = false
    bar._dropdownMenu = nil
    bar._items = {}
    bar._selected = nil
    bar._onSelect = nil

    function bar:Update(selectedExpansion, onSelect)
        Breadcrumbs.Update(self, selectedExpansion, onSelect)
    end

    return bar
end

function Breadcrumbs.Update(bar, selectedExpansion, onSelect)
    if not bar then
        return
    end

    bar._items = sortExpansionItems(DropTracker.Catalog.GetExpansions())
    bar._selected = selectedExpansion
    bar._onSelect = onSelect

    local label = selectedExpansion
    if not label or label == "" then
        label = (bar._items[1] and bar._items[1].name) or "No expansions"
    end

    if not ensureNavBar(bar) then
        return
    end

    local nav = bar._nav
    if NavBar_Reset then
        NavBar_Reset(nav)
    end

    if nav.homeButton then
        nav.homeButton:SetText(HOME_LABEL)
        nav.homeButton.listFunc = nil
        nav.homeButton.myclick = nil
        nav.homeButton:EnableMouse(false)
        nav.homeButton:Show()
    end

    local segmentButton
    local function listFunc(button)
        if button ~= segmentButton then
            return {}
        end
        Breadcrumbs.OpenExpansionMenu(bar, button)
        return {}
    end

    local beforeCount = nav.navList and #nav.navList or 0
    NavBar_AddButton(nav, {
        name = label,
        listFunc = listFunc,
        OnClick = function() end,
    })

    if nav.navList and #nav.navList >= beforeCount + 1 then
        segmentButton = nav.navList[beforeCount + 1]
        segmentButton.listFunc = listFunc
        if segmentButton.data then
            segmentButton.data.listFunc = listFunc
        end
        if not hookDropdownArrow(bar, nav, segmentButton) then
            C_Timer.After(0, function()
                hookDropdownArrow(bar, nav, segmentButton)
            end)
        end
    end
end
