local ADDON_NAME, G = ...

local TAB_KEY = "settings"

local frame = CreateFrame("Frame", "GrimoireSettingsTab", G.panel)
frame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
frame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
frame:SetHeight(255)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 4, -2)
title:SetText("Einstellungen")

local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
subtitle:SetText("Optionale Grimoire-Funktionen")

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
dungeonTeleportLabel:SetText("Dungeon-Teleports auf der Mythisch+-Übersicht")

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
dungeonTeleportHelp:SetText(
    "Wenn aktiviert, teleportiert ein Klick auf einen Dungeon in der "
    .. "Mythisch+-Übersicht direkt zum Eingang – sofern der entsprechende "
    .. "Keystone-Hero-Teleport auf diesem Charakter erlernt ist."
)

local note = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
note:SetPoint("TOPLEFT", dungeonTeleportHelp, "BOTTOMLEFT", 0, -14)
note:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
note:SetJustifyH("LEFT")
note:SetWordWrap(true)
note:SetText(
    "Nicht erlernte Teleports werden nicht ausgelöst. "
    .. "Im Tooltip steht dann „Zauber nicht erlernt“."
)


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
groupReminderLabel:SetText("Gruppensucher-Reminder")

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
groupReminderHelp:SetText(
    "Zeigt nach dem Beitritt über den organisierten Gruppensucher ein "
    .. "kleines Reminder-Fenster mit Dungeon/Raid und Schwierigkeitsgrad. "
    .. "Das Fenster bleibt offen, bis du es selbst schließt."
)

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

local function Refresh()
    dungeonTeleportCheck:SetChecked(IsEnabled())
    groupReminderCheck:SetChecked(IsGroupReminderEnabled())

    if G.GetActiveTab and G.GetActiveTab() == TAB_KEY
        and G.SetPanelContentHeight
    then
        G.SetPanelContentHeight(255)
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

    Refresh()
end)

Refresh()
