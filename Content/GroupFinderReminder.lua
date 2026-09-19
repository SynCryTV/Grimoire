local ADDON_NAME, G = ...

-- ============================================================================
-- Grimoire Gruppensucher-Reminder
--
-- Zeigt nach dem tatsächlichen Beitritt zu einer Gruppe aus dem organisierten
-- Gruppensucher an, welche Aktivität angenommen wurde.
--
-- Wir cachen die Activity-Daten bereits während der Bewerbung/Einladung,
-- weil Blizzard Suchergebnisse nach dem Gruppenbeitritt aus der Ergebnisliste
-- entfernen kann.
-- ============================================================================

local controller = CreateFrame("Frame")
local resultCache = {}

local function IsEnabled()
    if not G.db then
        return true
    end

    if G.db.groupFinderReminderEnabled == nil then
        G.db.groupFinderReminderEnabled = true
    end

    return G.db.groupFinderReminderEnabled == true
end

local function GetDifficultyLabel(activityInfo)
    if not activityInfo then
        return "Unbekannt"
    end

    if activityInfo.isMythicPlusActivity then
        return "Mythisch+"
    elseif activityInfo.isMythicActivity then
        return "Mythisch"
    elseif activityInfo.isHeroicActivity then
        return "Heroisch"
    elseif activityInfo.isNormalActivity then
        return "Normal"
    end

    -- Fallback über Blizzards Difficulty-ID.
    local difficultyID =
        activityInfo.redirectedDifficultyID
        and activityInfo.redirectedDifficultyID > 0
        and activityInfo.redirectedDifficultyID
        or activityInfo.difficultyID

    if difficultyID and GetDifficultyInfo then
        local name = GetDifficultyInfo(difficultyID)
        if name and name ~= "" then
            return name
        end
    end

    return "Unbekannt"
end

local function GetActivityTypeLabel(activityInfo)
    if not activityInfo then return "Aktivität" end

    if activityInfo.isCurrentRaidActivity
        or (activityInfo.maxNumPlayers and activityInfo.maxNumPlayers > 5)
    then
        return "Raid"
    end

    if activityInfo.isMythicPlusActivity
        or activityInfo.isMythicActivity
        or activityInfo.isHeroicActivity
        or activityInfo.isNormalActivity
    then
        return "Dungeon"
    end

    return "Aktivität"
end

local function ReadResultData(searchResultID, groupName)
    if not searchResultID
        or not C_LFGList
        or not C_LFGList.GetSearchResultInfo
    then
        return nil
    end

    local ok, searchData = pcall(
        C_LFGList.GetSearchResultInfo,
        searchResultID
    )

    if not ok or not searchData then
        return nil
    end

    local activityID =
        searchData.activityIDs
        and searchData.activityIDs[1]

    if not activityID then
        return nil
    end

    local activityInfo
    if C_LFGList.GetActivityInfoTable then
        local activityOK, result = pcall(
            C_LFGList.GetActivityInfoTable,
            activityID
        )
        if activityOK then
            activityInfo = result
        end
    end

    if not activityInfo then
        return nil
    end

    return {
        searchResultID = searchResultID,
        groupName = groupName or searchData.name,
        activityID = activityID,
        activityName =
            activityInfo.fullName
            or activityInfo.shortName
            or "Unbekannte Aktivität",
        activityType = GetActivityTypeLabel(activityInfo),
        difficulty = GetDifficultyLabel(activityInfo),
    }
end

local function CacheResult(searchResultID, groupName)
    local data = ReadResultData(searchResultID, groupName)
    if data then
        resultCache[searchResultID] = data
    end
end

-- ============================================================================
-- Reminder-Fenster
-- ============================================================================

local popup = CreateFrame(
    "Frame",
    "GrimoireGroupFinderReminder",
    UIParent,
    "BackdropTemplate"
)
popup:SetSize(390, 170)
popup:SetPoint("CENTER", UIParent, "CENTER", 0, 170)
popup:SetFrameStrata("DIALOG")
popup:SetFrameLevel(700)
popup:SetClampedToScreen(true)
popup:SetMovable(true)
popup:EnableMouse(true)
popup:RegisterForDrag("LeftButton")
popup:SetScript("OnDragStart", popup.StartMoving)
popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

popup:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
popup:SetBackdropColor(0.035, 0.035, 0.035, 0.97)
popup:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
popup:Hide()

local closeButton = CreateFrame(
    "Button",
    nil,
    popup,
    "UIPanelCloseButton"
)
closeButton:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 1, 1)

local icon = popup:CreateTexture(nil, "ARTWORK")
icon:SetSize(38, 38)
icon:SetPoint("TOPLEFT", popup, "TOPLEFT", 15, -18)
icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")

local title = popup:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)
title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
title:SetPoint("RIGHT", popup, "RIGHT", -38, 0)
title:SetJustifyH("LEFT")
title:SetText(G.L("Gruppensucher-Reminder"))

local activityText = popup:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)
activityText:SetPoint("TOPLEFT", popup, "TOPLEFT", 16, -72)
activityText:SetPoint("RIGHT", popup, "RIGHT", -16, 0)
activityText:SetJustifyH("LEFT")
activityText:SetWordWrap(true)

local difficultyText = popup:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
difficultyText:SetPoint(
    "TOPLEFT",
    activityText,
    "BOTTOMLEFT",
    0,
    -10
)
difficultyText:SetPoint("RIGHT", popup, "RIGHT", -16, 0)
difficultyText:SetJustifyH("LEFT")

local groupText = popup:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontDisableSmall"
)
groupText:SetPoint(
    "TOPLEFT",
    difficultyText,
    "BOTTOMLEFT",
    0,
    -8
)
groupText:SetPoint("RIGHT", popup, "RIGHT", -16, 0)
groupText:SetJustifyH("LEFT")
groupText:SetWordWrap(false)

local teleportButton = CreateFrame(
    "Button",
    nil,
    popup,
    "InsecureActionButtonTemplate, UIPanelButtonTemplate"
)
teleportButton:SetSize(180, 24)
teleportButton:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 16, 12)
teleportButton:SetText(G.L("Zum Dungeon teleportieren"))
teleportButton:RegisterForClicks("AnyUp")
teleportButton:Hide()

teleportButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    if not self.spellKnown then
        GameTooltip:SetText(G.L(SPELL_FAILED_NOT_KNOWN or "Zauber nicht erlernt"), 1.0, 0.25, 0.25)
    else
        GameTooltip:SetText(G.L("Dungeon-Teleport"), 1.0, 0.82, 0.0)
        GameTooltip:AddLine(G.L("Klicken, um zum Dungeon-Eingang zu teleportieren."), 0.9, 0.9, 0.9, true)
    end
    GameTooltip:Show()
end)
teleportButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
teleportButton:SetScript("PostClick", function(self)
    if self.spellID and not self.spellKnown and UIErrorsFrame and UIErrorsFrame.AddMessage then
        UIErrorsFrame:AddMessage(SPELL_FAILED_NOT_KNOWN or "Zauber nicht erlernt", 1.0, 0.20, 0.20, 1.0)
    end
end)

local okButton = CreateFrame(
    "Button",
    nil,
    popup,
    "UIPanelButtonTemplate"
)
okButton:SetSize(100, 24)
okButton:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -16, 12)
okButton:SetText(G.L("Alles klar"))
okButton:SetScript("OnClick", function()
    popup:Hide()
end)

G.HideGroupFinderReminder = function()
    popup:Hide()
end

local function ShowReminder(data)
    if not IsEnabled() or not data then
        return
    end

    activityText:SetText(G.L(
        string.format(
            "%s: |cffffffff%s|r",
            data.activityType or "Aktivität",
            data.activityName or "Unbekannt"
        )
    ))

    difficultyText:SetText(G.L(
        "Schwierigkeitsgrad: |cffffd200"
        .. (data.difficulty or "Unbekannt")
        .. "|r"
    ))

    if data.groupName and data.groupName ~= "" then
        groupText:SetText(G.L("Gruppe: " .. data.groupName))
        groupText:Show()
    else
        groupText:Hide()
    end

    local spellID = G.GetDungeonTeleportSpell and G.GetDungeonTeleportSpell(data.activityName)
    local featureEnabled = not G.IsDungeonTeleportsEnabled or G.IsDungeonTeleportsEnabled()
    if spellID and featureEnabled and not InCombatLockdown() then
        local known = G.IsDungeonTeleportKnown and G.IsDungeonTeleportKnown(spellID)
        teleportButton.spellID = spellID
        teleportButton.spellKnown = known == true
        -- Nicht wirklich deaktivieren: So bleibt der Hover-Hinweis auch für
        -- noch nicht erlernte Keystone-Hero-Teleports erreichbar.
        teleportButton:SetAlpha(teleportButton.spellKnown and 1 or 0.45)
        if not InCombatLockdown() then
            teleportButton:SetAttribute("type", teleportButton.spellKnown and "spell" or nil)
            teleportButton:SetAttribute("spell", teleportButton.spellKnown and spellID or nil)
        end
        teleportButton:Show()
        okButton:ClearAllPoints()
        okButton:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -16, 12)
    else
        teleportButton:Hide()
        okButton:ClearAllPoints()
        okButton:SetPoint("BOTTOM", popup, "BOTTOM", 0, 12)
    end

    -- Das Popup lässt sich schnell wegklicken. Die Annahme bleibt deshalb
    -- zusätzlich dauerhaft im Chatfenster nachvollziehbar.
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffc792ea[Grimoire]|r Gruppensucher: |cffffffff"
            .. (data.activityName or "Unbekannt")
            .. "|r |cffaaaaaa("
            .. (data.difficulty or "Unbekannt")
            .. ")|r"
        )
    end

    popup:Show()
end

-- ============================================================================
-- Gruppensucher-Events
-- ============================================================================

controller:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
controller:RegisterEvent("LFG_LIST_JOINED_GROUP")

controller:SetScript("OnEvent", function(_, event, ...)
    if event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        local searchResultID, newStatus, oldStatus, groupName = ...

        -- Bei jeder relevanten Statusänderung den Datensatz frisch cachen.
        -- Besonders wichtig sind applied/invited, bevor Blizzard das
        -- Suchergebnis beim Beitritt aus der Liste entfernt.
        if searchResultID then
            CacheResult(searchResultID, groupName)
        end

        return
    end

    if event == "LFG_LIST_JOINED_GROUP" then
        local searchResultID, groupName = ...

        if not IsEnabled() then
            return
        end

        local data =
            (searchResultID and resultCache[searchResultID])
            or ReadResultData(searchResultID, groupName)

        if data then
            if groupName and groupName ~= "" then
                data.groupName = groupName
            end

            ShowReminder(data)
        end
    end
end)

G.RegisterOnDatabaseReady(function()
    if G.db.groupFinderReminderEnabled == nil then
        G.db.groupFinderReminderEnabled = true
    end
end)
