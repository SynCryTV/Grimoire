local ADDON_NAME, G = ...

-- ============================================================================
-- Grimoire - separater Auktionshaus-Enhancements-Browser
--
-- WICHTIG:
-- * Beeinflusst NICHT G.GetSelectedClass/G.GetSelectedSpec.
-- * Beeinflusst NICHT den normalen Enhancements-Tab.
-- * Der normale Tab behält seine Copy-Popup-Funktion.
-- * Nur dieses AH-Fenster sucht beim Klick direkt im Blizzard-Auktionshaus.
-- ============================================================================

local AH = {}
G.AuctionHouseEnhancements = AH

local CLASS_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK",
    "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

local ROW_HEIGHT = 28
local ICON_SIZE = 20
local SECTION_GAP = 7

local selectedClass
local selectedSpec
local sections = {}

local CONSUMABLE_SLOT_NAMES = {
    ["flask"] = true,
    ["combat potion"] = true,
    ["health potion"] = true,
    ["invisibility potion"] = true,
    ["invisiblity potion"] = true,
    ["weapon buff"] = true,
    ["weapon oil"] = true,
    ["augment rune"] = true,
    ["food"] = true,
}

local SLOT_LABELS = {
    helm = "Helm",
    head = "Helm",
    shoulders = "Schultern",
    shoulder = "Schultern",
    chest = "Brust",
    wrist = "Handgelenke",
    bracer = "Handgelenke",
    bracers = "Handgelenke",
    legs = "Beine",
    feet = "Füße",
    boots = "Füße",
    ring = "Ring",
    weapon = "Waffe",
    ["weapon (2h)"] = "Waffe",
    ["weapons (1h)"] = "Waffe",
    ["weapons (2h & dual-wield)"] = "Waffe",
    ["main hand"] = "Waffe",
    ["off hand"] = "Nebenhand",

    flask = "Fläschchen",
    ["combat potion"] = "Kampftrank",
    ["health potion"] = "Heiltrank",
    ["invisibility potion"] = "Unsichtbarkeitstrank",
    ["invisiblity potion"] = "Unsichtbarkeitstrank",
    ["weapon buff"] = "Waffenverstärkung",
    ["weapon oil"] = "Waffenverstärkung",
    ["augment rune"] = "Verstärkungsrune",
    food = "Essen",
}

local FIXED_CONSUMABLES = {
    {
        label = "Vantusrune",
        item = { itemId = 272195, name = "Vantus Rune: Tides" },
    },
    {
        label = "Heiltrank",
        item = { itemId = 271884, name = "Concentrated Silvermoon Health Potion" },
    },
    {
        label = "Unsichtbarkeitstrank",
        item = { itemId = 241303, name = "Void-Shrouded Tincture" },
    },
}

local function NormalizeSlotLabel(slot)
    if not slot then return "" end
    return SLOT_LABELS[slot:lower()] or slot
end

local function NormalizeSlotKey(slot)
    if not slot then return "" end
    local key = slot:lower()
    key = key:gsub("^%s+", ""):gsub("%s+$", "")

    local aliases = {
        ["shoulder"] = "shoulders",
        ["shoulders"] = "shoulders",
        ["boot"] = "feet",
        ["boots"] = "feet",
        ["feet"] = "feet",
        ["helm"] = "head",
        ["head"] = "head",
        ["bracer"] = "wrist",
        ["bracers"] = "wrist",
        ["wrist"] = "wrist",
        ["weapon (2h & dual-wield)"] = "weapon",
        ["weapon (2h)"] = "weapon",
        ["weapons (1h)"] = "weapon",
        ["main hand"] = "weapon",
    }

    return aliases[key] or key
end

local function NormalizeDynamicConsumableLabel(label, key)
    local raw = tostring(label or key or "")
    raw = raw:gsub("^extra_", "")
    raw = raw:gsub("_", " ")
    raw = raw:gsub("%s+%d+$", "")
    raw = raw:gsub("^%s+", ""):gsub("%s+$", "")

    local lower = raw:lower()
    local aliases = {
        ["flask"] = "Fläschchen",
        ["phial"] = "Fläschchen",
        ["combat potion"] = "Kampftrank",
        ["health potion"] = "Heiltrank",
        ["healing potion"] = "Heiltrank",
        ["invisibility potion"] = "Unsichtbarkeitstrank",
        ["invisiblity potion"] = "Unsichtbarkeitstrank",
        ["weapon buff"] = "Waffenverstärkung",
        ["weapon oil"] = "Waffenverstärkung",
        ["augment rune"] = "Verstärkungsrune",
        ["food"] = "Essen",
        ["group feast"] = "Essen",
    }

    if aliases[lower] then
        return aliases[lower]
    end

    if label and label ~= "" and not tostring(label):match("^extra_") then
        return NormalizeSlotLabel(tostring(label):gsub("%s+%d+$", ""))
    end

    if raw == "" then return "Verbrauchsgut" end
    return raw:gsub("^%l", string.upper)
end

local function AddConsumable(out, label, item)
    if not item or not item.itemId then return end
    for _, existing in ipairs(out) do
        if existing.item.itemId == item.itemId then
            return
        end
    end
    out[#out + 1] = { label = label, item = item }
end

local function CollectEnchantEntries(specData)
    local out, seen = {}, {}
    if not specData then return out end

    for _, entry in ipairs(specData.enchants or {}) do
        local rawSlot = entry.slot or ""
        local slotLower = rawSlot:lower()

        if not CONSUMABLE_SLOT_NAMES[slotLower] and entry.best and entry.best.itemId then
            local slotKey = NormalizeSlotKey(rawSlot)
            local uniqueKey = slotKey .. ":" .. tostring(entry.best.itemId)
            if not seen[uniqueKey] then
                seen[uniqueKey] = true
                out[#out + 1] = {
                    label = NormalizeSlotLabel(slotKey),
                    item = entry.best,
                }
            end
        end
    end

    return out
end

local function CollectGemEntries(specData)
    local out = {}
    local gems = specData and specData.gems
    if not gems then return out end

    if gems.primary and gems.primary.itemId then
        out[#out + 1] = { label = "Primär", item = gems.primary }
    end

    for _, gem in ipairs(gems.secondary or {}) do
        if gem.itemId then
            out[#out + 1] = { label = "Sekundär", item = gem }
        end
    end

    return out
end

local function CollectConsumableEntries(specData)
    local out = {}
    if not specData then return out end

    local c = specData.consumables or {}
    local handledKeys = {}

    local function AddFromKey(key, label)
        local item = c[key]
        if item and item.itemId then
            AddConsumable(out, label, item)
            handledKeys[key] = true
        end
    end

    AddFromKey("flask", "Fläschchen")
    AddFromKey("combatPotion", "Kampftrank")
    AddFromKey("healthPotion", "Heiltrank")
    AddFromKey("invisibilityPotion", "Unsichtbarkeitstrank")
    AddFromKey("weaponBuff", "Waffenverstärkung")
    AddFromKey("augmentRune", "Verstärkungsrune")
    AddFromKey("food", "Essen")

    local extraKeys = {}
    for key, item in pairs(c) do
        if not handledKeys[key] and type(item) == "table" and item.itemId then
            extraKeys[#extraKeys + 1] = key
        end
    end
    table.sort(extraKeys)

    for _, key in ipairs(extraKeys) do
        local item = c[key]
        AddConsumable(out, NormalizeDynamicConsumableLabel(item.label, key), item)
    end

    for _, entry in ipairs(specData.enchants or {}) do
        local slotLower = entry.slot and entry.slot:lower()
        if CONSUMABLE_SLOT_NAMES[slotLower] and entry.best and entry.best.itemId then
            AddConsumable(out, NormalizeSlotLabel(entry.slot), entry.best)
        end
    end

    for _, fixed in ipairs(FIXED_CONSUMABLES) do
        AddConsumable(out, fixed.label, fixed.item)
    end

    return out
end

local SECTION_DEFS = {
    { key = "enchants", title = "Verzauberungen", collector = CollectEnchantEntries },
    { key = "gems", title = "Edelsteine", collector = CollectGemEntries },
    { key = "consumables", title = "Verbrauchsgüter", collector = CollectConsumableEntries },
}

-- ============================================================================
-- Blizzard-AH Suche
-- ============================================================================

local function GetAuctionSearchBar()
    if not AuctionHouseFrame then return nil end

    if AuctionHouseFrame.SearchBar then
        return AuctionHouseFrame.SearchBar
    end

    if AuctionHouseFrame.BrowseResultsFrame and AuctionHouseFrame.BrowseResultsFrame.SearchBar then
        return AuctionHouseFrame.BrowseResultsFrame.SearchBar
    end

    if AuctionHouseFrame.BrowseResultsFrame
        and AuctionHouseFrame.BrowseResultsFrame.ItemList
        and AuctionHouseFrame.BrowseResultsFrame.ItemList.SearchBar
    then
        return AuctionHouseFrame.BrowseResultsFrame.ItemList.SearchBar
    end

    return nil
end

local function SetAuctionSearchText(searchBar, text)
    if searchBar.SetSearchText then
        local ok = pcall(searchBar.SetSearchText, searchBar, text)
        if ok then return true end
    end

    local box = searchBar.SearchBox or searchBar.searchBox
    if box and box.SetText then
        box:SetText(text)
        return true
    end

    if searchBar.SetText then
        local ok = pcall(searchBar.SetText, searchBar, text)
        if ok then return true end
    end

    return false
end

local function StartAuctionSearch(searchBar)
    if searchBar.StartSearch then
        local ok = pcall(searchBar.StartSearch, searchBar)
        if ok then return true end
    end

    local button = searchBar.SearchButton or searchBar.searchButton
    if button and button.Click then
        local ok = pcall(button.Click, button)
        if ok then return true end
    end

    return false
end

local function SearchAuctionHouseByName(name)
    if not name or name == "" then return false, "Kein Itemname verfügbar." end
    if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
        return false, "Auktionshaus ist nicht geöffnet."
    end

    local searchBar = GetAuctionSearchBar()
    if not searchBar then
        return false, "AH-Suchfeld wurde nicht gefunden."
    end

    if not SetAuctionSearchText(searchBar, name) then
        return false, "Itemname konnte nicht ins AH-Suchfeld gesetzt werden."
    end

    if StartAuctionSearch(searchBar) then
        return true
    end

    return false, "Name wurde eingesetzt – Suche bitte einmal manuell bestätigen."
end


-- ============================================================================
-- Blizzard-AH Favoriten + Auctionator-Sektionsbuttons
-- ============================================================================

local function CanUseAuctionFavorites()
    return C_AuctionHouse
        and C_AuctionHouse.SetFavoriteItem
        and C_AuctionHouse.MakeItemKey
        and C_AuctionHouse.FavoritesAreAvailable
        and C_AuctionHouse.FavoritesAreAvailable()
end

local function SetFavoriteByItemID(itemID)
    if not itemID or not CanUseAuctionFavorites() then
        return false, "unavailable"
    end

    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    if not itemKey then
        return false, "nokey"
    end

    if C_AuctionHouse.IsFavoriteItem and C_AuctionHouse.IsFavoriteItem(itemKey) then
        return true, "already"
    end

    if C_AuctionHouse.HasMaxFavorites and C_AuctionHouse.HasMaxFavorites() then
        return false, "max"
    end

    local ok = pcall(C_AuctionHouse.SetFavoriteItem, itemKey, true)
    if ok then
        return true, "added"
    end

    return false, "failed"
end


local function IsFavoriteByItemID(itemID)
    if not itemID
        or not C_AuctionHouse
        or not C_AuctionHouse.MakeItemKey
        or not C_AuctionHouse.IsFavoriteItem
    then
        return false
    end

    local itemKey = C_AuctionHouse.MakeItemKey(itemID)
    if not itemKey then
        return false
    end

    local ok, isFavorite = pcall(C_AuctionHouse.IsFavoriteItem, itemKey)
    return ok and isFavorite == true
end

local function AreAllEntriesFavorited(entries)
    if not entries or #entries == 0 then
        return false
    end

    local foundAny = false

    for _, entry in ipairs(entries) do
        local itemID = entry.item and entry.item.itemId

        if itemID then
            foundAny = true

            if not IsFavoriteByItemID(itemID) then
                return false
            end
        end
    end

    return foundAny
end

local function UpdateFavoriteButtonVisual(entry)
    if not entry or not entry.favoriteButton then
        return
    end

    local allFavorited = AreAllEntriesFavorited(entry.currentEntries)

    if entry.favoriteNormal then
        entry.favoriteNormal:SetAtlas(
            allFavorited
                and "auctionhouse-icon-favorite"
                or "auctionhouse-icon-favorite-off",
            false
        )
    end

    if entry.favoriteHighlight then
        entry.favoriteHighlight:SetAtlas("auctionhouse-icon-favorite", false)
        entry.favoriteHighlight:SetAlpha(allFavorited and 0.20 or 0.45)
    end

    entry.favoriteButton.isFullyFavorited = allFavorited
end

local function UpdateAllFavoriteButtonVisuals()
    for _, entry in ipairs(sections) do
        UpdateFavoriteButtonVisual(entry)
    end
end

local function RefreshAuctionHouse()
    if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
        return
    end

    -- Nach dem Setzen der Sterne NICHT die letzte normale Suche erneut
    -- starten. Das würde das AH wieder in die normale Ergebnisliste schicken.
    --
    -- Stattdessen explizit zurück in Blizzards Favoritenansicht:
    --   QueryAll(AllFavorites)
    -- setzt intern isDisplayingFavorites = true,
    -- wechselt auf den Buy/Browse-Modus und lädt die Favoriten neu.
    C_Timer.After(0.22, function()
        if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
            return
        end

        -- Alten Suchtext entfernen, damit optisch ebenfalls klar ist,
        -- dass wieder die Favoritenansicht aktiv ist.
        if AuctionHouseFrame.SetSearchText then
            pcall(AuctionHouseFrame.SetSearchText, AuctionHouseFrame, "")
        else
            local searchBar = GetAuctionSearchBar()
            if searchBar and searchBar.SetSearchText then
                pcall(searchBar.SetSearchText, searchBar, "")
            end
        end

        if AuctionHouseFrame.QueryAll
            and AuctionHouseSearchContext
            and AuctionHouseSearchContext.AllFavorites
        then
            local ok = pcall(
                AuctionHouseFrame.QueryAll,
                AuctionHouseFrame,
                AuctionHouseSearchContext.AllFavorites
            )

            if ok then
                return
            end
        end

        -- Fallback nur für den Fall einer Blizzard-UI-Änderung.
        if AuctionHouseFrame.SetDisplayMode
            and AuctionHouseFrameDisplayMode
            and AuctionHouseFrameDisplayMode.Buy
        then
            pcall(
                AuctionHouseFrame.SetDisplayMode,
                AuctionHouseFrame,
                AuctionHouseFrameDisplayMode.Buy
            )
        end

        if C_AuctionHouse and C_AuctionHouse.SearchForFavorites then
            pcall(C_AuctionHouse.SearchForFavorites, {})
        end
    end)
end

local function FavoriteEntries(entries)
    if not entries or #entries == 0 then
        return 0, 0, 0
    end

    local added, already, failed = 0, 0, 0

    for _, entry in ipairs(entries) do
        local itemID = entry.item and entry.item.itemId
        if itemID then
            local ok, reason = SetFavoriteByItemID(itemID)

            if ok and reason == "added" then
                added = added + 1
            elseif ok and reason == "already" then
                already = already + 1
            elseif reason == "max" then
                failed = failed + 1
                break
            else
                failed = failed + 1
            end
        end
    end

    RefreshAuctionHouse()
    return added, already, failed
end

local function GetSelectedSpecDisplayNameAH()
    local name
    if G.GetSpecInfo and selectedClass and selectedSpec then
        name = G.GetSpecInfo(selectedClass, selectedSpec)
    end
    return name or selectedSpec or "Unbekannt"
end

local function BuildLocalizedAuctionatorItems(entries, callback)
    local itemIDs = {}
    local items = {}
    local seen = {}

    for _, entry in ipairs(entries or {}) do
        local itemID = entry.item and entry.item.itemId
        if itemID then
            itemIDs[#itemIDs + 1] = itemID
        end
    end

    if #itemIDs == 0 then
        callback(items)
        return
    end

    local pending = #itemIDs

    local function OneFinished()
        pending = pending - 1
        if pending <= 0 then
            callback(items)
        end
    end

    for _, itemID in ipairs(itemIDs) do
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local localizedName = item:GetItemName()

            if localizedName and localizedName ~= "" and not seen[localizedName] then
                seen[localizedName] = true
                items[#items + 1] = localizedName
            end

            OneFinished()
        end)
    end
end

local function SendEntriesToAuctionator(sectionTitle, entries, notify)
    if not Auctionator
        or not Auctionator.Shopping
        or not Auctionator.Shopping.ListManager
    then
        if notify then notify("Auctionator ist nicht geladen.") end
        return
    end

    if not entries or #entries == 0 then
        if notify then notify("Keine Items in diesem Abschnitt.") end
        return
    end

    BuildLocalizedAuctionatorItems(entries, function(items)
        if #items == 0 then
            if notify then notify("Itemnamen konnten nicht geladen werden.") end
            return
        end

        local listName =
            "Grimoire - "
            .. GetSelectedSpecDisplayNameAH()
            .. " - "
            .. sectionTitle

        local manager = Auctionator.Shopping.ListManager

        if manager:GetIndexForName(listName) == nil then
            manager:Create(listName)
        end

        local list = manager:GetByName(listName)
        if not list then
            if notify then notify("Auctionator-Liste konnte nicht erstellt werden.") end
            return
        end

        list:ClearItems()
        list:AppendItems(items)

        if notify then
            notify(string.format("%d Items → Auctionator", #items))
        end
    end)
end

-- ============================================================================
-- Eigenes AH-Fenster
-- ============================================================================

local panel = CreateFrame("Frame", "GrimoireAuctionHouseEnhancementsFrame", UIParent, "BackdropTemplate")
panel:SetSize(440, 520)
panel:SetFrameStrata("DIALOG")
panel:SetFrameLevel(500)
panel:SetClampedToScreen(true)
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
panel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
panel:SetBackdropColor(0.035, 0.035, 0.035, 0.98)
panel:SetBackdropBorderColor(0.38, 0.38, 0.38, 1)
panel:Hide()
AH.panel = panel

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 14, -12)
title:SetText("Grimoire – Auktionshaus")

local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
subtitle:SetText("Enhancements aller Klassen • Item anklicken = direkt suchen")

local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", 1, 1)

local classDropdown = CreateFrame("DropdownButton", "GrimoireAHClassDropdown", panel, "WowStyle1DropdownTemplate")
classDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -58)
classDropdown:SetSize(190, 24)

local specDropdown = CreateFrame("DropdownButton", "GrimoireAHSpecDropdown", panel, "WowStyle1DropdownTemplate")
specDropdown:SetPoint("LEFT", classDropdown, "RIGHT", 8, 0)
specDropdown:SetSize(190, 24)

local scrollFrame = CreateFrame("ScrollFrame", "GrimoireAHEnhancementsScrollFrame", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", classDropdown, "BOTTOMLEFT", 0, -12)
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 14)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(382, 1)
scrollFrame:SetScrollChild(content)

local toast = CreateFrame("Frame", nil, panel, "BackdropTemplate")
toast:SetSize(320, 34)
toast:SetPoint("BOTTOM", panel, "BOTTOM", 0, 18)
toast:SetFrameStrata("TOOLTIP")
toast:SetFrameLevel(panel:GetFrameLevel() + 50)
toast:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
toast:SetBackdropColor(0.04, 0.04, 0.04, 0.96)
toast:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.95)
toast:Hide()

local toastText = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
toastText:SetPoint("CENTER")
local toastGeneration = 0

local function ShowToast(message)
    toastGeneration = toastGeneration + 1
    local generation = toastGeneration
    toastText:SetText(message or "")
    toast:Show()
    C_Timer.After(2.0, function()
        if generation == toastGeneration then
            toast:Hide()
        end
    end)
end

local function SetItemQuality(fontString, item)
    local colorOrR, g, b = item:GetItemQualityColor()
    if type(colorOrR) == "table" then
        if type(colorOrR.r) == "number" and type(colorOrR.g) == "number" and type(colorOrR.b) == "number" then
            fontString:SetTextColor(colorOrR.r, colorOrR.g, colorOrR.b)
            return
        end
    elseif type(colorOrR) == "number" and type(g) == "number" and type(b) == "number" then
        fontString:SetTextColor(colorOrR, g, b)
        return
    end
    fontString:SetTextColor(1, 1, 1)
end

local function SearchItem(itemID, fallbackName)
    if not itemID then return end

    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local name = item:GetItemName() or fallbackName
        local ok, message = SearchAuctionHouseByName(name)
        if ok then
            ShowToast("Suche: " .. (name or "Item"))
        else
            ShowToast(message or "AH-Suche fehlgeschlagen.")
        end
    end)
end

local function CreateRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    local iconButton = CreateFrame("Button", nil, row)
    iconButton:SetSize(ICON_SIZE, ICON_SIZE)
    iconButton:SetPoint("LEFT", 4, 0)

    local icon = iconButton:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(134400)
    iconButton.texture = icon

    iconButton:SetScript("OnEnter", function(self)
        if not self.itemId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemId)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", GameTooltip_Hide)

    local slotText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slotText:SetPoint("LEFT", iconButton, "RIGHT", 6, 0)
    slotText:SetWidth(92)
    slotText:SetJustifyH("LEFT")
    slotText:SetWordWrap(false)
    slotText:SetTextColor(0.65, 0.65, 0.65)
    row.slotText = slotText

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", slotText, "RIGHT", 4, 0)
    nameText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local searchButton = CreateFrame("Button", nil, row)
    searchButton:SetPoint("LEFT", iconButton, "RIGHT", 2, 0)
    searchButton:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    searchButton:SetPoint("TOP", row, "TOP")
    searchButton:SetPoint("BOTTOM", row, "BOTTOM")
    searchButton:RegisterForClicks("LeftButtonUp")

    searchButton:SetScript("OnEnter", function(self)
        if not self.itemId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Im Auktionshaus suchen")
        GameTooltip:AddLine("Klicken → Namen einsetzen und Suche starten.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    searchButton:SetScript("OnLeave", GameTooltip_Hide)
    searchButton:SetScript("OnClick", function(self)
        SearchItem(self.itemId, self.fallbackName)
    end)

    row.iconButton = iconButton
    row.searchButton = searchButton
    row:Hide()
    return row
end

local function CreateSection(def)
    local entry = {
        key = def.key,
        title = def.title,
        collector = def.collector,
        rows = {},
        currentEntries = {},
    }

    local header = CreateFrame("Frame", nil, content, "BackdropTemplate")
    header:SetHeight(24)
    header:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    header:SetBackdropColor(0.10, 0.10, 0.10, 0.92)
    header:SetBackdropBorderColor(0.28, 0.28, 0.28, 0.9)

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("LEFT", 8, 0)
    headerText:SetText(def.title)

    -- Blizzard-AH Favoriten: ganze Sektion markieren.
    local favoriteButton = CreateFrame("Button", nil, header)
    favoriteButton:SetSize(18, 18)
    favoriteButton:SetPoint("RIGHT", header, "RIGHT", -5, 0)
    favoriteButton:SetFrameLevel(header:GetFrameLevel() + 5)

    local favoriteNormal = favoriteButton:CreateTexture(nil, "ARTWORK")
    favoriteNormal:SetPoint("CENTER")
    favoriteNormal:SetSize(13, 13)
    favoriteNormal:SetAtlas("auctionhouse-icon-favorite-off", false)

    local favoriteHighlight = favoriteButton:CreateTexture(nil, "HIGHLIGHT")
    favoriteHighlight:SetPoint("CENTER")
    favoriteHighlight:SetSize(13, 13)
    favoriteHighlight:SetAtlas("auctionhouse-icon-favorite", false)
    favoriteHighlight:SetAlpha(0.45)

    favoriteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Als Favoriten markieren")
        GameTooltip:AddLine(
            "Markiert alle Items dieses Abschnitts als Blizzard-AH-Favoriten.",
            0.8, 0.8, 0.8,
            true
        )
        GameTooltip:AddLine(
            "Danach springt das Auktionshaus zurück zu den Favoriten.",
            1.0, 0.82, 0.0,
            true
        )
        GameTooltip:Show()
    end)
    favoriteButton:SetScript("OnLeave", GameTooltip_Hide)

    favoriteButton:SetScript("OnClick", function()
        local added, already, failed = FavoriteEntries(entry.currentEntries)

        if added > 0 then
            ShowToast(string.format("%d Favoriten gesetzt", added))
        elseif already > 0 and failed == 0 then
            ShowToast(string.format("%d bereits favorisiert", already))
        elseif failed > 0 then
            ShowToast("Favoriten konnten nicht vollständig gesetzt werden.")
        end

        -- Blizzard aktualisiert den Favorite-State asynchron.
        C_Timer.After(0.30, function()
            UpdateFavoriteButtonVisual(entry)
        end)
    end)

    -- Auctionator: gleiche Funktion wie im normalen Enhancements-Tab.
    local auctionButton = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
    auctionButton:SetSize(34, 18)
    auctionButton:SetPoint("RIGHT", favoriteButton, "LEFT", -4, 0)
    auctionButton:SetText("AH")
    auctionButton:SetFrameLevel(header:GetFrameLevel() + 5)

    auctionButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Zu Auctionator")
        GameTooltip:AddLine(
            "Erstellt oder aktualisiert die Einkaufsliste für diesen Abschnitt.",
            0.8, 0.8, 0.8,
            true
        )
        GameTooltip:Show()
    end)
    auctionButton:SetScript("OnLeave", GameTooltip_Hide)
    auctionButton:SetScript("OnClick", function()
        SendEntriesToAuctionator(entry.title, entry.currentEntries, ShowToast)
    end)

    entry.favoriteButton = favoriteButton
    entry.favoriteNormal = favoriteNormal
    entry.favoriteHighlight = favoriteHighlight
    entry.auctionButton = auctionButton

    local body = CreateFrame("Frame", nil, content)
    body:SetHeight(1)

    entry.header = header
    entry.body = body
    sections[#sections + 1] = entry
end

for _, def in ipairs(SECTION_DEFS) do
    CreateSection(def)
end

local function GetSelectedSpecData()
    local classData = selectedClass and GrimoireGearData and GrimoireGearData[selectedClass]
    return classData and selectedSpec and classData[selectedSpec]
end

local function RefreshContent()
    local specData = GetSelectedSpecData()
    local y = 0

    for _, entry in ipairs(sections) do
        entry.header:ClearAllPoints()
        entry.header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        entry.header:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        y = y + 26

        local items = entry.collector(specData)
        entry.currentEntries = items

        if entry.favoriteButton then
            entry.favoriteButton:SetEnabled(#items > 0)
            UpdateFavoriteButtonVisual(entry)
        end
        if entry.auctionButton then
            entry.auctionButton:SetEnabled(#items > 0)
        end

        entry.body:ClearAllPoints()
        entry.body:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        entry.body:SetPoint("RIGHT", content, "RIGHT", 0, 0)

        if #items == 0 then
            local row = entry.rows[1] or CreateRow(entry.body)
            entry.rows[1] = row
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", entry.body, "TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", entry.body, "RIGHT", 0, 0)
            row.iconButton.itemId = nil
            row.searchButton.itemId = nil
            row.searchButton.fallbackName = nil
            row.iconButton.texture:SetTexture(134400)
            row.slotText:SetText("")
            row.nameText:SetText("Keine Daten verfügbar.")
            row.nameText:SetTextColor(0.55, 0.55, 0.55)
            row:Show()
            for i = 2, #entry.rows do entry.rows[i]:Hide() end
            entry.body:SetHeight(ROW_HEIGHT)
            y = y + ROW_HEIGHT
        else
            for i, itemEntry in ipairs(items) do
                local row = entry.rows[i] or CreateRow(entry.body)
                entry.rows[i] = row
                local itemID = itemEntry.item.itemId

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", entry.body, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
                row:SetPoint("RIGHT", entry.body, "RIGHT", 0, 0)

                row.iconButton.itemId = itemID
                row.searchButton.itemId = itemID
                row.searchButton.fallbackName = itemEntry.item.name
                row.iconButton.texture:SetTexture(134400)
                row.slotText:SetText(itemEntry.label or "")
                row.nameText:SetText(itemEntry.item.name or ("Item " .. tostring(itemID)))
                row.nameText:SetTextColor(1, 1, 1)
                row:Show()

                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    if row.iconButton.itemId ~= itemID then return end
                    row.iconButton.texture:SetTexture(item:GetItemIcon() or 134400)
                    local localizedName = item:GetItemName() or itemEntry.item.name or ("Item " .. tostring(itemID))
                    row.nameText:SetText(localizedName)
                    row.searchButton.fallbackName = localizedName
                    SetItemQuality(row.nameText, item)
                end)
            end

            for i = #items + 1, #entry.rows do
                entry.rows[i]:Hide()
            end

            entry.body:SetHeight(#items * ROW_HEIGHT)
            y = y + (#items * ROW_HEIGHT)
        end

        y = y + SECTION_GAP
    end

    content:SetHeight(math.max(1, y))
end

local function EnsureSelection()
    if not selectedClass then
        local _, ownClass = UnitClass("player")
        selectedClass = ownClass
    end

    local specs = G.SPEC_KEYS and G.SPEC_KEYS[selectedClass] or {}
    local valid = false
    for _, specKey in ipairs(specs) do
        if specKey == selectedSpec then
            valid = true
            break
        end
    end

    if not valid then
        local ownSpec = G.GetOwnSpecKey and G.GetOwnSpecKey()
        for _, specKey in ipairs(specs) do
            if specKey == ownSpec then
                selectedSpec = ownSpec
                valid = true
                break
            end
        end
    end

    if not valid then
        selectedSpec = specs[1]
    end
end

local function RefreshDropdowns()
    EnsureSelection()

    local className = G.GetClassDisplayName and G.GetClassDisplayName(selectedClass) or selectedClass or "Klasse"
    local classMarkup = G.GetClassIconMarkup and G.GetClassIconMarkup(selectedClass, 16) or ""
    classDropdown:SetText(classMarkup .. className)

    local specName, specIcon
    if G.GetSpecInfo and selectedClass and selectedSpec then
        specName, specIcon = G.GetSpecInfo(selectedClass, selectedSpec)
    end
    local specMarkup = G.GetSpecIconMarkup and G.GetSpecIconMarkup(specIcon, 16) or ""
    specDropdown:SetText(specMarkup .. (specName or selectedSpec or "Spec"))

    classDropdown:SetupMenu(function(_, rootDescription)
        for _, classToken in ipairs(CLASS_ORDER) do
            rootDescription:CreateRadio(
                (G.GetClassIconMarkup and G.GetClassIconMarkup(classToken, 16) or "")
                    .. (G.GetClassDisplayName and G.GetClassDisplayName(classToken) or classToken),
                function() return selectedClass == classToken end,
                function()
                    selectedClass = classToken
                    local specs = G.SPEC_KEYS and G.SPEC_KEYS[classToken] or {}
                    selectedSpec = specs[1]
                    RefreshDropdowns()
                    RefreshContent()
                end
            )
        end
    end)

    specDropdown:SetupMenu(function(_, rootDescription)
        local specs = G.SPEC_KEYS and G.SPEC_KEYS[selectedClass] or {}
        for _, specKey in ipairs(specs) do
            local name, icon = G.GetSpecInfo and G.GetSpecInfo(selectedClass, specKey)
            rootDescription:CreateRadio(
                (G.GetSpecIconMarkup and G.GetSpecIconMarkup(icon, 16) or "") .. (name or specKey),
                function() return selectedSpec == specKey end,
                function()
                    selectedSpec = specKey
                    RefreshDropdowns()
                    RefreshContent()
                end
            )
        end
    end)
end

local function PositionPanel()
    panel:ClearAllPoints()
    if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
        panel:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 6, 0)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

function AH.Open()
    EnsureSelection()
    RefreshDropdowns()
    RefreshContent()
    PositionPanel()
    panel:Show()

    -- Beim Öffnen den echten Blizzard-Favoritenstatus erneut prüfen.
    C_Timer.After(0.20, UpdateAllFavoriteButtonVisuals)
end

function AH.Close()
    panel:Hide()
end

function AH.Toggle()
    if panel:IsShown() then
        AH.Close()
    else
        AH.Open()
    end
end

-- ============================================================================
-- G-Button direkt am Blizzard-Auktionshaus
-- ============================================================================

local ahToggleButton

local function CreateAuctionHouseButton()
    if ahToggleButton or not AuctionHouseFrame then return end

    ahToggleButton = CreateFrame(
        "Button",
        "GrimoireAuctionHouseToggleButton",
        AuctionHouseFrame,
        "UIPanelButtonTemplate"
    )
    ahToggleButton:SetSize(24, 24)
    ahToggleButton:SetPoint("TOPRIGHT", AuctionHouseFrame, "TOPRIGHT", -34, -6)
    ahToggleButton:SetText("G")
    ahToggleButton:SetFrameLevel(AuctionHouseFrame:GetFrameLevel() + 20)

    ahToggleButton:SetScript("OnClick", AH.Toggle)
    ahToggleButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Grimoire – Enhancements")
        GameTooltip:AddLine("Alle Klassen/Specs fürs Auktionshaus anzeigen.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Item anklicken → direkt im AH suchen.", 1.0, 0.82, 0.0, true)
        GameTooltip:Show()
    end)
    ahToggleButton:SetScript("OnLeave", GameTooltip_Hide)

    AuctionHouseFrame:HookScript("OnHide", function()
        panel:Hide()
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_AuctionHouseUI" then
            C_Timer.After(0, CreateAuctionHouseButton)
        end
        return
    end

    if event == "AUCTION_HOUSE_SHOW" then
        C_Timer.After(0.05, function()
            CreateAuctionHouseButton()
            if panel:IsShown() then
                PositionPanel()
                RefreshContent()
            end
        end)

        C_Timer.After(0.30, function()
            if panel:IsShown() then
                UpdateAllFavoriteButtonVisuals()
            end
        end)
    end
end)

if AuctionHouseFrame then
    CreateAuctionHouseButton()
end
