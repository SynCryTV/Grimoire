local ADDON_NAME, G = ...

local panel = CreateFrame("Frame", "GrimoirePanel", CharacterFrame, "BackdropTemplate")
panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
panel:SetHeight(500) -- vorläufig fest, wird in Phase 3 dynamisch an den Tab-Inhalt angepasst
panel:Hide()
G.panel = panel

local function ApplyPanelWidth()
    local width = (G.db and G.db.panelWidth) or G.PANEL_WIDTH_DEFAULT
    if type(width) ~= "number" or width < G.PANEL_WIDTH_MIN or width > G.PANEL_WIDTH_MAX then
        width = G.PANEL_WIDTH_DEFAULT
    end
    panel:SetWidth(width)
end
G.ApplyPanelWidth = ApplyPanelWidth

local function PositionPanel()
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", 2, 0)
end
G.PositionPanel = PositionPanel

-- Panel öffnet sich NICHT automatisch mit dem Charakterfenster -- dafür gibt
-- es einen kleinen Umschalt-Knopf direkt am Charakterfenster (wirkt weniger
-- überladen als ein sofortiges Auto-Öffnen). Schließt sich aber weiterhin
-- automatisch mit, wenn das Charakterfenster zugeht.
CharacterFrame:HookScript("OnHide", function()
    panel:Hide()
end)

local toggleButton = CreateFrame("Button", "GrimoireToggleButton", CharacterFrame, "UIPanelButtonTemplate")
toggleButton:SetSize(24, 24)
toggleButton:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -32, -6)
toggleButton:SetText("G")
toggleButton:SetScript("OnClick", function() G.TogglePanel() end)
toggleButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Grimoire")
    GameTooltip:AddLine("Klicken zum Öffnen/Schließen", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)
toggleButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
G.toggleButton = toggleButton

function G.OpenPanel()
    if not CharacterFrame:IsShown() then
        ToggleCharacter("PaperDollFrame")
    end
    PositionPanel()
    panel:Show()
end

function G.ClosePanel()
    panel:Hide()
end

function G.TogglePanel()
    if panel:IsShown() then
        G.ClosePanel()
    else
        G.OpenPanel()
    end
end

-- Meldet sich bei Init.lua an, sobald die SavedVariables geladen sind.
G.RegisterOnDatabaseReady(function()
    ApplyPanelWidth()
end)
