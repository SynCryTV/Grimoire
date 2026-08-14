local ADDON_NAME, G = ...

local panel = CreateFrame("Frame", "GrimoirePanel", CharacterFrame, "BackdropTemplate")
panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
panel:SetHeight(500) -- Startwert, bevor der erste Tab-Inhalt sein Layout meldet (siehe G.SetPanelContentHeight)
panel:Hide()
G.panel = panel

-- Fixer "Chrome"-Anteil der Panel-Höhe, der nicht zum eigentlichen
-- Tab-Inhalt gehört: Padding oben (16) + Selector-Bar (28) + Abstand
-- zwischen Selector-Bar und Tab-Inhalt (20) + Padding unten (16).
-- Muss in Sync mit Selector.lua (selectorBar-Höhe/-Position) und den
-- jeweiligen Content-Tabs (Abstand zum Tab-Inhalt) gehalten werden.
local CONTENT_CHROME_HEIGHT = 16 + 28 + 20 + 16
local PANEL_HEIGHT_MIN = 300

-- Wird von den Tabs (aktuell Guide.lua) nach jedem Layout-Durchlauf mit der
-- tatsächlich benötigten Inhaltshöhe aufgerufen -- das Panel wächst/schrumpft
-- dann automatisch mit, statt den Inhalt auf eine feste Höhe zu quetschen
-- oder abzuschneiden. Nach unten hin durch PANEL_HEIGHT_MIN, nach oben hin
-- durch den verfügbaren Bildschirmplatz begrenzt (rein als Sicherheitsnetz
-- gegen ein Panel, das über den Bildschirmrand hinauswächst).
function G.SetPanelContentHeight(contentHeight)
    local total = CONTENT_CHROME_HEIGHT + (contentHeight or 0)
    total = math.max(total, PANEL_HEIGHT_MIN)
    local maxHeight = (UIParent and UIParent:GetHeight() or 1000) - 100
    total = math.min(total, maxHeight)

    if panel:IsShown() and G.SoftHeight then
        G.SoftHeight(panel, total, 0.22)
    else
        panel:SetHeight(total)
    end
end

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
    panel:SetAlpha(1)
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

    if G.SoftShow then
        G.SoftShow(panel, 0.20)
    else
        panel:Show()
    end
end

function G.ClosePanel()
    if G.SoftHide then
        G.SoftHide(panel, 0.16)
    else
        panel:Hide()
    end
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
