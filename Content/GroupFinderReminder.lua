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
title:SetText("Gruppensucher-Reminder")

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

local okButton = CreateFrame(
    "Button",
    nil,
    popup,
    "UIPanelButtonTemplate"
)
okButton:SetSize(100, 24)
okButton:SetPoint("BOTTOM", popup, "BOTTOM", 0, 12)
okButton:SetText("Alles klar")
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

    activityText:SetText(
        string.format(
            "%s: |cffffffff%s|r",
            data.activityType or "Aktivität",
            data.activityName or "Unbekannt"
        )
    )

    difficultyText:SetText(
        "Schwierigkeitsgrad: |cffffd200"
        .. (data.difficulty or "Unbekannt")
        .. "|r"
    )

    if data.groupName and data.groupName ~= "" then
        groupText:SetText("Gruppe: " .. data.groupName)
        groupText:Show()
    else
        groupText:Hide()
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
