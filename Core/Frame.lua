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

local toggleButton = CreateFrame("Button", "GrimoireToggleButton", CharacterFrame)
toggleButton:SetSize(24, 24)
-- Außerhalb des Charakterfensters platzieren: Das Standard-UI verdeckt den
-- oberen rechten Innenbereich mit Portrait- und Schließen-Elementen.
toggleButton:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -32, -6)
toggleButton:SetFrameStrata("HIGH")
toggleButton:SetFrameLevel(CharacterFrame:GetFrameLevel() + 100)
toggleButton:SetToplevel(true)
toggleButton:SetNormalTexture("Interface\\AddOns\\Grimoire\\icon")
toggleButton:SetPushedTexture("Interface\\AddOns\\Grimoire\\icon")
toggleButton:SetHighlightTexture("Interface\\AddOns\\Grimoire\\icon", "ADD")
toggleButton:EnableMouse(false)

local toggleGlow = toggleButton:CreateTexture(nil, "OVERLAY", nil, 7)
toggleGlow:SetSize(44, 44)
toggleGlow:SetPoint("CENTER")
toggleGlow:SetAtlas("bags-glow-flash")
toggleGlow:SetVertexColor(0.15, 0.82, 1.0, 1.0)
toggleGlow:SetBlendMode("ADD")

local toggleSparkle = toggleButton:CreateTexture(nil, "OVERLAY", nil, 6)
toggleSparkle:SetSize(34, 34)
toggleSparkle:SetPoint("CENTER")
toggleSparkle:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
toggleSparkle:SetVertexColor(1.0, 0.68, 0.12, 0.9)
toggleSparkle:SetBlendMode("ADD")

local toggleGlowPulse = toggleGlow:CreateAnimationGroup()
toggleGlowPulse:SetLooping("REPEAT")
local toggleGlowFadeIn = toggleGlowPulse:CreateAnimation("Alpha")
toggleGlowFadeIn:SetFromAlpha(0.28)
toggleGlowFadeIn:SetToAlpha(0.85)
toggleGlowFadeIn:SetDuration(1.1)
toggleGlowFadeIn:SetSmoothing("IN_OUT")
local toggleGlowFadeOut = toggleGlowPulse:CreateAnimation("Alpha")
toggleGlowFadeOut:SetFromAlpha(0.85)
toggleGlowFadeOut:SetToAlpha(0.18)
toggleGlowFadeOut:SetDuration(1.3)
toggleGlowFadeOut:SetSmoothing("IN_OUT")
toggleGlowPulse:Play()

local toggleSparklePulse = toggleSparkle:CreateAnimationGroup()
toggleSparklePulse:SetLooping("REPEAT")
local toggleSparkleFadeIn = toggleSparklePulse:CreateAnimation("Alpha")
toggleSparkleFadeIn:SetFromAlpha(0.12)
toggleSparkleFadeIn:SetToAlpha(0.9)
toggleSparkleFadeIn:SetDuration(0.42)
toggleSparkleFadeIn:SetSmoothing("OUT")
local toggleSparkleFadeOut = toggleSparklePulse:CreateAnimation("Alpha")
toggleSparkleFadeOut:SetFromAlpha(0.9)
toggleSparkleFadeOut:SetToAlpha(0.12)
toggleSparkleFadeOut:SetDuration(1.65)
toggleSparkleFadeOut:SetSmoothing("IN")
toggleSparklePulse:Play()

local function IsToggleHighlightEnabled()
    return not G.db or G.db.highlightToggleButtons ~= false
end

function G.RefreshToggleButtonHighlights()
    if toggleGlow then
        toggleGlow:SetShown(IsToggleHighlightEnabled())
    end
    if toggleSparkle then
        toggleSparkle:SetShown(IsToggleHighlightEnabled())
    end
    if G.RefreshAuctionHouseToggleHighlight then
        G.RefreshAuctionHouseToggleHighlight()
    end
end

local function ShowToggleTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(G.L("Grimoire"))
    GameTooltip:AddLine(G.L("Klicken zum Öffnen/Schließen"), 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

-- Der Blizzard-Header kann die Mausinteraktion eines kleinen Kind-Buttons
-- teilweise abfangen. Eine transparente Klickfläche über dem Icon liefert
-- eine durchgehend zuverlässige 44x44-Fläche, ohne das Symbol zu strecken.
local toggleHitArea = CreateFrame("Button", "GrimoireToggleHitArea", UIParent)
toggleHitArea:SetSize(44, 44)
toggleHitArea:SetPoint("CENTER", toggleButton, "CENTER")
toggleHitArea:SetFrameStrata("TOOLTIP")
toggleHitArea:SetFrameLevel(100)
toggleHitArea:SetToplevel(true)
toggleHitArea:RegisterForClicks("LeftButtonUp")
toggleHitArea:SetScript("OnClick", function() G.TogglePanel() end)
toggleHitArea:SetScript("OnEnter", ShowToggleTooltip)
toggleHitArea:SetScript("OnLeave", GameTooltip_Hide)
toggleHitArea:Hide()

CharacterFrame:HookScript("OnShow", function()
    toggleHitArea:Show()
end)
CharacterFrame:HookScript("OnHide", function()
    toggleHitArea:Hide()
end)
if CharacterFrame:IsShown() then
    toggleHitArea:Show()
end
G.toggleButton = toggleButton

function G.OpenPanel()
    if not CharacterFrame:IsShown() then
        ToggleCharacter("PaperDollFrame")
    end

    -- Mehrere gleichzeitig laufende WoW-Clients teilen sich beim Beenden
    -- dieselben accountweiten SavedVariables. Die Auswahl darf deshalb beim
    -- Öffnen nie von einer zuvor betrachteten Klasse stammen: immer die
    -- tatsächliche Klasse/Spec dieses Clients verwenden. Der ausgelöste
    -- Selection-Refresh setzt auch die aktive Hero-Spezialisierung neu.
    if G.ResetSelectionToOwnSpec then
        G.ResetSelectionToOwnSpec()
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
    G.RefreshToggleButtonHighlights()
end)
