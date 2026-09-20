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

local function ApplyPanelWidth(animated)
    local width = (G.db and G.db.panelWidth) or G.PANEL_WIDTH_DEFAULT
    if type(width) ~= "number" or width < G.PANEL_WIDTH_MIN or width > G.PANEL_WIDTH_MAX then
        width = G.PANEL_WIDTH_DEFAULT
    end
    if animated and panel:IsShown() and G.SoftWidth then
        G.SoftWidth(panel, width, 0.24)
    else
        panel:SetWidth(width)
    end
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

local DEFAULT_TOGGLE_OFFSET_X = -12
local DEFAULT_TOGGLE_OFFSET_Y = -150

local toggleButton = CreateFrame("Button", "GrimoireToggleButton", UIParent)
toggleButton:SetSize(24, 24)
-- Außerhalb des Charakterfensters platzieren: Das Standard-UI verdeckt den
-- oberen rechten Innenbereich mit Portrait- und Schließen-Elementen.
toggleButton:SetFrameStrata("HIGH")
toggleButton:SetFrameLevel(CharacterFrame:GetFrameLevel() + 20)
toggleButton:SetNormalTexture("Interface\\AddOns\\Grimoire\\icon")
toggleButton:SetPushedTexture("Interface\\AddOns\\Grimoire\\icon")
toggleButton:SetHighlightTexture("Interface\\AddOns\\Grimoire\\icon", "ADD")

local function SetToggleButtonPosition(x, y)
    toggleButton:ClearAllPoints()
    toggleButton:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

local function SetToggleButtonDefaultPosition()
    toggleButton:ClearAllPoints()
    toggleButton:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", DEFAULT_TOGGLE_OFFSET_X, DEFAULT_TOGGLE_OFFSET_Y)
end

local function SaveToggleButtonPosition()
    local centerX, centerY = toggleButton:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not centerX or not centerY or not parentX or not parentY or not G.charDB then return end
    local scale = UIParent:GetEffectiveScale()
    if not scale or scale == 0 then scale = 1 end

    G.charDB.toggleButtonPosition = {
        x = math.floor(((centerX - parentX) / scale) + 0.5),
        y = math.floor(((centerY - parentY) / scale) + 0.5),
        version = 3,
    }

    SetToggleButtonPosition(G.charDB.toggleButtonPosition.x, G.charDB.toggleButtonPosition.y)
end

local function IsToggleButtonLocked()
    return not G.charDB or G.charDB.toggleButtonLocked ~= false
end

toggleButton:SetMovable(true)
toggleButton:SetClampedToScreen(true)
toggleButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
toggleButton:RegisterForDrag("LeftButton")
toggleButton:SetScript("OnDragStart", function(self)
    if IsToggleButtonLocked() then return end
    GameTooltip:Hide()
    self:StartMoving()
end)
toggleButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if not IsToggleButtonLocked() then
        SaveToggleButtonPosition()
    end
end)
toggleButton:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        if G.charDB then
            G.charDB.toggleButtonLocked = not IsToggleButtonLocked()
        end
        return
    end
    G.TogglePanel()
end)
toggleButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(G.L("Grimoire"))
    GameTooltip:AddLine(G.L("Klicken zum Öffnen/Schließen"), 0.8, 0.8, 0.8)
    if IsToggleButtonLocked() then
        GameTooltip:AddLine(G.L("Rechtsklick zum Lösen"), 0.8, 0.8, 0.8)
    else
        GameTooltip:AddLine(G.L("Gedrückt halten und ziehen zum Verschieben"), 0.8, 0.8, 0.8)
        GameTooltip:AddLine(G.L("Rechtsklick zum Feststellen"), 0.8, 0.8, 0.8)
    end
    GameTooltip:Show()
end)
toggleButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
G.toggleButton = toggleButton

toggleButton:Hide()
CharacterFrame:HookScript("OnShow", function()
    toggleButton:Show()
end)
CharacterFrame:HookScript("OnHide", function()
    toggleButton:Hide()
end)
if CharacterFrame:IsShown() then
    toggleButton:Show()
end

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

    if G.charDB.toggleButtonLocked == nil then
        G.charDB.toggleButtonLocked = true
    end

    local position = G.charDB and G.charDB.toggleButtonPosition
    if position and position.version == 3 and type(position.x) == "number" and type(position.y) == "number" then
        SetToggleButtonPosition(position.x, position.y)
    else
        -- Alte relative Positionen können durch Blizzard-Fensterlayout und
        -- UI-Skalierung wandern. Einmal auf die sichere Standardposition
        -- zurücksetzen; jede neu gezogene Position ist bildschirmfest.
        SetToggleButtonDefaultPosition()
    end
end)
