local ADDON_NAME, G = ...

local TAB_KEY = "settings"

local frame = CreateFrame("Frame", "GrimoireSettingsTab", G.panel)
frame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
frame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
frame:SetHeight(385)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 4, -2)
title:SetText(G.L("Einstellungen"))

local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
subtitle:SetText(G.L("Optionale Grimoire-Funktionen"))

local dungeonTeleportCheck = CreateFrame(
    "CheckButton",
    "GrimoireDungeonTeleportSetting",
    frame,
    "UICheckButtonTemplate"
)
dungeonTeleportCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -4, -16)
dungeonTeleportCheck:SetSize(24, 24)

local dungeonTeleportLabel = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)
dungeonTeleportLabel:SetPoint("LEFT", dungeonTeleportCheck, "RIGHT", 4, 0)
dungeonTeleportLabel:SetText(G.L("Dungeon-Teleports auf der Mythisch+-Übersicht"))

local dungeonTeleportHelp = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontDisableSmall"
)
dungeonTeleportHelp:SetPoint(
    "TOPLEFT",
    dungeonTeleportLabel,
    "BOTTOMLEFT",
    0,
    -6
)
dungeonTeleportHelp:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
dungeonTeleportHelp:SetJustifyH("LEFT")
dungeonTeleportHelp:SetWordWrap(true)
dungeonTeleportHelp:SetText(G.L(
    "Wenn aktiviert, teleportiert ein Klick auf einen Dungeon in der "
    .. "Mythisch+-Übersicht direkt zum Eingang – sofern der entsprechende "
    .. "Keystone-Hero-Teleport auf diesem Charakter erlernt ist."
))

local note = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
note:SetPoint("TOPLEFT", dungeonTeleportHelp, "BOTTOMLEFT", 0, -14)
note:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
note:SetJustifyH("LEFT")
note:SetWordWrap(true)
note:SetText(G.L(
    "Nicht erlernte Teleports werden nicht ausgelöst. "
    .. "Im Tooltip steht dann „Zauber nicht erlernt“."
))


-- ============================================================
-- Gruppensucher-Reminder
-- ============================================================

local groupReminderCheck = CreateFrame(
    "CheckButton",
    "GrimoireGroupFinderReminderSetting",
    frame,
    "UICheckButtonTemplate"
)
groupReminderCheck:SetPoint("TOPLEFT", note, "BOTTOMLEFT", -4, -18)
groupReminderCheck:SetSize(24, 24)

local groupReminderLabel = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)
groupReminderLabel:SetPoint("LEFT", groupReminderCheck, "RIGHT", 4, 0)
groupReminderLabel:SetText(G.L("Gruppensucher-Reminder"))

local groupReminderHelp = frame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontDisableSmall"
)
groupReminderHelp:SetPoint(
    "TOPLEFT",
    groupReminderLabel,
    "BOTTOMLEFT",
    0,
    -6
)
groupReminderHelp:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
groupReminderHelp:SetJustifyH("LEFT")
groupReminderHelp:SetWordWrap(true)
groupReminderHelp:SetText(G.L(
    "Zeigt nach dem Beitritt über den organisierten Gruppensucher ein "
    .. "kleines Reminder-Fenster mit Dungeon/Raid und Schwierigkeitsgrad. "
    .. "Das Fenster bleibt offen, bis du es selbst schließt."
))

-- ============================================================
-- Grimoire-Icon-Hervorhebung
-- ============================================================

local highlightButtonsCheck = CreateFrame(
    "CheckButton",
    "GrimoireHighlightButtonsSetting",
    frame,
    "UICheckButtonTemplate"
)
highlightButtonsCheck:SetPoint("TOPLEFT", groupReminderHelp, "BOTTOMLEFT", -4, -18)
highlightButtonsCheck:SetSize(24, 24)

local highlightButtonsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
highlightButtonsLabel:SetPoint("LEFT", highlightButtonsCheck, "RIGHT", 4, 0)
highlightButtonsLabel:SetText(G.L("Grimoire-Icons hervorheben"))

local highlightButtonsHelp = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
highlightButtonsHelp:SetPoint("TOPLEFT", highlightButtonsLabel, "BOTTOMLEFT", 0, -6)
highlightButtonsHelp:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
highlightButtonsHelp:SetJustifyH("LEFT")
highlightButtonsHelp:SetWordWrap(true)
highlightButtonsHelp:SetText(G.L(
    "Zeigt eine pulsierende Leuchtumrandung um die Grimoire-Buttons im Charakterfenster und Handelsfenster."
))

-- ============================================================
-- Minimap-Button
-- ============================================================

local minimapButtonCheck = CreateFrame(
    "CheckButton",
    "GrimoireMinimapButtonSetting",
    frame,
    "UICheckButtonTemplate"
)
minimapButtonCheck:SetPoint("TOPLEFT", highlightButtonsHelp, "BOTTOMLEFT", -4, -18)
minimapButtonCheck:SetSize(24, 24)

local minimapButtonLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
minimapButtonLabel:SetPoint("LEFT", minimapButtonCheck, "RIGHT", 4, 0)
minimapButtonLabel:SetText(G.L("Minimap-Button anzeigen"))

local minimapButtonHelp = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
minimapButtonHelp:SetPoint("TOPLEFT", minimapButtonLabel, "BOTTOMLEFT", 0, -6)
minimapButtonHelp:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
minimapButtonHelp:SetJustifyH("LEFT")
minimapButtonHelp:SetWordWrap(true)
minimapButtonHelp:SetText(G.L(
    "Zeigt einen klassischen Grimoire-Button an der Minimap. Ziehe ihn mit der linken Maustaste, um seine Position zu ändern."
))

-- ============================================================================
-- Quellenübersicht
-- ============================================================================

local sourceInfoButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
sourceInfoButton:SetSize(180, 24)
sourceInfoButton:SetPoint("TOPLEFT", minimapButtonHelp, "BOTTOMLEFT", 0, -14)
sourceInfoButton:SetText(G.L("Info & Quellen"))

local sourcePopup = CreateFrame("Frame", "GrimoireSourceInfoPopup", UIParent, "BackdropTemplate")
sourcePopup:SetSize(455, 300)
sourcePopup:SetPoint("CENTER")
sourcePopup:SetFrameStrata("DIALOG")
sourcePopup:SetFrameLevel(100)
sourcePopup:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
sourcePopup:SetBackdropColor(0.035, 0.035, 0.035, 0.98)
sourcePopup:SetBackdropBorderColor(0.42, 0.42, 0.42, 1)
sourcePopup:EnableMouse(true)
sourcePopup:Hide()

local popupTitle = sourcePopup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
popupTitle:SetPoint("TOPLEFT", 14, -12)
popupTitle:SetText(G.L("Grimoire – Quellen"))

local popupHint = sourcePopup:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
popupHint:SetPoint("TOPLEFT", popupTitle, "BOTTOMLEFT", 0, -5)
popupHint:SetText(G.L("Quelle anklicken → URL markieren → Strg+C im Browser einfügen"))

local popupClose = CreateFrame("Button", nil, sourcePopup, "UIPanelCloseButton")
popupClose:SetPoint("TOPRIGHT", 1, 1)
popupClose:SetScript("OnClick", function() sourcePopup:Hide() end)

local urlBox = CreateFrame("EditBox", nil, sourcePopup, "InputBoxTemplate")
urlBox:SetPoint("BOTTOMLEFT", sourcePopup, "BOTTOMLEFT", 14, 14)
urlBox:SetPoint("BOTTOMRIGHT", sourcePopup, "BOTTOMRIGHT", -14, 14)
urlBox:SetHeight(25)
urlBox:SetAutoFocus(false)
urlBox:SetFontObject("GameFontHighlight")
urlBox:SetJustifyH("LEFT")

local SOURCES = {
    { name = "Wowhead", url = "https://www.wowhead.com/", note = "Guides, kaufbare VZ-Items und Verbrauchsgüter" },
    { name = "Icy Veins", url = "https://www.icy-veins.com/wow/", note = "PvE-Guides und BiS-Listen" },
    { name = "Murlok", url = "https://murlok.io/", note = "Mythic+-BiS und M+-Werteziele" },
    { name = "KeystoneLoot", url = "https://keystoneloot.io/", note = "BiS, Gems, aktuelle Wertepriorität und Heldentalent-Empfehlungen" },
    { name = "Warcraft Logs", url = "https://www.warcraftlogs.com/", note = "Raid-Werteziele aus Ranking-Daten" },
    { name = "Blizzard", url = "https://develop.battle.net/", note = "Item-Tooltips und Spielinformationen" },
}

for index, source in ipairs(SOURCES) do
    local button = CreateFrame("Button", nil, sourcePopup, "UIPanelButtonTemplate")
    button:SetSize(112, 22)
    button:SetPoint("TOPLEFT", sourcePopup, "TOPLEFT", 14, -48 - ((index - 1) * 33))
    button:SetText(G.L(source.name))
    button:SetScript("OnClick", function()
        urlBox:SetText(G.L(source.url))
        urlBox:SetFocus()
        urlBox:HighlightText()
    end)

    local description = sourcePopup:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    description:SetPoint("LEFT", button, "RIGHT", 8, 0)
    description:SetPoint("RIGHT", sourcePopup, "RIGHT", -12, 0)
    description:SetJustifyH("LEFT")
    description:SetWordWrap(false)
    description:SetText(G.L(source.note))
end

sourceInfoButton:SetScript("OnClick", function()
    sourcePopup:Show()
    urlBox:SetText(G.L(SOURCES[1].url))
end)

local function IsEnabled()
    if not G.db then
        return true
    end

    if G.db.dungeonTeleportsEnabled == nil then
        G.db.dungeonTeleportsEnabled = true
    end

    return G.db.dungeonTeleportsEnabled == true
end


local function IsGroupReminderEnabled()
    if not G.db then
        return true
    end

    if G.db.groupFinderReminderEnabled == nil then
        G.db.groupFinderReminderEnabled = true
    end

    return G.db.groupFinderReminderEnabled == true
end

local function IsButtonHighlightEnabled()
    if not G.db then return true end
    if G.db.highlightToggleButtons == nil then
        G.db.highlightToggleButtons = true
    end
    return G.db.highlightToggleButtons == true
end

local function IsMinimapButtonEnabled()
    if not G.db then return true end
    if G.db.showMinimapButton == nil then
        G.db.showMinimapButton = true
    end
    return G.db.showMinimapButton == true
end

local function Refresh()
    dungeonTeleportCheck:SetChecked(IsEnabled())
    groupReminderCheck:SetChecked(IsGroupReminderEnabled())
    highlightButtonsCheck:SetChecked(IsButtonHighlightEnabled())
    minimapButtonCheck:SetChecked(IsMinimapButtonEnabled())
    if G.GetActiveTab and G.GetActiveTab() == TAB_KEY
        and G.SetPanelContentHeight
    then
        G.SetPanelContentHeight(385)
    end
end

dungeonTeleportCheck:SetScript("OnClick", function(self)
    if not G.db then return end

    G.db.dungeonTeleportsEnabled = self:GetChecked() == true

    if G.RefreshDungeonTeleportButtons then
        G.RefreshDungeonTeleportButtons()
    end
end)


groupReminderCheck:SetScript("OnClick", function(self)
    if not G.db then return end
    G.db.groupFinderReminderEnabled = self:GetChecked() == true

    if not G.db.groupFinderReminderEnabled
        and G.HideGroupFinderReminder
    then
        G.HideGroupFinderReminder()
    end
end)

minimapButtonCheck:SetScript("OnClick", function(self)
    if not G.db then return end
    G.db.showMinimapButton = self:GetChecked() == true
    if G.RefreshMinimapButton then
        G.RefreshMinimapButton()
    end
end)

highlightButtonsCheck:SetScript("OnClick", function(self)
    if not G.db then return end
    G.db.highlightToggleButtons = self:GetChecked() == true
    if G.RefreshToggleButtonHighlights then
        G.RefreshToggleButtonHighlights()
    end
end)

G.RegisterTabContent(TAB_KEY, frame)

if G.RegisterOnActiveTabChanged then
    G.RegisterOnActiveTabChanged(function(tabKey)
        if tabKey == TAB_KEY then
            Refresh()
        end
    end)
end

G.RegisterOnDatabaseReady(function()
    if G.db.dungeonTeleportsEnabled == nil then
        G.db.dungeonTeleportsEnabled = true
    end

    if G.db.groupFinderReminderEnabled == nil then
        G.db.groupFinderReminderEnabled = true
    end
    if G.db.highlightToggleButtons == nil then
        G.db.highlightToggleButtons = true
    end
    if G.db.showMinimapButton == nil then
        G.db.showMinimapButton = true
    end

    Refresh()
end)

Refresh()
