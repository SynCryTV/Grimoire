local ADDON_NAME, G = ...

local TAB_DEFS = {
    { key = "guide",        label = "Guide",       icon = "Interface\\Icons\\INV_Misc_Book_09" },
    { key = "bisGear",      label = "BiS-Gear",    icon = "Interface\\Icons\\INV_Chest_Plate04" },
    { key = "trinkets",     label = "Trinkets",    icon = "Interface\\Icons\\INV_Jewelry_Talisman_04" },
    { key = "enhancements", label = "Enhancements", icon = "Interface\\Icons\\Trade_Engraving" },
}

local TAB_WIDTH = 32
local TAB_HEIGHT = 32
local TAB_GAP = 4

local tabButtons = {}
local contentFrames = {}
local activeTabKey = TAB_DEFS[1].key

local function CreateTabButton(index, def)
    local btn = CreateFrame("Button", "GrimoireTab" .. def.key, G.panel, "BackdropTemplate")
    btn:SetSize(TAB_WIDTH, TAB_HEIGHT)
    btn:SetPoint("TOPLEFT", G.panel, "TOPRIGHT", 4, -20 - (index - 1) * (TAB_HEIGHT + TAB_GAP))
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 4, -4)
    icon:SetPoint("BOTTOMRIGHT", -4, 4)
    icon:SetTexture(def.icon)
    btn.icon = icon

    btn:SetScript("OnClick", function() G.SetActiveTab(def.key) end)
    btn:SetScript("OnEnter", function(self)
        self.icon:SetDesaturated(false)
        self.icon:SetVertexColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(def.label)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        if activeTabKey ~= def.key then
            self.icon:SetDesaturated(true)
            self.icon:SetVertexColor(0.7, 0.7, 0.7)
        end
        GameTooltip:Hide()
    end)

    return btn
end

local function RefreshTabHighlight()
    for key, btn in pairs(tabButtons) do
        if key == activeTabKey then
            btn:SetBackdropColor(0.25, 0.25, 0.25, 1)
            btn.icon:SetDesaturated(false)
            btn.icon:SetVertexColor(1, 1, 1)
        else
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            btn.icon:SetDesaturated(true)
            btn.icon:SetVertexColor(0.7, 0.7, 0.7)
        end
    end
end

-- Wird von den einzelnen Bereichs-Dateien (Phase 3) aufgerufen, um ihren
-- Inhaltsrahmen für einen Tab zu registrieren.
function G.RegisterTabContent(tabKey, frame)
    contentFrames[tabKey] = frame
    frame:Hide()
end

function G.SetActiveTab(tabKey)
    if not tabButtons[tabKey] then return end
    activeTabKey = tabKey
    for key, frame in pairs(contentFrames) do
        frame:SetShown(key == tabKey)
    end
    RefreshTabHighlight()
    if G.OnActiveTabChanged then
        G.OnActiveTabChanged(tabKey)
    end
end

function G.GetActiveTab()
    return activeTabKey
end

for index, def in ipairs(TAB_DEFS) do
    tabButtons[def.key] = CreateTabButton(index, def)
end
RefreshTabHighlight()
