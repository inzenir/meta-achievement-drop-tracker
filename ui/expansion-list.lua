--[[ Left panel: expansion list (v1) ]]

local ExpansionList = {}
DropTracker.UI = DropTracker.UI or {}
DropTracker.UI.ExpansionList = ExpansionList

function ExpansionList.Create(parent, onSelect)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(140)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)

    frame._buttons = {}
    frame._onSelect = onSelect

    function frame:Rebuild(expansions, selectedExpansion)
        for _, btn in ipairs(self._buttons) do
            btn:Hide()
        end
        wipe(self._buttons)

        local y = -4
        for _, expansion in ipairs(expansions or {}) do
            local btn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
            btn:SetSize(128, 22)
            btn:SetPoint("TOPLEFT", 4, y)
            btn:SetText(expansion)
            btn.expansion = expansion
            btn:SetScript("OnClick", function()
                if self._onSelect then
                    self._onSelect(expansion)
                end
            end)
            if expansion == selectedExpansion then
                btn:LockHighlight()
            end
            table.insert(self._buttons, btn)
            y = y - 26
        end
    end

    return frame
end
