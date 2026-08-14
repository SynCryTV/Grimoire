local ADDON_NAME, G = ...

local TAB_KEY = "enhancements"

local frame = CreateFrame("Frame", "GrimoireEnhancementsTab", G.panel)
frame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
frame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)

-- ============================================================
-- Soft Toast / In-Panel-Bestätigung
-- ============================================================

local toast = CreateFrame("Frame", nil, G.panel, "BackdropTemplate")
toast:SetSize(250, 34)
toast:SetPoint("BOTTOM", G.panel, "BOTTOM", 0, 18)
toast:SetFrameStrata("DIALOG")
toast:SetFrameLevel(G.panel:GetFrameLevel() + 30)
toast:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
toast:SetBackdropColor(0.04, 0.04, 0.04, 0.94)
toast:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.95)
toast:SetAlpha(0)
toast:Hide()

local toastIcon = toast:CreateTexture(nil, "ARTWORK")
toastIcon:SetSize(16, 16)
toastIcon:SetPoint("LEFT", toast, "LEFT", 9, 0)
toastIcon:SetAtlas("common-icon-checkmark", false)

local toastText = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
toastText:SetPoint("LEFT", toastIcon, "RIGHT", 7, 0)
toastText:SetPoint("RIGHT", toast, "RIGHT", -10, 0)
toastText:SetJustifyH("LEFT")
toastText:SetWordWrap(false)

local toastGeneration = 0

local function ShowToast(message, kind)
    toastGeneration = toastGeneration + 1
    local generation = toastGeneration

    toastText:SetText(message or "")

    if kind == "warning" then
        toastIcon:SetAtlas("common-icon-redx", false)
    else
        toastIcon:SetAtlas("common-icon-checkmark", false)
    end

    toast:SetAlpha(0)
    toast:Show()

    if G.SoftAlpha then
        G.SoftAlpha(toast, 1, 0.16)
    else
        toast:SetAlpha(1)
    end

    C_Timer.After(2.1, function()
        if generation ~= toastGeneration then return end

        if G.SoftHide then
            G.SoftHide(toast, 0.22)
        elseif G.SoftAlpha then
            G.SoftAlpha(toast, 0, 0.22, function()
                if generation == toastGeneration then
                    toast:Hide()
                    toast:SetAlpha(1)
                end
            end)
        else
            toast:Hide()
        end
    end)
end

local SECTION_GAP = 6
local ROW_HEIGHT = 28
local ICON_SIZE = 20

local CONSUMABLE_SLOT_NAMES = {
    ["flask"] = true,
    ["combat potion"] = true,
    ["health potion"] = true,
    ["weapon buff"] = true,
    ["augment rune"] = true,
    ["food"] = true,
}

local SLOT_LABELS = {
    helm = "Helm",
    head = "Helm",
    shoulders = "Schultern",
    shoulder = "Schultern",
    chest = "Brust",
    legs = "Beine",
    feet = "Füße",
    boots = "Füße",
    ring = "Ring",
    weapon = "Waffe",
    ["main hand"] = "Waffe",
    ["off hand"] = "Nebenhand",

    flask = "Fläschchen",
    ["combat potion"] = "Kampftrank",
    ["health potion"] = "Heiltrank",
    ["weapon buff"] = "Waffenverstärkung",
    ["augment rune"] = "Verstärkungsrune",
    food = "Essen",
}

local function NormalizeSlotLabel(slot)
    if not slot then return "" end
    return SLOT_LABELS[slot:lower()] or slot
end

local function SetItemQuality(fontString, item)
    local colorOrR, g, b = item:GetItemQualityColor()

    if type(colorOrR) == "table" then
        local r, cg, cb = colorOrR.r, colorOrR.g, colorOrR.b
        if type(r) == "number" and type(cg) == "number" and type(cb) == "number" then
            fontString:SetTextColor(r, cg, cb)
            return
        end
    elseif type(colorOrR) == "number" and type(g) == "number" and type(b) == "number" then
        fontString:SetTextColor(colorOrR, g, b)
        return
    end

    fontString:SetTextColor(1, 1, 1)
end

local function GetSpecData()
    local classToken = G.GetSelectedClass and G.GetSelectedClass()
    local specKey = G.GetSelectedSpec and G.GetSelectedSpec()
    local classData = classToken and GrimoireGearData and GrimoireGearData[classToken]
    return classData and specKey and classData[specKey]
end

local function CollectEnchantEntries(specData)
    local out = {}
    if not specData then return out end

    for _, entry in ipairs(specData.enchants or {}) do
        local slotLower = entry.slot and entry.slot:lower()
        if not CONSUMABLE_SLOT_NAMES[slotLower] and entry.best and entry.best.itemId then
            out[#out + 1] = {
                label = NormalizeSlotLabel(entry.slot),
                item = entry.best,
            }
        end
    end

    return out
end

local function CollectGemEntries(specData)
    local out = {}
    local gems = specData and specData.gems
    if not gems then return out end

    if gems.primary and gems.primary.itemId then
        out[#out + 1] = {
            label = "Primär",
            item = gems.primary,
        }
    end

    for _, gem in ipairs(gems.secondary or {}) do
        if gem.itemId then
            out[#out + 1] = {
                label = "Sekundär",
                item = gem,
            }
        end
    end

    return out
end

local function AddConsumable(out, label, item)
    if not item or not item.itemId then return end

    for _, existing in ipairs(out) do
        if existing.item.itemId == item.itemId then
            return
        end
    end

    out[#out + 1] = {
        label = label,
        item = item,
    }
end

-- Fester Midnight-S2-Heiltrank.
-- Wird absichtlich nicht vom Scraper abhängig gemacht, damit er immer
-- unter Verbrauchsgüter erscheint.
local FIXED_CONSUMABLES = {
    {
        label = "Vantusrune",
        item = {
            -- Midnight Season 2 / Patch 12.1
            -- Deutscher Name, Icon und Tooltip kommen direkt aus dem WoW-Client.
            itemId = 272195,
            name = "Vantus Rune: Tides",
        },
    },
    {
        label = "Heiltrank",
        item = {
            -- Hochwertige Variante; der deutsche Name/Icon/Tooltip kommen
            -- direkt aus dem laufenden WoW-Client.
            itemId = 271884,
            name = "Concentrated Silvermoon Health Potion",
        },
    },
}

local function CollectConsumableEntries(specData)
    local out = {}
    if not specData then return out end

    local c = specData.consumables or {}

    -- Feste, versionsspezifische Verbrauchsgüter zuerst ergänzen.
    for _, fixed in ipairs(FIXED_CONSUMABLES) do
        AddConsumable(out, fixed.label, fixed.item)
    end

    AddConsumable(out, "Fläschchen", c.flask)
    AddConsumable(out, "Kampftrank", c.combatPotion)
    AddConsumable(out, "Heiltrank", c.healthPotion)
    AddConsumable(out, "Waffenverstärkung", c.weaponBuff)
    AddConsumable(out, "Verstärkungsrune", c.augmentRune)
    AddConsumable(out, "Essen", c.food)

    -- Fallback für Scraper-Ausgaben, die Consumables unter "enchants" ablegen.
    for _, entry in ipairs(specData.enchants or {}) do
        local slotLower = entry.slot and entry.slot:lower()
        if CONSUMABLE_SLOT_NAMES[slotLower] and entry.best and entry.best.itemId then
            AddConsumable(out, NormalizeSlotLabel(entry.slot), entry.best)
        end
    end

    return out
end


local function GetSelectedSpecDisplayName()
    local classToken = G.GetSelectedClass and G.GetSelectedClass()
    local specKey = G.GetSelectedSpec and G.GetSelectedSpec()

    if classToken and specKey and G.GetSpecInfo then
        local specName = G.GetSpecInfo(classToken, specKey)
        if specName and specName ~= "" then
            return specName
        end
    end

    return specKey or "Unbekannt"
end

local function BuildAuctionatorListName(sectionTitle)
    return "Grimoire - " .. GetSelectedSpecDisplayName() .. " - " .. sectionTitle
end

local function BuildLocalizedAuctionatorItems(entries, callback)
    local items = {}
    local seen = {}

    -- Zuerst ALLE gültigen Item-IDs sammeln.
    -- Wichtig: ContinueOnItemLoad kann bei gecachten Items sofort/synchron
    -- feuern. Deshalb darf pending nicht erst während der Callback-
    -- Registrierung hochgezählt werden.
    local itemIDs = {}

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
            -- GetItemName() nutzt die Sprache des laufenden WoW-Clients.
            local localizedName = item:GetItemName()

            if localizedName and localizedName ~= "" and not seen[localizedName] then
                seen[localizedName] = true
                items[#items + 1] = localizedName
            end

            OneFinished()
        end)
    end
end

local function SendSectionToAuctionator(sectionTitle, entries)
    if not Auctionator
        or not Auctionator.Shopping
        or not Auctionator.Shopping.ListManager
    then
        ShowToast("Auctionator ist nicht geladen.", "warning")
        return
    end

    if not entries or #entries == 0 then
        ShowToast("Keine Items in diesem Abschnitt.", "warning")
        return
    end

    ShowToast("Items werden vorbereitet …")

    BuildLocalizedAuctionatorItems(entries, function(items)
        if #items == 0 then
            ShowToast("Itemnamen konnten nicht geladen werden.", "warning")
            return
        end

        local listName = BuildAuctionatorListName(sectionTitle)
        local manager = Auctionator.Shopping.ListManager

        if manager:GetIndexForName(listName) == nil then
            manager:Create(listName)
        end

        local list = manager:GetByName(listName)
        if not list then
            ShowToast("Auctionator-Liste konnte nicht erstellt werden.", "warning")
            return
        end

        list:ClearItems()
        list:AppendItems(items)

        ShowToast(string.format("%d Items → Auctionator-Liste", #items))
    end)
end


-- ============================================================
-- Blizzard-Auktionshaus-Favoriten
-- Funktioniert auch ohne Auctionator.
-- Wenn Favoriten gerade nicht verfügbar sind, werden Item-IDs
-- gespeichert und beim nächsten Öffnen des Auktionshauses gesetzt.
-- ============================================================

local function GetPendingFavorites()
    if not G.db then return nil end
    G.db.pendingAuctionFavorites = G.db.pendingAuctionFavorites or {}
    return G.db.pendingAuctionFavorites
end

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

local function QueueFavorite(itemID)
    local pending = GetPendingFavorites()
    if not pending or not itemID then return end

    pending[tostring(itemID)] = true
end

local function ApplyPendingFavorites()
    local pending = GetPendingFavorites()
    if not pending or not CanUseAuctionFavorites() then return end

    local completed = 0

    for itemIDString in pairs(pending) do
        local itemID = tonumber(itemIDString)
        local ok, reason = SetFavoriteByItemID(itemID)

        if ok then
            pending[itemIDString] = nil
            completed = completed + 1
        elseif reason == "max" then
            ShowToast("Maximale Anzahl an Favoriten erreicht.", "warning")
            break
        end
    end

    if completed > 0 then
        ShowToast(string.format("%d Favoriten gesetzt", completed))
    end
end

local function FavoriteSectionItems(entries)
    if not entries or #entries == 0 then
        ShowToast("Keine Items in diesem Abschnitt.", "warning")
        return
    end

    local added = 0
    local queued = 0
    local already = 0

    for _, entry in ipairs(entries) do
        local itemID = entry.item and entry.item.itemId

        if itemID then
            if CanUseAuctionFavorites() then
                local ok, reason = SetFavoriteByItemID(itemID)

                if ok and reason == "added" then
                    added = added + 1
                elseif ok and reason == "already" then
                    already = already + 1
                elseif reason == "max" then
                    ShowToast("Maximale Anzahl an Favoriten erreicht.", "warning")
                    break
                else
                    QueueFavorite(itemID)
                    queued = queued + 1
                end
            else
                QueueFavorite(itemID)
                queued = queued + 1
            end
        end
    end

    if added > 0 then
        ShowToast(string.format("%d Favoriten gesetzt", added))
    end

    if already > 0 then
        if added == 0 and queued == 0 then
            ShowToast(string.format("%d Items bereits favorisiert", already))
        end
    end

    if queued > 0 then
        ShowToast(string.format("%d Favoriten vorgemerkt", queued))
    end
end

local favoriteEventFrame = CreateFrame("Frame")
favoriteEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
favoriteEventFrame:SetScript("OnEvent", function()
    C_Timer.After(0.25, ApplyPendingFavorites)
end)

local SECTION_DEFS = {
    { key = "enchants", title = "Verzauberungen", collector = CollectEnchantEntries },
    { key = "gems", title = "Edelsteine", collector = CollectGemEntries },
    { key = "consumables", title = "Verbrauchsgüter", collector = CollectConsumableEntries },
}

local sections = {}

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

    row.iconButton = iconButton

    local slotText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slotText:SetPoint("LEFT", iconButton, "RIGHT", 5, 0)
    slotText:SetWidth(76)
    slotText:SetJustifyH("LEFT")
    slotText:SetWordWrap(false)
    slotText:SetTextColor(0.65, 0.65, 0.65)
    row.slotText = slotText

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", slotText, "RIGHT", 3, 0)
    nameText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    row:Hide()
    return row
end

local function Layout()
    local totalHeight = 0

    for _, entry in ipairs(sections) do
        entry.section:ClearAllPoints()
        entry.section:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -totalHeight)
        entry.section:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

        local sectionHeight = 22
        if not entry.section.IsCollapsed() then
            sectionHeight = sectionHeight + (entry.body and entry.body:GetHeight() or 0)
        end

        entry.section:SetHeight(sectionHeight)
        totalHeight = totalHeight + sectionHeight + SECTION_GAP
    end

    if totalHeight > 0 then
        totalHeight = totalHeight - SECTION_GAP
    end

    frame:SetHeight(totalHeight)

    if G.SetPanelContentHeight and G.GetActiveTab and G.GetActiveTab() == TAB_KEY then
        G.SetPanelContentHeight(totalHeight)
    end
end

local function SaveVisibility(key, section)
    if not G.db then return end
    G.db.sectionVisibility = G.db.sectionVisibility or {}
    G.db.sectionVisibility[key] = not section.IsCollapsed()
end

for _, def in ipairs(SECTION_DEFS) do
    local sectionEntry = {}

    local section, header, content = G.UI.CreateCollapsibleSection({
        parent = frame,
        title = def.title,
        onToggle = function()
            SaveVisibility(def.key, sectionEntry.section)

            local isOpening = not sectionEntry.section.IsCollapsed()

            if isOpening and sectionEntry.content then
                -- Der Inhalt darf beim Aufklappen noch nicht sichtbar sein,
                -- solange Section + Hauptpanel ihre neue Höhe anfahren.
                sectionEntry.content:SetAlpha(0)
            end

            -- Zuerst Section und Panel auf die neue Größe bringen.
            Layout()

            if isOpening and sectionEntry.content then
                local expectedSection = sectionEntry.section

                -- G.SoftHeight(panel) läuft 0.22 s.
                -- Erst danach den Inhalt sanft einblenden.
                C_Timer.After(0.23, function()
                    if not expectedSection
                        or expectedSection.IsCollapsed()
                        or not sectionEntry.content
                    then
                        return
                    end

                    sectionEntry.content:SetAlpha(0)
                    sectionEntry.content:Show()

                    if G.SoftAlpha then
                        G.SoftAlpha(sectionEntry.content, 1, 0.15)
                    else
                        sectionEntry.content:SetAlpha(1)
                    end
                end)
            elseif sectionEntry.content then
                -- Für den nächsten Öffnungsvorgang sauber zurücksetzen.
                sectionEntry.content:SetAlpha(1)
            end
        end,
    })

    sectionEntry.key = def.key
    sectionEntry.title = def.title
    sectionEntry.collector = def.collector
    sectionEntry.section = section
    sectionEntry.header = header
    sectionEntry.content = content
    sectionEntry.rows = {}
    sectionEntry.currentEntries = {}

    local favoriteButton = CreateFrame("Button", nil, header)
    favoriteButton:SetSize(18, 18)
    favoriteButton:SetPoint("RIGHT", header, "RIGHT", -4, 0)
    favoriteButton:SetFrameLevel(header:GetFrameLevel() + 5)

    local favoriteNormal = favoriteButton:CreateTexture(nil, "ARTWORK")
    favoriteNormal:SetPoint("CENTER")
    favoriteNormal:SetSize(13, 13)
    favoriteNormal:SetAtlas("auctionhouse-icon-favorite-off", false)
    favoriteButton.favoriteNormal = favoriteNormal

    local favoriteHighlight = favoriteButton:CreateTexture(nil, "HIGHLIGHT")
    favoriteHighlight:SetPoint("CENTER")
    favoriteHighlight:SetSize(13, 13)
    favoriteHighlight:SetAtlas("auctionhouse-icon-favorite", false)
    favoriteHighlight:SetAlpha(0.45)
    favoriteButton.favoriteHighlight = favoriteHighlight

    local auctionButton = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
    auctionButton:SetSize(34, 18)
    auctionButton:SetPoint("RIGHT", favoriteButton, "LEFT", -4, 0)
    auctionButton:SetText("AH")
    auctionButton:SetFrameLevel(header:GetFrameLevel() + 5)

    favoriteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Auktionshaus-Favoriten")
        GameTooltip:AddLine(
            "Markiert alle Items dieses Abschnitts als Favoriten im normalen WoW-Auktionshaus.",
            0.8, 0.8, 0.8,
            true
        )
        if not CanUseAuctionFavorites() then
            GameTooltip:AddLine(
                "Ist das Auktionshaus nicht geöffnet, werden die Items vorgemerkt.",
                1.0, 0.82, 0.0,
                true
            )
        end
        GameTooltip:Show()
    end)

    favoriteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    favoriteButton:SetScript("OnClick", function()
        FavoriteSectionItems(sectionEntry.currentEntries)
    end)

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

    auctionButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    auctionButton:SetScript("OnClick", function()
        SendSectionToAuctionator(sectionEntry.title, sectionEntry.currentEntries)
    end)

    sectionEntry.auctionButton = auctionButton
    sectionEntry.favoriteButton = favoriteButton

    local body = CreateFrame("Frame", nil, content)
    body:SetPoint("TOPLEFT", 0, 0)
    body:SetPoint("RIGHT", 0, 0)
    body:SetHeight(1)
    sectionEntry.body = body

    sections[#sections + 1] = sectionEntry
end

local function ApplySavedVisibility()
    if not G.db or not G.db.sectionVisibility then return end

    for _, entry in ipairs(sections) do
        local wantedOpen = G.db.sectionVisibility[entry.key] ~= false

        -- Je nach Version der gemeinsamen UI-Komponente kann SetCollapsed
        -- vorhanden sein. Falls nicht, bleibt der Standardzustand bestehen.
        if entry.section.SetCollapsed then
            entry.section.SetCollapsed(not wantedOpen)
        elseif entry.section.SetExpanded then
            entry.section.SetExpanded(wantedOpen)
        end
    end
end

local function RefreshSection(entry, specData, animate)
    local items = entry.collector(specData)
    entry.currentEntries = items

    if entry.auctionButton then
        entry.auctionButton:SetEnabled(#items > 0)
    end
    if entry.favoriteButton then
        entry.favoriteButton:SetEnabled(#items > 0)
    end

    if #items == 0 then
        local row = entry.rows[1]
        if not row then
            row = CreateRow(entry.body)
            entry.rows[1] = row
        end

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", entry.body, "TOPLEFT", 0, 0)
        row:SetPoint("RIGHT", entry.body, "RIGHT", 0, 0)
        row.iconButton.itemId = nil
        row.iconButton.texture:SetTexture(134400)
        row.slotText:SetText("")
        row.nameText:SetText("Keine Daten verfügbar.")
        row.nameText:SetTextColor(0.55, 0.55, 0.55)
        row:SetAlpha(1)
        row:Show()

        for i = 2, #entry.rows do
            entry.rows[i]:Hide()
        end

        entry.body:SetHeight(ROW_HEIGHT)
        return
    end

    for i, itemEntry in ipairs(items) do
        local row = entry.rows[i]
        if not row then
            row = CreateRow(entry.body)
            entry.rows[i] = row
        end

        local itemID = itemEntry.item.itemId

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", entry.body, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row:SetPoint("RIGHT", entry.body, "RIGHT", 0, 0)

        row.iconButton.itemId = itemID
        row.iconButton.texture:SetTexture(134400)
        row.slotText:SetText(itemEntry.label or "")
        row.nameText:SetText(itemEntry.item.name or ("Item " .. tostring(itemID)))
        row.nameText:SetTextColor(1, 1, 1)

        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            if row.iconButton.itemId ~= itemID then return end

            row.iconButton.texture:SetTexture(item:GetItemIcon() or 134400)
            row.nameText:SetText(item:GetItemName() or itemEntry.item.name or ("Item " .. tostring(itemID)))
            SetItemQuality(row.nameText, item)
        end)

        if animate and G.SoftShow and not entry.section.IsCollapsed() then
            row:SetAlpha(0)
            row:Show()
            C_Timer.After((i - 1) * 0.018, function()
                if row.iconButton.itemId == itemID then
                    G.SoftShow(row, 0.14)
                end
            end)
        else
            row:SetAlpha(1)
            row:Show()
        end
    end

    for i = #items + 1, #entry.rows do
        entry.rows[i]:Hide()
        entry.rows[i]:SetAlpha(1)
    end

    entry.body:SetHeight(#items * ROW_HEIGHT)
end

local function Refresh(animate)
    local specData = GetSpecData()

    for _, entry in ipairs(sections) do
        RefreshSection(entry, specData, animate)
    end

    Layout()
end

G.RegisterTabContent(TAB_KEY, frame)

if G.RegisterOnActiveTabChanged then
    G.RegisterOnActiveTabChanged(function(tabKey)
        if tabKey == TAB_KEY then
            Refresh(false)
        end
    end)
end

G.RegisterOnDatabaseReady(function()
    ApplySavedVisibility()
    Refresh(false)
end)

G.RegisterOnSelectionChanged(function()
    Refresh(true)
end)

Refresh(false)
