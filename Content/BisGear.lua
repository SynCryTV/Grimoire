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

-- KeystoneLoot liefert Item-IDs ohne ausgeschriebenen Inventarslot. Der
-- WoW-Client kennt den Slot aber direkt über die Item-Metadaten.
local KEYSTONE_EQUIPLOC_TO_KEY = {
    INVTYPE_HEAD = "head", INVTYPE_NECK = "neck", INVTYPE_SHOULDER = "shoulder",
    INVTYPE_CLOAK = "back", INVTYPE_CHEST = "chest", INVTYPE_ROBE = "chest",
    INVTYPE_WRIST = "wrist", INVTYPE_HAND = "hands", INVTYPE_WAIST = "waist",
    INVTYPE_LEGS = "legs", INVTYPE_FEET = "feet",
    INVTYPE_2HWEAPON = "mainhand", INVTYPE_WEAPONMAINHAND = "mainhand",
    INVTYPE_HOLDABLE = "offhand", INVTYPE_SHIELD = "offhand", INVTYPE_WEAPONOFFHAND = "offhand",
    INVTYPE_RANGED = "mainhand", INVTYPE_RANGEDRIGHT = "mainhand", INVTYPE_THROWN = "mainhand",
}

-- Die Import-API liefert die ausgerüsteten Kern-Slots in dieser festen
-- Reihenfolge. Das ist zuverlässiger als die Item-Eigenschaft bei Waffen,
-- denn einige Einhandwaffen melden dort beide als Mainhand.
local KEYSTONE_SLOT_ORDER = {
    "head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist",
    "legs", "feet", "ring1", "ring2", "trinket1", "trinket2", "mainhand", "offhand",
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
-- dann Murlok (Mythic+), dann Icy Veins.
-- ============================================================
local function FindReferenceItemSource(classToken, specKey, itemID)
    -- Die Murlok- und KeystoneLoot-Importe enthalten keine Fundorte. Bereits
    -- geladene Guide-Daten kennen sie jedoch für viele derselben Item-IDs.
    -- Das ist ein reiner Tabellenabgleich, ohne UI-/Abenteuerführer-Aufruf.
    local function FindInSpecData(specData)
        for _, context in ipairs(specData and specData.bisGear or {}) do
            for _, slot in ipairs(context.slots or {}) do
                local item = slot.item
                if item and item.itemId == itemID and slot.source and slot.source ~= "" then
                    return slot.source
                end
            end
        end
        return nil
    end

    for _, dataRoot in ipairs({ GrimoireGearData, GrimoireIcyVeinsData }) do
        local source = FindInSpecData(dataRoot and dataRoot[classToken] and dataRoot[classToken][specKey])
        if source then return source end
    end

    -- Einige Gegenst\u00e4nde stehen nur in der Empfehlung einer anderen Spec.
    -- Der Fundort selbst ist aber identisch, deshalb ist das ein sinnvoller
    -- zweiter, weiterhin rein statischer Abgleich.
    for _, dataRoot in ipairs({ GrimoireGearData, GrimoireIcyVeinsData }) do
        for _, classData in pairs(dataRoot or {}) do
            for _, specData in pairs(classData) do
                local source = FindInSpecData(specData)
                if source then return source end
            end
        end
    end
    return nil
end

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
        key = "murlok", label = "Murlok (Mythic+)",
        getRaw = function(classToken, specKey)
            local d = GrimoireMurlokGearData and GrimoireMurlokGearData[classToken] and GrimoireMurlokGearData[classToken][specKey]
            -- Die BiS-Ansicht arbeitet bei jeder Quelle mit Kontextlisten.
            -- Murlok liefert genau einen Kontext, also hier in dieselbe
            -- gemeinsame Form einpacken statt eine nackte Slotliste
            -- zurückzugeben.
            return d and d.bisGear and {
                { label = "Mythic+", slots = d.bisGear },
            }
        end,
        normalize = function(rawSlots, classToken, specKey)
            local counters, out = {}, {}
            for _, s in ipairs(rawSlots) do
                local key = ResolveSlotKey(s.slot, counters)
                if key then
                    table.insert(out, {
                        key = key,
                        item = s.item,
                        source = FindReferenceItemSource(classToken, specKey, s.item and s.item.itemId) or s.source,
                        provider = "Murlok",
                    })
                end
            end
            return out
        end,
    },
    {
        key = "keystoneloot", label = "KeystoneLoot",
        getRaw = function(classToken, specKey)
            local d = GrimoireKeystoneLootData and GrimoireKeystoneLootData[classToken] and GrimoireKeystoneLootData[classToken][specKey]
            return d and d.lists
        end,
        normalize = function(rawEntries, classToken, specKey)
            local counters, out = {}, {}
            for index, entry in ipairs(rawEntries or {}) do
                local itemID = entry.itemId
                local equipLoc = itemID and select(4, GetItemInfoInstant(itemID))
                local key = KEYSTONE_SLOT_ORDER[index]
                if not key then key = equipLoc and KEYSTONE_EQUIPLOC_TO_KEY[equipLoc] end
                if not KEYSTONE_SLOT_ORDER[index] and equipLoc == "INVTYPE_FINGER" then
                    counters.ring = (counters.ring or 0) + 1
                    key = counters.ring == 1 and "ring1" or "ring2"
                elseif not KEYSTONE_SLOT_ORDER[index] and equipLoc == "INVTYPE_TRINKET" then
                    counters.trinket = (counters.trinket or 0) + 1
                    key = counters.trinket == 1 and "trinket1" or "trinket2"
                elseif not KEYSTONE_SLOT_ORDER[index] and equipLoc == "INVTYPE_WEAPON" then
                    -- Zwei generische Einhandwaffen (z.B. Dämonenjäger)
                    -- haben dieselbe EquipLoc. Die zweite darf die erste
                    -- daher nicht als Mainhand überschreiben.
                    counters.weapon = (counters.weapon or 0) + 1
                    key = counters.weapon == 1 and "mainhand" or "offhand"
                end
                -- Selbst wenn ein neuer/einmaliger EquipLoc-Typ noch nicht
                -- bekannt ist, darf der API-Eintrag nicht verschwinden.
                key = key or ("additional-" .. tostring(index))
                if itemID then
                    table.insert(out, {
                        key = key,
                        item = { itemId = itemID, name = "Item " .. tostring(itemID) },
                        source = FindReferenceItemSource(classToken, specKey, itemID) or "KeystoneLoot",
                        provider = "KeystoneLoot",
                        tier = entry.tier,
                        gems = entry.gems,
                        enchant = entry.enchant,
                        socketCount = entry.gems and #entry.gems or 0,
                    })
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

    navToastText:SetText(G.L(message or ""))
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
        ShowNavToast(G.L("Für dieses Item fehlt die Item-ID."))
        return
    end

    local normalized = NormalizeSourceName(sourceName)
    if normalized:find("craft", 1, true)
        or normalized:find("herstellung", 1, true)
        or normalized:find("crafted", 1, true)
    then
        ShowNavToast(G.L("Quelle: Herstellung"))
        return
    end

    if sourceName and TrySetSourceWaypoint(sourceName) then
        ShowNavToast(G.L("Kartenmarker gesetzt: " .. sourceName))
        return
    end

    ShowNavToast(G.L("Quelle wird gesucht …"))

    -- Weg 1: Item-ID -> lokaler deutscher Itemname -> EJ-Lootsuche.
    FindEncounterJournalSourceByItemID(itemID, function(result)
        if result and OpenEncounterJournalResult(result, itemID) then
            if result.encounterID then
                ShowNavToast(G.L(
                    "Beute geöffnet: "
                    .. (result.encounterName or result.instanceName or "Boss")
                ))
            else
                ShowNavToast(G.L(
                    "Beute geöffnet: "
                    .. (result.instanceName or "Dungeon/Raid")
                ))
            end
            return
        end

        -- Weg 2: einzelne neue/noch nicht sauber indexierte Items.
        -- Dann über die Quelle zur Instanz navigieren.
        FindInstanceByLocalizedSource(sourceName, function(sourceResult)
            if sourceResult and OpenEncounterJournalResult(sourceResult, itemID) then
                ShowNavToast(G.L(
                    "Instanz/Beute geöffnet: "
                    .. (sourceResult.instanceName or sourceName or "Dungeon/Raid")
                ))
                return
            end

            if sourceName and sourceName ~= "" then
                ShowNavToast(G.L("Keine automatische Navigation: " .. sourceName))
            else
                ShowNavToast(G.L("Keine Dungeon-/Raidquelle gefunden."))
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
alertLabel:SetText(G.L("Diese Liste überwachen"))

-- Kleine Hilfe direkt neben der Einstellung.
local alertHelp = CreateFrame("Frame", nil, bisGearFrame)
alertHelp:SetSize(16, 16)
alertHelp:SetPoint("LEFT", alertLabel, "RIGHT", 5, 0)
alertHelp:EnableMouse(true)

local alertHelpText = alertHelp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
alertHelpText:SetPoint("CENTER", 0, 0)
alertHelpText:SetText(G.L("?"))
alertHelpText:SetTextColor(0.72, 0.72, 0.72)

alertHelp:SetScript("OnEnter", function(self)
    alertHelpText:SetTextColor(1.0, 0.82, 0.0)

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(G.L("BiS-Drop-Warnung"))
    GameTooltip:AddLine(G.L(" "))
    GameTooltip:AddLine(G.L(
        "Überwacht genau die aktuell ausgewählte BiS-Liste und Unterkategorie."),
        1, 1, 1,
        true
    )
    GameTooltip:AddLine(G.L(" "))
    GameTooltip:AddLine(G.L(
        "Es kann immer nur eine BiS-Liste gleichzeitig überwacht werden."),
        0.82, 0.82, 0.82,
        true
    )
    GameTooltip:AddLine(G.L(
        "Aktivierst du den Haken bei einer anderen Liste, wird die vorherige automatisch deaktiviert."),
        0.82, 0.82, 0.82,
        true
    )
    GameTooltip:AddLine(G.L(" "))
    GameTooltip:AddLine(G.L(
        "Eigene Drops: Sound, wenn du selbst eines deiner BiS-Items erhältst."),
        0.45, 0.85, 1.0,
        true
    )
    GameTooltip:AddLine(G.L(
        "Drops anderer: Sound, wenn ein Gruppen- oder Raidmitglied eines deiner BiS-Items erhält."),
        0.45, 0.85, 1.0,
        true
    )
    GameTooltip:AddLine(G.L(" "))
    GameTooltip:AddLine(G.L(
        "Den Warnton kannst du im Dropdown auswählen und direkt vorhören."),
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
ownDropLabel:SetText(G.L("Eigene Drops"))

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
othersDropLabel:SetText(G.L("Drops anderer"))

local rows = {}

local fallbackText = bisGearFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

local selectedSourceKey = SOURCES[1].key -- Wowhead ist Standard
local selectedContext = "Overall"

local function SaveBisGearView()
    if not G.db then return end
    G.db.bisGearView = G.db.bisGearView or {}
    G.db.bisGearView.sourceKey = selectedSourceKey
    G.db.bisGearView.context = selectedContext
end

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

    local normalized = source.normalize(contextEntry.slots, classToken, specKey)
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
    soundDropdown:SetText(G.L(soundDef and soundDef.label or "Epische Beute"))

    soundDropdown:SetupMenu(function(_, rootDescription)
        for _, def in ipairs(BIS_ALERT_SOUNDS) do
            local kit = def.getKit and def.getKit()
            if kit then
                rootDescription:CreateRadio(
                    G.L(def.label),
                    function()
                        return (G.db.bisDropAlert.sound or "pvpqueue") == def.key
                    end,
                    function()
                        G.db.bisDropAlert.sound = def.key
                        soundDropdown:SetText(G.L(def.label))

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
        -- Ein vorheriger Haken bei Wowhead/Murlok/Icy verschwindet damit
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
            GameTooltip:AddLine(G.L(" "))
            GameTooltip:AddLine(G.L("Linksklick: Quelle anzeigen"), 1.0, 0.82, 0.0)
            GameTooltip:AddLine(G.L("Rechtsklick: Anprobe"), 0.65, 0.65, 0.65)
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
    nameText:SetPoint("RIGHT", row, "CENTER", -6, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    -- Statisch breit verankerte Variante für Listen ohne Alternativen.
    -- Kein ClearAllPoints/SetPoint während des Renderns: Das vermeidet
    -- Änderungen an WoWs Ankergraph beim Öffnen des Panels.
    local wideNameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wideNameText:SetPoint("TOPLEFT", slotText, "TOPRIGHT", 4, 0)
    wideNameText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    wideNameText:SetJustifyH("LEFT")
    wideNameText:SetWordWrap(false)
    wideNameText:Hide()
    row.wideNameText = wideNameText

    local alternativeText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    alternativeText:SetPoint("TOPLEFT", row, "TOP", 4, -1)
    alternativeText:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    alternativeText:SetJustifyH("LEFT")
    alternativeText:SetWordWrap(false)
    alternativeText:Hide()
    row.alternativeText = alternativeText
    row.alternativeButtons = {}

    local sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sourceText:SetPoint("TOPLEFT", slotText, "BOTTOMLEFT", 0, -2)
    sourceText:SetPoint("RIGHT", row, "CENTER", -6, 0)
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
    fallbackText:SetText(G.L(text))
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

local function HasKeystoneAlternatives(normalizedSlots)
    local slotCounts = {}
    for _, entry in ipairs(normalizedSlots or {}) do
        if entry.key and SLOT_INFO[entry.key] then
            slotCounts[entry.key] = (slotCounts[entry.key] or 0) + 1
            if slotCounts[entry.key] > 1 then
                return true
            end
        end
    end
    return false
end

local function ApplyBisPanelWidth(needsAlternativeLayout)
    if not G.panel then return end

    -- Der Daten-Refresh läuft auch im Hintergrund beim Addon-Start. Nur der
    -- tatsächlich sichtbare BiS-Tab darf die Panel-Breite verändern.
    if not G.GetActiveTab or G.GetActiveTab() ~= TAB_KEY then
        if G.ApplyPanelWidth then
            G.ApplyPanelWidth()
        else
            G.panel:SetWidth(G.PANEL_WIDTH_DEFAULT)
        end
        return
    end

    if needsAlternativeLayout then
        if G.SoftWidth and G.panel:IsShown() then
            G.SoftWidth(G.panel, 500, 0.28)
        else
            G.panel:SetWidth(500)
        end
    elseif G.ApplyPanelWidth then
        G.ApplyPanelWidth(true)
    else
        if G.SoftWidth and G.panel:IsShown() then
            G.SoftWidth(G.panel, G.PANEL_WIDTH_DEFAULT, 0.24)
        else
            G.panel:SetWidth(G.PANEL_WIDTH_DEFAULT)
        end
    end
end

local function RenderSlots(normalizedSlots, yOffset)
    fallbackText:Hide()

    -- Feste Slot-Reihenfolge, aber keine Einträge verwerfen: KeystoneLoot
    -- kann mehrere sinnvolle Alternativen für denselben Slot liefern.
    local byKey = {}
    for _, entry in ipairs(normalizedSlots) do
        byKey[entry.key] = byKey[entry.key] or {}
        table.insert(byKey[entry.key], entry)
    end

    local ordered = {}
    for _, slotDef in ipairs(CANONICAL_SLOTS) do
        local choices = byKey[slotDef.key] or {}
        if choices[1] then
            local alternatives = {}
            for index = 2, #choices do
                alternatives[#alternatives + 1] = choices[index]
            end
            table.insert(ordered, {
                entry = choices[1],
                slotDef = slotDef,
                label = slotDef.label,
                alternatives = alternatives,
            })
        end
    end
    for _, entry in ipairs(normalizedSlots) do
        if not SLOT_INFO[entry.key] then
            table.insert(ordered, {
                entry = entry,
                slotDef = {},
                label = "Weitere Empfehlung",
            })
        end
    end

    local i = 0
    for _, display in ipairs(ordered) do
        local entry, slotDef = display.entry, display.slotDef
        if entry and entry.item then
            i = i + 1
            local row = rows[i] or CreateRow(i)

            row.iconButton.itemId = entry.item.itemId
            row.iconButton.sourceName = entry.source
            row.iconButton.texture:SetTexture(134400) -- Fragezeichen-Icon, bis Item geladen ist
            row.slotText:SetText(G.L(display.label))
            row.alternativeText:Hide()
            row.alternativeText:SetText(G.L(""))
            row.alternativeText:ClearAllPoints()
            row.alternativeText:SetPoint("TOPLEFT", row, "TOP", 4, -1)
            row.alternativeText:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            for _, button in ipairs(row.alternativeButtons) do
                button:Hide()
            end

            local alternatives = display.alternatives or {}
            if #alternatives > 0 then
                local alternativeKey = table.concat((function()
                    local ids = {}
                    for _, alternative in ipairs(alternatives) do
                        ids[#ids + 1] = tostring(alternative.item.itemId)
                    end
                    return ids
                end)(), ",")
                row.alternativeKey = alternativeKey
                local names, pending = {}, #alternatives
                for index, alternative in ipairs(alternatives) do
                    local alternativeID = alternative.item.itemId
                    local alternativeButton = row.alternativeButtons[index]
                    if not alternativeButton then
                        alternativeButton = CreateFrame("Button", nil, row)
                        alternativeButton:SetSize(20, 20)
                        local texture = alternativeButton:CreateTexture(nil, "ARTWORK")
                        texture:SetAllPoints()
                        alternativeButton.texture = texture
                        alternativeButton:SetScript("OnEnter", function(self)
                            if not self.itemId then return end
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetItemByID(self.itemId)
                            GameTooltip:AddLine(G.L(" "))
                            GameTooltip:AddLine(G.L("KeystoneLoot-Alternative"), 0.55, 0.75, 1.0)
                            GameTooltip:Show()
                        end)
                        alternativeButton:SetScript("OnLeave", GameTooltip_Hide)
                        row.alternativeButtons[index] = alternativeButton
                    end
                    alternativeButton:ClearAllPoints()
                    alternativeButton:SetPoint("TOPLEFT", row, "TOP", 4 + ((index - 1) * 23), -1)
                    alternativeButton.itemId = alternativeID
                    alternativeButton.texture:SetTexture(134400)
                    alternativeButton:Show()
                    local alternativeItem = Item:CreateFromItemID(alternativeID)
                    alternativeItem:ContinueOnItemLoad(function()
                        if row.alternativeKey ~= alternativeKey then return end
                        names[index] = alternativeItem:GetItemName() or alternative.item.name or ("Item " .. tostring(alternativeID))
                        alternativeButton.texture:SetTexture(alternativeItem:GetItemIcon() or 134400)
                        pending = pending - 1
                        if pending == 0 and row.alternativeKey == alternativeKey then
                            local lastButton = row.alternativeButtons[#alternatives]
                            row.alternativeText:ClearAllPoints()
                            row.alternativeText:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 4, 0)
                            row.alternativeText:SetPoint("RIGHT", row, "RIGHT", -2, 0)
                            row.alternativeText:SetText(G.L("Alternativen: " .. table.concat(names, " • ")))
                            row.alternativeText:Show()
                        end
                    end)
                end
            else
                row.alternativeKey = nil
            end

            local nameText, wideNameText, sourceText = row.nameText, row.wideNameText, row.sourceText
            local hasAlternatives = #alternatives > 0
            nameText:SetShown(hasAlternatives)
            wideNameText:SetShown(not hasAlternatives)
            nameText:SetText(G.L(entry.item.name))
            wideNameText:SetText(G.L(entry.item.name))
            nameText:SetTextColor(1, 1, 1)
            wideNameText:SetTextColor(1, 1, 1)

            local item = Item:CreateFromItemID(entry.item.itemId)
            item:ContinueOnItemLoad(function()
                row.iconButton.texture:SetTexture(item:GetItemIcon() or 134400)
                local itemName = item:GetItemName() or entry.item.name or ("Item " .. tostring(entry.item.itemId))
                nameText:SetText(G.L(itemName))
                wideNameText:SetText(G.L(itemName))

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
                        wideNameText:SetTextColor(cr, cg, cb)
                    else
                        nameText:SetTextColor(1, 1, 1)
                        wideNameText:SetTextColor(1, 1, 1)
                    end
                elseif type(colorOrR) == "number"
                    and type(g) == "number"
                    and type(b) == "number"
                then
                    nameText:SetTextColor(colorOrR, g, b)
                    wideNameText:SetTextColor(colorOrR, g, b)
                else
                    nameText:SetTextColor(1, 1, 1)
                    wideNameText:SetTextColor(1, 1, 1)
                end
            end)

            if entry.source then
                -- Ein echter Fundort ist aussagekräftiger als der Importer.
                -- Die Quellenbezeichnung bleibt nur als transparenter Fallback.
                local sourceLabel = entry.source
                if entry.provider == "KeystoneLoot" or entry.source == "KeystoneLoot" then
                    local notes = {}
                    if entry.socketCount and entry.socketCount > 0 then
                        table.insert(notes, entry.socketCount == 1 and "Sockel" or (entry.socketCount .. " Sockel"))
                    end
                    if entry.enchant and entry.enchant > 0 then
                        table.insert(notes, "VZ")
                    end
                    if #notes > 0 then sourceLabel = sourceLabel .. " • " .. table.concat(notes, ", ") end
                end
                sourceText:SetText(G.L(sourceLabel))
                sourceText:Show()
            else
                sourceText:Hide()
            end

            local owned = slotDef.invSlot and GetInventoryItemID("player", slotDef.invSlot) == entry.item.itemId
            row.ownedHighlight:SetShown(owned and true or false)

            if entry.bis then
                local bisName = (entry.item.name or "") .. " |cffe6cc80(BiS)|r"
                nameText:SetText(G.L(bisName))
                wideNameText:SetText(G.L(bisName))
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
    ApplyBisPanelWidth(false)

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()

    sourceDropdown:SetText(G.L(SOURCE_BY_KEY[selectedSourceKey].label))
    sourceDropdown:SetupMenu(function(_, rootDescription)
        for _, src in ipairs(SOURCES) do
            rootDescription:CreateRadio(G.L(src.label),
                function() return selectedSourceKey == src.key end,
                function()
                    selectedSourceKey = src.key
                    selectedContext = nil -- Kontext-Optionen unterscheiden sich je Quelle
                    SaveBisGearView()

                    -- Nur Ansicht wechseln. Die überwachte Sound-Liste
                    -- bleibt unverändert, bis der Nutzer den Haken setzt.
                    Refresh()
                end)
        end
    end)

    local source = SOURCE_BY_KEY[selectedSourceKey]
    local contextOptions, raw = GetContextOptions(source, classToken, specKey)

    if not contextOptions or #contextOptions == 0 then
        ShowFallback(G.L("Keine BiS-Gear-Daten für diese Spec verfügbar."), CONTROL_AREA_HEIGHT + DD_GAP)
        return
    end

    local found = false
    for _, c in ipairs(contextOptions) do
        if c == selectedContext then found = true break end
    end
    if not found then selectedContext = contextOptions[1] end
    SaveBisGearView()

    local yOffset = CONTROL_AREA_HEIGHT + DD_GAP
    if #contextOptions > 1 then
        contextDropdown:SetText(G.L(selectedContext))
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, c in ipairs(contextOptions) do
                rootDescription:CreateRadio(G.L(c),
                    function() return selectedContext == c end,
                    function()
                        -- Nur sichtbare Unterkategorie wechseln.
                        -- Die aktive Sound-Überwachung wird erst durch den
                        -- Haken "Diese Liste überwachen" geändert.
                        selectedContext = c
                        SaveBisGearView()
                        Refresh()
                    end)
            end
        end)
        contextDropdown:Show()
    end

    local contextEntry = FindContextEntry(raw, selectedContext)
    if not contextEntry then
        ShowFallback(G.L("Keine BiS-Gear-Daten für diese Auswahl verfügbar."), yOffset)
        return
    end

    local normalizedSlots = source.normalize(contextEntry.slots, classToken, specKey)
    -- Nur KeystoneLoot mit tatsächlich vorhandenen Slot-Alternativen braucht
    -- die breite Darstellung. Alle anderen Ansichten bleiben kompakt.
    ApplyBisPanelWidth(
        selectedSourceKey == "keystoneloot"
        and HasKeystoneAlternatives(normalizedSlots)
    )

    SyncAlertControls()
    RenderSlots(normalizedSlots, yOffset)
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
            Refresh()
        elseif G.ApplyPanelWidth then
            G.ApplyPanelWidth(true)
        end
    end)
end

G.RegisterOnDatabaseReady(function()
    local view = G.db and G.db.bisGearView or {}
    selectedSourceKey = SOURCE_BY_KEY[view.sourceKey] and view.sourceKey or "wowhead"
    selectedContext = view.context or "Overall"

    SyncAlertControls()
    Refresh()
    RebuildTrackedBisItems()
end)

G.RegisterOnSelectionChanged(function()
    Refresh()
    RebuildTrackedBisItems()
    SyncAlertControls()
end)
