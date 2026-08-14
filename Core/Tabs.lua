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
    icon:SetAlpha(0.72)
    btn.icon = icon

    btn:SetScript("OnClick", function() G.SetActiveTab(def.key) end)
    btn:SetScript("OnEnter", function(self)
        self.icon:SetDesaturated(false)
        self.icon:SetVertexColor(1, 1, 1)
        if G.SoftIconHover then G.SoftIconHover(self.icon, true, 0.13) end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(def.label)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        if activeTabKey ~= def.key then
            self.icon:SetDesaturated(true)
            self.icon:SetVertexColor(0.7, 0.7, 0.7)
            if G.SoftIconHover then G.SoftIconHover(self.icon, false, 0.13) end
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
            btn.icon:SetAlpha(1)
        else
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            btn.icon:SetDesaturated(true)
            btn.icon:SetVertexColor(0.7, 0.7, 0.7)
            if not btn:IsMouseOver() then
                btn.icon:SetAlpha(0.72)
            end
        end
    end
end

-- Wird von den einzelnen Bereichs-Dateien (Phase 3) aufgerufen, um ihren
-- Inhaltsrahmen für einen Tab zu registrieren.
function G.RegisterTabContent(tabKey, frame)
    contentFrames[tabKey] = frame

    -- Wichtig beim Addon-Start:
    -- activeTabKey ist bereits auf den Standard-Tab ("guide") gesetzt.
    -- Dieser Inhalt darf deshalb beim Registrieren nicht versteckt bleiben,
    -- sonst erscheint er erst nach einem manuellen Tab-Wechsel.
    if tabKey == activeTabKey then
        frame:SetAlpha(1)
        frame:Show()
    else
        frame:Hide()
        frame:SetAlpha(1)
    end
end

-- Wird von den einzelnen Bereichs-Dateien aufgerufen, um bei jedem
-- Tab-Wechsel benachrichtigt zu werden (z.B. um die Panel-Höhe für den neu
-- aktivierten Tab neu anzufordern, siehe Content/Guide.lua und
-- Content/BisGear.lua -- deren G.SetPanelContentHeight()-Aufrufe sind
-- gegated auf "bin ich gerade der aktive Tab", laufen also während sie im
-- Hintergrund waren ins Leere und müssen beim Aktivwerden nachgeholt werden).
local activeTabChangedCallbacks = {}
function G.RegisterOnActiveTabChanged(callback)
    table.insert(activeTabChangedCallbacks, callback)
end

function G.SetActiveTab(tabKey)
    if not tabButtons[tabKey] then return end

    if activeTabKey == tabKey then
        local currentFrame = contentFrames[tabKey]
        if currentFrame and not currentFrame:IsShown() then
            currentFrame:SetAlpha(1)
            currentFrame:Show()
        end
        return
    end

    local oldKey = activeTabKey
    local oldFrame = contentFrames[oldKey]
    local newFrame = contentFrames[tabKey]

    activeTabKey = tabKey

    -- Alten Inhalt zuerst weich ausblenden.
    if oldFrame and oldFrame:IsShown() and G.SoftHide then
        G.SoftHide(oldFrame, 0.09)
    elseif oldFrame then
        oldFrame:Hide()
    end

    -- Der neue Inhalt wird bereits fürs Layout sichtbar gemacht,
    -- bleibt aber vollständig transparent, während das Panel seine
    -- neue Höhe anfährt. So steht niemals Text "im Leeren".
    if newFrame then
        newFrame:SetAlpha(0)
        newFrame:Show()
    end

    for key, frame in pairs(contentFrames) do
        if key ~= tabKey and frame ~= oldFrame then
            frame:Hide()
            frame:SetAlpha(1)
        end
    end

    RefreshTabHighlight()

    -- Die Content-Callbacks berechnen jetzt die neue Höhe und starten
    -- G.SoftHeight() am Panel.
    for _, callback in ipairs(activeTabChangedCallbacks) do
        callback(tabKey)
    end

    -- Erst NACH der Höhenanimation den neuen Inhalt einblenden.
    -- Die Panel-Höhe läuft aktuell 0.22 s; 0.23 s stellt sicher,
    -- dass der Rahmen zuerst vollständig an seinem Platz ist.
    if newFrame then
        if G.SoftAlpha then
            C_Timer.After(0.23, function()
                -- Nur einblenden, wenn inzwischen nicht schon wieder
                -- auf einen anderen Tab gewechselt wurde.
                if activeTabKey ~= tabKey then return end

                newFrame:SetAlpha(0)
                newFrame:Show()
                G.SoftAlpha(newFrame, 1, 0.15)
            end)
        else
            newFrame:SetAlpha(1)
            newFrame:Show()
        end
    end
end

function G.GetActiveTab()
    return activeTabKey
end

for index, def in ipairs(TAB_DEFS) do
    tabButtons[def.key] = CreateTabButton(index, def)
end
RefreshTabHighlight()
