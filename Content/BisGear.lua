local ADDON_NAME, G = ...

local TAB_KEY = "bisGear"

local bisGearFrame = CreateFrame("Frame", "GrimoireBisGearTab", G.panel)
bisGearFrame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
bisGearFrame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
-- KEIN BOTTOM-Anchor ans Panel -- Höhe kommt aus dem Inhalt, siehe Layout()
-- weiter unten (gleiches Prinzip wie bei Content/Guide.lua).

-- ============================================================
-- Kanonische Slots: Deutsches Label + Blizzard-Inventory-Slot-ID
-- (für den Abgleich mit dem eigenen ausgerüsteten Item).
-- ============================================================
local CANONICAL_SLOTS = {
    { key = "head",     label = "Kopf",           invSlot = INVSLOT_HEAD },
    { key = "neck",     label = "Hals",           invSlot = INVSLOT_NECK },
    { key = "shoulder", label = "Schultern",      invSlot = INVSLOT_SHOULDER },
    { key = "back",     label = "Rücken",         invSlot = INVSLOT_BACK },
    { key = "chest",    label = "Brust",          invSlot = INVSLOT_CHEST },
    { key = "wrist",    label = "Handgelenke",    invSlot = INVSLOT_WRIST },
    { key = "hands",    label = "Hände",          invSlot = INVSLOT_HAND },
    { key = "waist",    label = "Taille",         invSlot = INVSLOT_WAIST },
    { key = "legs",     label = "Beine",          invSlot = INVSLOT_LEGS },
    { key = "feet",     label = "Füße",           invSlot = INVSLOT_FEET },
    { key = "ring1",    label = "Ring 1",         invSlot = INVSLOT_FINGER1 },
    { key = "ring2",    label = "Ring 2",         invSlot = INVSLOT_FINGER2 },
    { key = "mainhand", label = "Waffe",          invSlot = INVSLOT_MAINHAND },
    { key = "offhand",  label = "Nebenhand",      invSlot = INVSLOT_OFFHAND },
    { key = "trinket1", label = "Schmuckstück 1", invSlot = INVSLOT_TRINKET1 },
    { key = "trinket2", label = "Schmuckstück 2", invSlot = INVSLOT_TRINKET2 },
}
local SLOT_INFO = {}
for _, s in ipairs(CANONICAL_SLOTS) do SLOT_INFO[s.key] = s end

-- Archon liefert pro Eintrag KEIN slot-Feld -- die Reihenfolge der 16
-- zurückgegebenen Items ist implizit (siehe scrape_all_archon.py: erst die
-- 12 "gear"-Slots, dann 2 "weapons", dann 2 "trinkets"). Anhand identischer
-- Items über mehrere Specs hinweg verifiziert (z.B. liegt "Silvermoon
-- Agent's Deflectors" bei allen drei Quellen konsistent auf Handgelenke).
-- Muss in Sync mit archon.py bleiben, falls sich dort mal die
-- Scrape-Reihenfolge ändert.
local ARCHON_SLOT_ORDER = {
    "head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist",
    "legs", "feet", "ring1", "ring2", "mainhand", "offhand", "trinket1", "trinket2",
}

-- Wowhead und Icy-Veins liefern das slot-Feld als englisches Klartextwort,
-- aber mit unterschiedlicher Wortwahl je Quelle ("Head" vs. "Helm", "Belt"
-- vs. "Waist" usw.). "Ring"/"Trinket" bewusst nicht hier -- die kommen pro
-- Liste zweimal vor und brauchen einen Zähler statt eines festen Mappings,
-- siehe ResolveSlotKey().
local RAW_SLOT_TO_KEY = {
    ["weapon"] = "mainhand", ["main hand"] = "mainhand",
    ["offhand"] = "offhand", ["off hand"] = "offhand",
    ["head"] = "head", ["helm"] = "head",
    ["neck"] = "neck",
    ["shoulders"] = "shoulder", ["shoulder"] = "shoulder",
    ["cloak"] = "back", ["back"] = "back",
    ["chest"] = "chest",
    ["wrist"] = "wrist", ["bracers"] = "wrist",
    ["gloves"] = "hands", ["hands"] = "hands",
    ["belt"] = "waist", ["waist"] = "waist",
    ["legs"] = "legs",
    ["boots"] = "feet", ["feet"] = "feet",
}

-- Löst das rohe slot-Feld (Wowhead/Icy-Veins) in einen kanonischen Key auf.
-- counters zählt "Ring"/"Trinket" hoch (pro Liste 2x vorhanden, z.B. auch
-- "Trinket (Raw Damage)" bei Wowhead -- daher Teilstring-Match "^ring"/
-- "^trinket" statt exaktem Vergleich).
local function ResolveSlotKey(rawSlot, counters)
    local lower = rawSlot:lower()
    if lower:find("^ring") then
        counters.ring = (counters.ring or 0) + 1
        return counters.ring == 1 and "ring1" or "ring2"
    end
    if lower:find("^trinket") then
        counters.trinket = (counters.trinket or 0) + 1
        return counters.trinket == 1 and "trinket1" or "trinket2"
    end
    return RAW_SLOT_TO_KEY[lower]
end

-- ============================================================
-- Quellen: jede liefert data[classToken][specKey].bisGear (Rohform je nach
-- Quelle unterschiedlich, siehe oben) -- normalize() bringt alle auf
-- dieselbe Form: { {key, item={itemId,name}, source?, bis?}, ... }
-- Reihenfolge hier = Dropdown-Reihenfolge = Wowhead zuerst (Standard),
-- dann Archon, dann Icy Veins.
-- ============================================================
local SOURCES = {
    {
        key = "wowhead", label = "Wowhead",
        getRaw = function(classToken, specKey)
            local d = GrimoireGearData and GrimoireGearData[classToken] and GrimoireGearData[classToken][specKey]
            return d and d.bisGear
        end,
        normalize = function(rawSlots)
            local counters, out = {}, {}
            for _, s in ipairs(rawSlots) do
                local key = ResolveSlotKey(s.slot, counters)
                if key then
                    table.insert(out, { key = key, item = s.item, source = s.source })
                end
            end
            return out
        end,
    },
    {
        key = "archon", label = "Archon",
        getRaw = function(classToken, specKey)
            local d = GrimoireArchonGearData and GrimoireArchonGearData[classToken] and GrimoireArchonGearData[classToken][specKey]
            return d and d.bisGear
        end,
        normalize = function(rawSlots)
            local out = {}
            for i, s in ipairs(rawSlots) do
                local key = ARCHON_SLOT_ORDER[i]
                if key then
                    table.insert(out, { key = key, item = s.item, bis = s.bis })
                end
            end
            return out
        end,
    },
    {
        key = "icyveins", label = "Icy Veins",
        getRaw = function(classToken, specKey)
            local d = GrimoireIcyVeinsData and GrimoireIcyVeinsData[classToken] and GrimoireIcyVeinsData[classToken][specKey]
            return d and d.bisGear
        end,
        normalize = function(rawSlots)
            local counters, out = {}, {}
            for _, s in ipairs(rawSlots) do
                local key = ResolveSlotKey(s.slot, counters)
                if key then
                    table.insert(out, { key = key, item = s.item, source = s.source })
                end
            end
            return out
        end,
    },
}
local SOURCE_BY_KEY = {}
for _, src in ipairs(SOURCES) do SOURCE_BY_KEY[src.key] = src end

-- ============================================================
-- BiS-Quellen-Navigation
-- Linksklick auf ein BiS-Item versucht die Quelle im Abenteuerführer
-- zu finden und öffnet direkt die passende Instanz / den Boss.
-- Welt-Wegpunkte können über SOURCE_WAYPOINTS ergänzt werden.
-- ============================================================

local SOURCE_WAYPOINTS = {
    -- Beispiel für spätere Weltquellen:
    -- ["name der quelle"] = { mapID = 1234, x = 0.50, y = 0.50, label = "Quelle" },
}

local navToast
local navToastText
local navToastGeneration = 0

local function EnsureNavToast()
    if navToast then return end

    navToast = CreateFrame("Frame", nil, G.panel, "BackdropTemplate")
    navToast:SetSize(270, 34)
    navToast:SetPoint("BOTTOM", G.panel, "BOTTOM", 0, 18)
    navToast:SetFrameStrata("DIALOG")
    navToast:SetFrameLevel(G.panel:GetFrameLevel() + 30)
    navToast:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    navToast:SetBackdropColor(0.04, 0.04, 0.04, 0.94)
    navToast:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.95)
    navToast:SetAlpha(0)
    navToast:Hide()

    navToastText = navToast:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    navToastText:SetPoint("LEFT", navToast, "LEFT", 10, 0)
    navToastText:SetPoint("RIGHT", navToast, "RIGHT", -10, 0)
    navToastText:SetJustifyH("CENTER")
end

local function ShowNavToast(message)
    EnsureNavToast()
    navToastGeneration = navToastGeneration + 1
    local generation = navToastGeneration

    navToastText:SetText(message or "")
    navToast:SetAlpha(0)
    navToast:Show()

    if G.SoftAlpha then
        G.SoftAlpha(navToast, 1, 0.15)
    else
        navToast:SetAlpha(1)
    end

    C_Timer.After(2.2, function()
        if generation ~= navToastGeneration then return end
        if G.SoftHide then
            G.SoftHide(navToast, 0.20)
        else
            navToast:Hide()
        end
    end)
end

local function NormalizeSourceName(value)
    if not value then return "" end
    value = value:lower()
    value = value:gsub("|c%x%x%x%x%x%x%x%x", "")
    value = value:gsub("|r", "")
    value = value:gsub("[%p%c]", " ")
    value = value:gsub("%s+", " ")
    value = value:match("^%s*(.-)%s*$") or value
    return value
end

local function NamesMatch(a, b)
    a = NormalizeSourceName(a)
    b = NormalizeSourceName(b)

    if a == "" or b == "" then return false end
    if a == b then return true end

    -- Quellen enthalten gelegentlich Zusätze. Nur längere Namen als
    -- Teiltreffer zulassen, damit kurze Bossnamen keine Fehlmatches erzeugen.
    if #a >= 6 and b:find(a, 1, true) then return true end
    if #b >= 6 and a:find(b, 1, true) then return true end
    return false
end

local SOURCE_NAME_ALIASES_DE = {
    -- Midnight / aktueller deutscher Client
    ["voidscar arena"] = "Arena der Leerennarbe",
}

local function GetLocalizedSourceAlias(sourceName)
    local normalized = NormalizeSourceName(sourceName)
    return SOURCE_NAME_ALIASES_DE[normalized] or sourceName
end

local function OpenEncounterJournalResult(result, searchedItemID)
    if not result or not result.instanceID then return false end

    if EncounterJournal_LoadUI and not EncounterJournal then
        EncounterJournal_LoadUI()
    end

    if not EncounterJournal or not EncounterJournal_OpenJournal then
        return false
    end

    -- Das ist Blizzards eigener Weg, den auch die Suchergebnisse im
    -- Abenteuerführer verwenden:
    -- Instanz -> Encounter/Boss -> bei itemID/lootID automatisch Beute-Tab.
    --
    -- Der sechste Parameter muss nur non-nil sein, damit OpenJournal()
    -- den Loot-Tab anklickt. Wenn wir einen echten searchLootID haben,
    -- geben wir diesen weiter; sonst die gesuchte Item-ID.
    local lootMarker = result.searchLootID or searchedItemID

    EncounterJournal_OpenJournal(
        result.difficultyID,
        result.instanceID,
        result.encounterID,
        nil, -- sectionID
        nil, -- creatureID
        lootMarker
    )

    return true
end

local function ExtractItemIDFromLink(link)
    if not link then return nil end
    local itemID = link:match("item:(%d+)")
    return itemID and tonumber(itemID) or nil
end

local function FinishJournalSearch()
    if EJ_EndSearch then
        EJ_EndSearch()
    elseif EJ_ClearSearch then
        EJ_ClearSearch()
    end
end

local function FinishJournalSearch()
    if EJ_EndSearch then
        EJ_EndSearch()
    elseif EJ_ClearSearch then
        EJ_ClearSearch()
    end
end

local function RunJournalSearch(searchText, callback)
    if not searchText or searchText == "" or not callback then
        callback({})
        return
    end

    if not EJ_SetSearch or not EJ_GetNumSearchResults or not EJ_GetSearchResult then
        callback({})
        return
    end

    if EncounterJournal_LoadUI and not EncounterJournal then
        EncounterJournal_LoadUI()
    end

    if EJ_ClearSearch then
        EJ_ClearSearch()
    end

    EJ_SetSearch(searchText)

    local attempts = 0
    local MAX_ATTEMPTS = 30

    local function CheckResults()
        attempts = attempts + 1

        local results = {}
        local count = EJ_GetNumSearchResults() or 0

        for i = 1, count do
            local id, resultType, difficultyID, instanceID, encounterID, itemLink =
                EJ_GetSearchResult(i)

            results[#results + 1] = {
                id = id,
                resultType = resultType,
                difficultyID = difficultyID,
                instanceID = instanceID,
                encounterID = encounterID,
                itemLink = itemLink,
            }
        end

        local finished = not EJ_IsSearchFinished or EJ_IsSearchFinished()

        if finished or attempts >= MAX_ATTEMPTS then
            FinishJournalSearch()
            callback(results)
            return
        end

        C_Timer.After(0.08, CheckResults)
    end

    C_Timer.After(0.05, CheckResults)
end

local function FindEncounterJournalSourceByItemID(itemID, callback)
    if not itemID or not callback then
        if callback then callback(nil) end
        return
    end

    local item = Item:CreateFromItemID(itemID)

    item:ContinueOnItemLoad(function()
        local localizedName = item:GetItemName()
        if not localizedName or localizedName == "" then
            callback(nil)
            return
        end

        RunJournalSearch(localizedName, function(results)
            for _, searchResult in ipairs(results) do
                -- 0 = Item/Loot in Blizzards Encounter-Journal-Suche.
                if searchResult.resultType == 0 and searchResult.instanceID then
                    -- In Blizzards eigenem UI ist "id" hier die Loot-ID.
                    -- Darüber erhalten wir zuverlässig die echte Item-ID,
                    -- selbst wenn der Item-Link noch nicht gecacht ist.
                    local lootInfo
                    if C_EncounterJournal and C_EncounterJournal.GetLootInfo then
                        lootInfo = C_EncounterJournal.GetLootInfo(searchResult.id)
                    end

                    local resultItemID = lootInfo and lootInfo.itemID

                    if not resultItemID then
                        resultItemID = ExtractItemIDFromLink(searchResult.itemLink)
                    end

                    if resultItemID == itemID then
                        -- Wichtig:
                        -- Bei einem Item-Suchergebnis benutzen wir für den Boss
                        -- bevorzugt die encounterID aus dem Loot-Datensatz selbst.
                        -- Genau dieser Datensatz gehört zu searchResult.id (Loot-ID).
                        -- Dadurch stammen Beute-Tab UND Boss aus derselben Quelle.
                        local lootEncounterID = lootInfo and lootInfo.encounterID
                        local resolvedEncounterID = lootEncounterID or searchResult.encounterID

                        callback({
                            instanceID = searchResult.instanceID,
                            encounterID = resolvedEncounterID,
                            difficultyID = searchResult.difficultyID,
                            searchLootID = searchResult.id,
                            instanceName = EJ_GetInstanceInfo
                                and select(1, EJ_GetInstanceInfo(searchResult.instanceID)),
                            encounterName = resolvedEncounterID
                                and EJ_GetEncounterInfo
                                and select(1, EJ_GetEncounterInfo(resolvedEncounterID)),
                        })
                        return
                    end
                end
            end

            callback(nil)
        end)
    end)
end

local function FindInstanceByLocalizedSource(sourceName, callback)
    if not sourceName or sourceName == "" then
        callback(nil)
        return
    end

    local localizedSource = GetLocalizedSourceAlias(sourceName)

    RunJournalSearch(localizedSource, function(results)
        -- 4 = Instance in Blizzards Encounter-Journal-Suche.
        for _, searchResult in ipairs(results) do
            if searchResult.resultType == 4 then
                local instanceID = searchResult.id or searchResult.instanceID

                if instanceID then
                    callback({
                        instanceID = instanceID,
                        difficultyID = searchResult.difficultyID,
                        instanceName = EJ_GetInstanceInfo
                            and select(1, EJ_GetInstanceInfo(instanceID)),
                    })
                    return
                end
            end
        end

        -- Falls die Suche statt eines Instance-Resultats direkt einen
        -- Encounter liefert, können wir auch daraus die Instanz nehmen.
        for _, searchResult in ipairs(results) do
            if searchResult.instanceID then
                callback({
                    instanceID = searchResult.instanceID,
                    encounterID = searchResult.encounterID,
                    difficultyID = searchResult.difficultyID,
                    instanceName = EJ_GetInstanceInfo
                        and select(1, EJ_GetInstanceInfo(searchResult.instanceID)),
                    encounterName = searchResult.encounterID
                        and EJ_GetEncounterInfo
                        and select(1, EJ_GetEncounterInfo(searchResult.encounterID)),
                })
                return
            end
        end

        callback(nil)
    end)
end

local function TrySetSourceWaypoint(sourceName)
    local waypoint = SOURCE_WAYPOINTS[NormalizeSourceName(sourceName)]
    if not waypoint then return false end
    if not C_Map or not C_Map.SetUserWaypoint or not UiMapPoint then return false end

    local point = UiMapPoint.CreateFromCoordinates(waypoint.mapID, waypoint.x, waypoint.y)
    if not point then return false end

    C_Map.SetUserWaypoint(point)

    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end

    if OpenWorldMap then
        OpenWorldMap(waypoint.mapID)
    elseif ToggleWorldMap then
        ToggleWorldMap()
    end

    return true
end

local function NavigateToBisSource(itemID, sourceName)
    if not itemID then
        ShowNavToast("Für dieses Item fehlt die Item-ID.")
        return
    end

    local normalized = NormalizeSourceName(sourceName)
    if normalized:find("craft", 1, true)
        or normalized:find("herstellung", 1, true)
        or normalized:find("crafted", 1, true)
    then
        ShowNavToast("Quelle: Herstellung")
        return
    end

    if sourceName and TrySetSourceWaypoint(sourceName) then
        ShowNavToast("Kartenmarker gesetzt: " .. sourceName)
        return
    end

    ShowNavToast("Quelle wird gesucht …")

    -- Weg 1: Item-ID -> lokaler deutscher Itemname -> EJ-Lootsuche.
    FindEncounterJournalSourceByItemID(itemID, function(result)
        if result and OpenEncounterJournalResult(result, itemID) then
            if result.encounterID then
                ShowNavToast(
                    "Beute geöffnet: "
                    .. (result.encounterName or result.instanceName or "Boss")
                )
            else
                ShowNavToast(
                    "Beute geöffnet: "
                    .. (result.instanceName or "Dungeon/Raid")
                )
            end
            return
        end

        -- Weg 2: einzelne neue/noch nicht sauber indexierte Items.
        -- Dann über die Quelle zur Instanz navigieren.
        FindInstanceByLocalizedSource(sourceName, function(sourceResult)
            if sourceResult and OpenEncounterJournalResult(sourceResult, itemID) then
                ShowNavToast(
                    "Instanz/Beute geöffnet: "
                    .. (sourceResult.instanceName or sourceName or "Dungeon/Raid")
                )
                return
            end

            if sourceName and sourceName ~= "" then
                ShowNavToast("Keine automatische Navigation: " .. sourceName)
            else
                ShowNavToast("Keine Dungeon-/Raidquelle gefunden.")
            end
        end)
    end)
end

-- ============================================================
-- UI-Grundgerüst (Muster wie StatPriority.lua/StatTargets.lua)
-- ============================================================
local DD_HEIGHT = 24
local DD_GAP = 6
local ROW_HEIGHT = 34
local ICON_SIZE = 24

-- Zusätzlicher Platz unter den beiden BiS-Dropdowns:
-- Soundwarnung + Soundauswahl + eigene/fremde Drops.
local ALERT_ROW_HEIGHT = 24
local ALERT_GAP = 4
local CONTROL_AREA_HEIGHT = DD_HEIGHT + DD_GAP + ALERT_ROW_HEIGHT + ALERT_GAP + ALERT_ROW_HEIGHT

local BIS_ALERT_SOUNDS = {
    {
        key = "epic",
        label = "Epische Beute",
        getKit = function()
            return SOUNDKIT and (SOUNDKIT.UI_EPICLOOT_TOAST or SOUNDKIT.READY_CHECK)
        end,
    },
    {
        key = "ready",
        label = "Bereitschaftscheck",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.READY_CHECK
        end,
    },
    {
        key = "raid",
        label = "Raid-Warnung",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.RAID_WARNING
        end,
    },
    {
        key = "boss",
        label = "Boss-Warnung",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.RAID_BOSS_EMOTE_WARNING
        end,
    },
    {
        key = "alarm1",
        label = "Alarm 1",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_1
        end,
    },
    {
        key = "alarm2",
        label = "Alarm 2",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_2
        end,
    },
    {
        key = "alarm3",
        label = "Alarm 3",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3
        end,
    },
    {
        key = "quest",
        label = "Quest abgeschlossen",
        getKit = function()
            return SOUNDKIT and (SOUNDKIT.UI_AUTO_QUEST_COMPLETE or SOUNDKIT.IG_QUEST_LIST_COMPLETE)
        end,
    },
    {
        key = "lfgreward",
        label = "Dungeon-Belohnung",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.LFG_REWARDS
        end,
    },
    {
        key = "rolecheck",
        label = "Rollenauswahl",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.LFG_ROLE_CHECK
        end,
    },
    {
        key = "pvpqueue",
        label = "PvP-Warteschlange",
        getKit = function()
            return SOUNDKIT and (SOUNDKIT.PVP_THROUGH_QUEUE or SOUNDKIT.PVP_ENTER_QUEUE)
        end,
    },
    {
        key = "bnet",
        label = "Battle.net Hinweis",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.UI_BNET_TOAST
        end,
    },
    {
        key = "whisper",
        label = "Flüstern",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.TELL_MESSAGE
        end,
    },
    {
        key = "mapping",
        label = "Karten-Ping",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.MAP_PING
        end,
    },
    {
        key = "achievement",
        label = "Erfolg-Fenster",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.ACHIEVEMENT_MENU_OPEN
        end,
    },
    {
        key = "auction",
        label = "Auktionshaus",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.AUCTION_WINDOW_OPEN
        end,
    },
    {
        key = "power",
        label = "Power-Aura",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.UI_POWER_AURA_GENERIC
        end,
    },
    {
        key = "lootcoin",
        label = "Loot / Münzen",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.LOOT_WINDOW_COIN_SOUND
        end,
    },
    {
        key = "click",
        label = "Dezenter UI-Klick",
        getKit = function()
            return SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        end,
    },
}

local BIS_ALERT_SOUND_BY_KEY = {}
for _, def in ipairs(BIS_ALERT_SOUNDS) do
    BIS_ALERT_SOUND_BY_KEY[def.key] = def
end

local trackedBisItemIDs = {}

local function PlayBisAlertSound()
    if not G.db or not G.db.bisDropAlert then return end

    local soundKey = G.db.bisDropAlert.sound or "pvpqueue"
    local def = BIS_ALERT_SOUND_BY_KEY[soundKey] or BIS_ALERT_SOUND_BY_KEY.pvpqueue
    local kit = def and def.getKit and def.getKit()

    if kit then
        PlaySound(kit, "Master")
    end
end

local function PreviewBisAlertSound(soundKey)
    local def = BIS_ALERT_SOUND_BY_KEY[soundKey]
    local kit = def and def.getKit and def.getKit()

    if kit then
        PlaySound(kit, "Master")
    end
end

local sourceDropdown = CreateFrame("DropdownButton", "GrimoireBisGearSourceDD", bisGearFrame, "WowStyle1DropdownTemplate")
sourceDropdown:SetPoint("TOPLEFT", 0, 0)
sourceDropdown:SetSize(140, DD_HEIGHT)

local contextDropdown = CreateFrame("DropdownButton", "GrimoireBisGearContextDD", bisGearFrame, "WowStyle1DropdownTemplate")
contextDropdown:SetPoint("LEFT", sourceDropdown, "RIGHT", 8, 0)
contextDropdown:SetSize(140, DD_HEIGHT)
contextDropdown:Hide()

-- ============================================================
-- BiS-Drop-Sound Einstellungen
-- ============================================================

local alertCheckbox = CreateFrame(
    "CheckButton",
    "GrimoireBisDropAlertEnabled",
    bisGearFrame,
    "UICheckButtonTemplate"
)
alertCheckbox:SetPoint("TOPLEFT", sourceDropdown, "BOTTOMLEFT", -4, -DD_GAP)
alertCheckbox:SetSize(24, 24)

local alertLabel = bisGearFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
alertLabel:SetPoint("LEFT", alertCheckbox, "RIGHT", 2, 0)
alertLabel:SetText("Diese Liste überwachen")

-- Kleine Hilfe direkt neben der Einstellung.
local alertHelp = CreateFrame("Frame", nil, bisGearFrame)
alertHelp:SetSize(16, 16)
alertHelp:SetPoint("LEFT", alertLabel, "RIGHT", 5, 0)
alertHelp:EnableMouse(true)

local alertHelpText = alertHelp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
alertHelpText:SetPoint("CENTER", 0, 0)
alertHelpText:SetText("?")
alertHelpText:SetTextColor(0.72, 0.72, 0.72)

alertHelp:SetScript("OnEnter", function(self)
    alertHelpText:SetTextColor(1.0, 0.82, 0.0)

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("BiS-Drop-Warnung")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Überwacht genau die aktuell ausgewählte BiS-Liste und Unterkategorie.",
        1, 1, 1,
        true
    )
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Es kann immer nur eine BiS-Liste gleichzeitig überwacht werden.",
        0.82, 0.82, 0.82,
        true
    )
    GameTooltip:AddLine(
        "Aktivierst du den Haken bei einer anderen Liste, wird die vorherige automatisch deaktiviert.",
        0.82, 0.82, 0.82,
        true
    )
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Eigene Drops: Sound, wenn du selbst eines deiner BiS-Items erhältst.",
        0.45, 0.85, 1.0,
        true
    )
    GameTooltip:AddLine(
        "Drops anderer: Sound, wenn ein Gruppen- oder Raidmitglied eines deiner BiS-Items erhält.",
        0.45, 0.85, 1.0,
        true
    )
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Den Warnton kannst du im Dropdown auswählen und direkt vorhören.",
        1.0, 0.82, 0.0,
        true
    )
    GameTooltip:Show()
end)

alertHelp:SetScript("OnLeave", function()
    alertHelpText:SetTextColor(0.72, 0.72, 0.72)
    GameTooltip:Hide()
end)

local soundDropdown = CreateFrame(
    "DropdownButton",
    "GrimoireBisDropSoundDD",
    bisGearFrame,
    "WowStyle1DropdownTemplate"
)
soundDropdown:SetPoint("LEFT", alertHelp, "RIGHT", 7, 0)
soundDropdown:SetSize(135, DD_HEIGHT)

local ownDropCheckbox = CreateFrame(
    "CheckButton",
    "GrimoireBisDropAlertOwn",
    bisGearFrame,
    "UICheckButtonTemplate"
)
ownDropCheckbox:SetPoint("TOPLEFT", alertCheckbox, "BOTTOMLEFT", 0, -ALERT_GAP)
ownDropCheckbox:SetSize(24, 24)

local ownDropLabel = bisGearFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
ownDropLabel:SetPoint("LEFT", ownDropCheckbox, "RIGHT", 2, 0)
ownDropLabel:SetText("Eigene Drops")

local othersDropCheckbox = CreateFrame(
    "CheckButton",
    "GrimoireBisDropAlertOthers",
    bisGearFrame,
    "UICheckButtonTemplate"
)
othersDropCheckbox:SetPoint("LEFT", ownDropLabel, "RIGHT", 12, 0)
othersDropCheckbox:SetSize(24, 24)

local othersDropLabel = bisGearFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
othersDropLabel:SetPoint("LEFT", othersDropCheckbox, "RIGHT", 2, 0)
othersDropLabel:SetText("Drops anderer")

local rows = {}

local fallbackText = bisGearFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

local selectedSourceKey = SOURCES[1].key -- Wowhead ist Standard
local selectedContext = "Overall"

local function FindContextEntryByLabel(raw, label)
    if not raw then return nil end
    for _, entry in ipairs(raw) do
        if entry.label == label then
            return entry
        end
    end
    return nil
end

local function RebuildTrackedBisItems()
    wipe(trackedBisItemIDs)

    if not G.db or not G.db.bisDropAlert or not G.db.bisDropAlert.enabled then
        return
    end

    local classToken = G.GetSelectedClass and G.GetSelectedClass()
    local specKey = G.GetSelectedSpec and G.GetSelectedSpec()
    if not classToken or not specKey then return end

    -- Wichtig: Überwacht wird NICHT automatisch die gerade sichtbare Liste,
    -- sondern ausschließlich die explizit angehakte Quelle + Unterkategorie.
    local cfg = G.db.bisDropAlert
    local source = SOURCE_BY_KEY[cfg.sourceKey or "wowhead"]
    if not source then return end

    local raw = source.getRaw(classToken, specKey)
    if not raw or #raw == 0 then return end

    local contextEntry = FindContextEntryByLabel(raw, cfg.context or "Overall")
    if not contextEntry then
        return
    end

    local normalized = source.normalize(contextEntry.slots)
    for _, entry in ipairs(normalized or {}) do
        local itemID = entry.item and entry.item.itemId
        if itemID then
            trackedBisItemIDs[itemID] = true
        end
    end
end

local function EscapePattern(textValue)
    return (textValue:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function FormatToLootPattern(formatString)
    if not formatString or formatString == "" then return nil end

    -- Format-Platzhalter vor dem Escapen sichern.
    local value = formatString
    value = value:gsub("%%(%d+)%$s", "__GRIM_S__")
    value = value:gsub("%%(%d+)%$d", "__GRIM_D__")
    value = value:gsub("%%s", "__GRIM_S__")
    value = value:gsub("%%d", "__GRIM_D__")

    value = EscapePattern(value)
    value = value:gsub("__GRIM_S__", ".-")
    value = value:gsub("__GRIM_D__", "%%d+")

    return "^" .. value .. "$"
end

local SELF_LOOT_PATTERNS = {}
for _, globalName in ipairs({
    "LOOT_ITEM_SELF",
    "LOOT_ITEM_SELF_MULTIPLE",
    "LOOT_ITEM_PUSHED_SELF",
    "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
}) do
    local fmt = _G[globalName]
    local pattern = FormatToLootPattern(fmt)
    if pattern then
        SELF_LOOT_PATTERNS[#SELF_LOOT_PATTERNS + 1] = pattern
    end
end

local function IsSelfLootMessage(message)
    for _, pattern in ipairs(SELF_LOOT_PATTERNS) do
        if message:match(pattern) then
            return true
        end
    end
    return false
end

local function GetLootedItemID(message)
    if not message then return nil end

    -- Sprachunabhängig: Item-ID direkt aus dem Hyperlink lesen.
    local itemID = message:match("|Hitem:(%d+)")
    return itemID and tonumber(itemID) or nil
end

local lootEventFrame = CreateFrame("Frame")
lootEventFrame:RegisterEvent("CHAT_MSG_LOOT")
lootEventFrame:SetScript("OnEvent", function(_, _, message)
    if not G.db or not G.db.bisDropAlert then return end

    local cfg = G.db.bisDropAlert
    if not cfg.enabled then return end

    local itemID = GetLootedItemID(message)
    if not itemID or not trackedBisItemIDs[itemID] then return end

    local isSelf = IsSelfLootMessage(message)

    if isSelf then
        if cfg.ownDrops then
            PlayBisAlertSound()
        end
    else
        -- Fremde Drops nur berücksichtigen, wenn man tatsächlich in einer
        -- Gruppe/Raid ist, damit keine zufälligen Lootmeldungen stören.
        if cfg.otherDrops and IsInGroup() then
            PlayBisAlertSound()
        end
    end
end)

local function SyncAlertControls()
    if not G.db or not G.db.bisDropAlert then return end

    local cfg = G.db.bisDropAlert

    -- Der Haken gilt nur für GENAU die aktuell sichtbare Quelle +
    -- Unterkategorie. Andere Listen bleiben sichtbar, aber unangehakt.
    local currentListIsTracked =
        cfg.enabled == true
        and cfg.sourceKey == selectedSourceKey
        and cfg.context == selectedContext

    alertCheckbox:SetChecked(currentListIsTracked)
    ownDropCheckbox:SetChecked(cfg.ownDrops ~= false)
    othersDropCheckbox:SetChecked(cfg.otherDrops == true)

    local soundDef = BIS_ALERT_SOUND_BY_KEY[cfg.sound or "epic"] or BIS_ALERT_SOUND_BY_KEY.pvpqueue
    soundDropdown:SetText(soundDef and soundDef.label or "Epische Beute")

    soundDropdown:SetupMenu(function(_, rootDescription)
        for _, def in ipairs(BIS_ALERT_SOUNDS) do
            local kit = def.getKit and def.getKit()
            if kit then
                rootDescription:CreateRadio(
                    def.label,
                    function()
                        return (G.db.bisDropAlert.sound or "pvpqueue") == def.key
                    end,
                    function()
                        G.db.bisDropAlert.sound = def.key
                        soundDropdown:SetText(def.label)

                        -- Vorhören direkt bei Auswahl.
                        PreviewBisAlertSound(def.key)
                    end
                )
            end
        end
    end)

    soundDropdown:SetEnabled(currentListIsTracked)
    ownDropCheckbox:SetEnabled(currentListIsTracked)
    othersDropCheckbox:SetEnabled(currentListIsTracked)
end

alertCheckbox:SetScript("OnClick", function(self)
    if not G.db or not G.db.bisDropAlert then return end

    local cfg = G.db.bisDropAlert

    if self:GetChecked() then
        -- Exklusiv: Diese Liste wird die EINZIGE überwachte Liste.
        -- Ein vorheriger Haken bei Wowhead/Archon/Icy verschwindet damit
        -- automatisch, weil sourceKey/context überschrieben werden.
        cfg.enabled = true
        cfg.sourceKey = selectedSourceKey
        cfg.context = selectedContext
    else
        -- Nur deaktivieren, wenn gerade die tatsächlich überwachte Liste
        -- abgewählt wurde.
        if cfg.sourceKey == selectedSourceKey and cfg.context == selectedContext then
            cfg.enabled = false
        end
    end

    RebuildTrackedBisItems()
    SyncAlertControls()
end)

ownDropCheckbox:SetScript("OnClick", function(self)
    if not G.db or not G.db.bisDropAlert then return end
    G.db.bisDropAlert.ownDrops = self:GetChecked() and true or false
end)

othersDropCheckbox:SetScript("OnClick", function(self)
    if not G.db or not G.db.bisDropAlert then return end
    G.db.bisDropAlert.otherDrops = self:GetChecked() and true or false
end)

local function CreateRow(i)
    local row = CreateFrame("Frame", nil, bisGearFrame)
    row:SetHeight(ROW_HEIGHT)

    local ownedHighlight = row:CreateTexture(nil, "BACKGROUND")
    ownedHighlight:SetAllPoints()
    ownedHighlight:SetColorTexture(0.3, 0.9, 0.3, 0.10)
    ownedHighlight:Hide()
    row.ownedHighlight = ownedHighlight

    local iconButton = CreateFrame("Button", nil, row)
    iconButton:SetSize(ICON_SIZE, ICON_SIZE)
    iconButton:SetPoint("LEFT", 4, 0)
    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
    iconTexture:SetAllPoints()
    iconButton.texture = iconTexture
    iconButton:SetScript("OnEnter", function(self)
        if not self.itemId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemId)
        if self.sourceName and self.sourceName ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Linksklick: Quelle anzeigen", 1.0, 0.82, 0.0)
            GameTooltip:AddLine("Rechtsklick: Anprobe", 0.65, 0.65, 0.65)
        end
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", GameTooltip_Hide)
    iconButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    iconButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            NavigateToBisSource(self.itemId, self.sourceName)
        elseif button == "RightButton" and self.itemId then
            DressUpItemLink("item:" .. tostring(self.itemId))
        end
    end)
    row.iconButton = iconButton

    local slotText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slotText:SetPoint("TOPLEFT", iconButton, "TOPRIGHT", 6, -1)
    slotText:SetWidth(70)
    slotText:SetJustifyH("LEFT")
    slotText:SetWordWrap(false)
    slotText:SetTextColor(0.6, 0.6, 0.6)
    row.slotText = slotText

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", slotText, "TOPRIGHT", 4, 0)
    nameText:SetPoint("RIGHT", 0, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sourceText:SetPoint("TOPLEFT", slotText, "BOTTOMLEFT", 0, -2)
    sourceText:SetPoint("RIGHT", 0, 0)
    sourceText:SetJustifyH("LEFT")
    sourceText:SetWordWrap(false)
    row.sourceText = sourceText

    row:Hide()
    rows[i] = row
    return row
end

-- Nur bei Refresh(), wenn dieser Tab gerade aktiv ist, die Panel-Höhe
-- anfassen -- sonst würde ein Guide-Tab-Refresh im Hintergrund (z.B. durch
-- Live-Stat-Events) das Panel verstellen, während BiS-Gear sichtbar ist,
-- und umgekehrt. G.GetActiveTab() existiert bereits (siehe StatTargets.lua).
local function ReportContentHeight(height)
    if G.SetPanelContentHeight and G.GetActiveTab and G.GetActiveTab() == TAB_KEY then
        G.SetPanelContentHeight(height)
    end
end

local function Layout(totalHeight)
    bisGearFrame:SetHeight(totalHeight)
    ReportContentHeight(totalHeight)
end

local function ShowFallback(text, yOffset)
    yOffset = yOffset or 0
    for _, row in ipairs(rows) do row:Hide() end
    fallbackText:ClearAllPoints()
    fallbackText:SetPoint("TOPLEFT", bisGearFrame, "TOPLEFT", 0, -yOffset)
    fallbackText:SetPoint("RIGHT", bisGearFrame, "RIGHT", 0, 0)
    fallbackText:SetText(text)
    fallbackText:Show()
    Layout(yOffset + (fallbackText:GetStringHeight() or 14) + 6)
end

local function GetContextOptions(source, classToken, specKey)
    local raw = source.getRaw(classToken, specKey)
    if not raw then return nil end
    local options = {}
    for _, entry in ipairs(raw) do
        table.insert(options, entry.label)
    end
    return options, raw
end

local function FindContextEntry(raw, label)
    for _, entry in ipairs(raw) do
        if entry.label == label then return entry end
    end
    return nil
end

local function RenderSlots(normalizedSlots, yOffset)
    fallbackText:Hide()

    -- Feste Slot-Reihenfolge (CANONICAL_SLOTS), nicht die Reihenfolge aus
    -- den Rohdaten -- die variiert je Quelle und Autor.
    local byKey = {}
    for _, entry in ipairs(normalizedSlots) do
        byKey[entry.key] = entry
    end

    local i = 0
    for _, slotDef in ipairs(CANONICAL_SLOTS) do
        local entry = byKey[slotDef.key]
        if entry and entry.item then
            i = i + 1
            local row = rows[i] or CreateRow(i)

            row.iconButton.itemId = entry.item.itemId
            row.iconButton.sourceName = entry.source
            row.iconButton.texture:SetTexture(134400) -- Fragezeichen-Icon, bis Item geladen ist
            row.slotText:SetText(slotDef.label)

            local nameText, sourceText = row.nameText, row.sourceText
            nameText:SetText(entry.item.name)
            nameText:SetTextColor(1, 1, 1)

            local item = Item:CreateFromItemID(entry.item.itemId)
            item:ContinueOnItemLoad(function()
                row.iconButton.texture:SetTexture(item:GetItemIcon() or 134400)
                nameText:SetText(item:GetItemName() or entry.item.name or ("Item " .. tostring(entry.item.itemId)))

                -- Aktuelle WoW-Versionen können hier statt r, g, b ein
                -- Farbobjekt als ersten Rückgabewert liefern.
                local colorOrR, g, b = item:GetItemQualityColor()

                if type(colorOrR) == "table" then
                    local cr = colorOrR.r
                    local cg = colorOrR.g
                    local cb = colorOrR.b

                    if type(cr) == "number"
                        and type(cg) == "number"
                        and type(cb) == "number"
                    then
                        nameText:SetTextColor(cr, cg, cb)
                    else
                        nameText:SetTextColor(1, 1, 1)
                    end
                elseif type(colorOrR) == "number"
                    and type(g) == "number"
                    and type(b) == "number"
                then
                    nameText:SetTextColor(colorOrR, g, b)
                else
                    nameText:SetTextColor(1, 1, 1)
                end
            end)

            if entry.source then
                sourceText:SetText(entry.source)
                sourceText:Show()
            else
                sourceText:Hide()
            end

            local owned = slotDef.invSlot and GetInventoryItemID("player", slotDef.invSlot) == entry.item.itemId
            row.ownedHighlight:SetShown(owned and true or false)

            if entry.bis then
                nameText:SetText((entry.item.name or "") .. " |cffe6cc80(BiS)|r")
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", bisGearFrame, "TOPLEFT", 0, -(yOffset + (i - 1) * ROW_HEIGHT))
            row:SetPoint("RIGHT", bisGearFrame, "RIGHT", 0, 0)
            row:Show()
        end
    end
    for j = i + 1, #rows do
        rows[j]:Hide()
    end

    Layout(yOffset + i * ROW_HEIGHT)
end

local function Refresh()
    fallbackText:Hide()
    contextDropdown:Hide()

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()

    sourceDropdown:SetText(SOURCE_BY_KEY[selectedSourceKey].label)
    sourceDropdown:SetupMenu(function(_, rootDescription)
        for _, src in ipairs(SOURCES) do
            rootDescription:CreateRadio(src.label,
                function() return selectedSourceKey == src.key end,
                function()
                    selectedSourceKey = src.key
                    selectedContext = nil -- Kontext-Optionen unterscheiden sich je Quelle

                    -- Nur Ansicht wechseln. Die überwachte Sound-Liste
                    -- bleibt unverändert, bis der Nutzer den Haken setzt.
                    Refresh()
                end)
        end
    end)

    local source = SOURCE_BY_KEY[selectedSourceKey]
    local contextOptions, raw = GetContextOptions(source, classToken, specKey)

    if not contextOptions or #contextOptions == 0 then
        ShowFallback("Keine BiS-Gear-Daten für diese Spec verfügbar.", CONTROL_AREA_HEIGHT + DD_GAP)
        return
    end

    local found = false
    for _, c in ipairs(contextOptions) do
        if c == selectedContext then found = true break end
    end
    if not found then selectedContext = contextOptions[1] end

    local yOffset = CONTROL_AREA_HEIGHT + DD_GAP
    if #contextOptions > 1 then
        contextDropdown:SetText(selectedContext)
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, c in ipairs(contextOptions) do
                rootDescription:CreateRadio(c,
                    function() return selectedContext == c end,
                    function()
                        -- Nur sichtbare Unterkategorie wechseln.
                        -- Die aktive Sound-Überwachung wird erst durch den
                        -- Haken "Diese Liste überwachen" geändert.
                        selectedContext = c
                        Refresh()
                    end)
            end
        end)
        contextDropdown:Show()
    end

    local contextEntry = FindContextEntry(raw, selectedContext)
    if not contextEntry then
        ShowFallback("Keine BiS-Gear-Daten für diese Auswahl verfügbar.", yOffset)
        return
    end

    SyncAlertControls()
    RenderSlots(source.normalize(contextEntry.slots), yOffset)
end

G.RegisterTabContent(TAB_KEY, bisGearFrame)
-- KEIN G.SetActiveTab() hier -- der Standard-Tab beim Öffnen wird von
-- Content/Guide.lua gesetzt.

-- Tab war evtl. im Hintergrund und der Guard in ReportContentHeight() hat
-- G.SetPanelContentHeight() deshalb übersprungen -- beim Aktivwerden einmal
-- nachholen, damit die Panel-Höhe wieder zum tatsächlich sichtbaren Inhalt passt.
if G.RegisterOnActiveTabChanged then
    G.RegisterOnActiveTabChanged(function(tabKey)
        if tabKey == TAB_KEY then
            G.SetPanelContentHeight(bisGearFrame:GetHeight())
        end
    end)
end

G.RegisterOnDatabaseReady(function()
    -- Sichtbare Startansicht bleibt bewusst Wowhead -> Overall.
    -- Die überwachte Liste ist davon unabhängig gespeichert.
    selectedSourceKey = "wowhead"
    selectedContext = "Overall"

    SyncAlertControls()
    Refresh()
    RebuildTrackedBisItems()
end)

G.RegisterOnSelectionChanged(function()
    Refresh()
    RebuildTrackedBisItems()
    SyncAlertControls()
end)
