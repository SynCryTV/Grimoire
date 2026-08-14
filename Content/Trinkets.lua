local ADDON_NAME, G = ...

local TAB_KEY = "trinkets"


local trinketsFrame = CreateFrame("Frame", "GrimoireTrinketsTab", G.panel)
trinketsFrame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
trinketsFrame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)

local DD_HEIGHT = 24
local DD_GAP = 8
local ROW_HEIGHT = 34
local HEADER_HEIGHT = 24
local ICON_SIZE = 24
local CONTENT_HEIGHT = 500

local TIER_ORDER = { "S", "A", "B", "C", "D" }
local TIER_COLORS = {
    S = { 1.00, 0.50, 0.20 },
    A = { 1.00, 0.82, 0.20 },
    B = { 0.25, 0.75, 1.00 },
    C = { 0.25, 1.00, 0.45 },
    D = { 0.70, 0.70, 0.70 },
}

local CONTEXT_OPTIONS = {
    { key = "all",      label = "Alle" },
    { key = "raid",     label = "Raid" },
    { key = "dungeon",  label = "Mythic+" },
    { key = "delves",   label = "Delves" },
    { key = "crafting", label = "Crafting" },
}

local CONTEXT_LABELS = {
    raid = "Raid",
    dungeon = "M+",
    delves = "Delves",
    crafting = "Crafting",
}

local CLASS_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK",
    "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

local selectedContext = "all"
local Refresh
local itemNameCache = {}
local pendingItemNames = {}

-- ============================================================
-- Daten-Helfer
-- ============================================================

local function GetSpecTrinkets(classToken, specKey)
    local classData = GrimoireGearData and GrimoireGearData[classToken]
    local specData = classData and classData[specKey]
    return specData and specData.trinkets
end

local function HasContext(entry, wanted)
    if wanted == "all" then return true end
    if not entry.contexts then return false end

    for _, context in ipairs(entry.contexts) do
        if context == wanted then
            return true
        end
    end
    return false
end

local function ContextText(contexts)
    if not contexts or #contexts == 0 then return "" end

    local labels = {}
    for _, context in ipairs(contexts) do
        labels[#labels + 1] = CONTEXT_LABELS[context] or context
    end
    return table.concat(labels, ", ")
end

local function GetTierColor(tier)
    return TIER_COLORS[tier] or { 1, 1, 1 }
end

local function IsTierEnabled(tier)
    if not G.db or not G.db.trinketTierFilters then return true end
    return G.db.trinketTierFilters[tier] ~= false
end

local function GetCachedItemName(itemID)
    if itemNameCache[itemID] then
        return itemNameCache[itemID]
    end

    local name
    if C_Item and C_Item.GetItemNameByID then
        name = C_Item.GetItemNameByID(itemID)
    end

    if name then
        itemNameCache[itemID] = name
        return name
    end

    if not pendingItemNames[itemID] then
        pendingItemNames[itemID] = true
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            pendingItemNames[itemID] = nil
            itemNameCache[itemID] = item:GetItemName() or ("Item " .. tostring(itemID))
            if Refresh then Refresh() end
        end)
    end

    return nil
end

local function SetFontStringItemQuality(fontString, item)
    local colorOrR, g, b = item:GetItemQualityColor()

    if type(colorOrR) == "table" then
        local r = colorOrR.r
        local cg = colorOrR.g
        local cb = colorOrR.b
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

-- ============================================================
-- Tab UI
-- ============================================================

local contextDropdown = CreateFrame(
    "DropdownButton",
    "GrimoireTrinketsContextDD",
    trinketsFrame,
    "WowStyle1DropdownTemplate"
)
contextDropdown:SetPoint("TOPLEFT", 0, 0)
contextDropdown:SetSize(125, DD_HEIGHT)

local searchLabel = trinketsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
searchLabel:SetPoint("LEFT", contextDropdown, "RIGHT", 8, 0)
searchLabel:SetText("Suche:")

local searchBox = CreateFrame("EditBox", "GrimoireTrinketsSearchBox", trinketsFrame, "InputBoxTemplate")
searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 6, 0)
searchBox:SetSize(125, 22)
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(60)
searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnTextChanged", function()
    if Refresh then Refresh() end
end)

local ownClassCheckbox = CreateFrame(
    "CheckButton",
    "GrimoireTrinketsOwnClassOnly",
    trinketsFrame,
    "UICheckButtonTemplate"
)
ownClassCheckbox:SetPoint("TOPLEFT", contextDropdown, "BOTTOMLEFT", -4, -6)
ownClassCheckbox:SetSize(24, 24)

local ownClassLabel = trinketsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
ownClassLabel:SetPoint("LEFT", ownClassCheckbox, "RIGHT", 2, 0)
ownClassLabel:SetText("Tooltip: nur eigene Klasse")

-- Kleine Hilfe für Suche, Tierfilter und Tooltip-Optionen.
local trinketHelp = CreateFrame("Frame", nil, trinketsFrame)
trinketHelp:SetSize(16, 16)
trinketHelp:SetPoint("LEFT", ownClassLabel, "RIGHT", 5, 0)
trinketHelp:EnableMouse(true)

local trinketHelpText = trinketHelp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
trinketHelpText:SetPoint("CENTER", 0, 0)
trinketHelpText:SetText("?")
trinketHelpText:SetTextColor(0.72, 0.72, 0.72)

trinketHelp:SetScript("OnEnter", function(self)
    trinketHelpText:SetTextColor(1.0, 0.82, 0.0)

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Trinket-Tierliste")
    GameTooltip:AddLine(" ")

    GameTooltip:AddLine(
        "Suche",
        1.0, 0.82, 0.0
    )
    GameTooltip:AddLine(
        "Filtert die Trinket-Liste nach dem eingegebenen Namen.",
        0.85, 0.85, 0.85,
        true
    )

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Tier-Filter",
        1.0, 0.82, 0.0
    )
    GameTooltip:AddLine(
        "Mit S, A, B, C und D kannst du mehrere Tiers gleichzeitig ein- oder ausblenden.",
        0.85, 0.85, 0.85,
        true
    )
    GameTooltip:AddLine(
        "Die gewählten Tier-Filter gelten auch für die BiS-Hinweise in Item-Tooltips.",
        0.85, 0.85, 0.85,
        true
    )

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Tooltip: nur eigene Klasse",
        1.0, 0.82, 0.0
    )
    GameTooltip:AddLine(
        "Aktiviert: Im Item-Tooltip werden nur die Specs deiner aktuell gespielten Klasse angezeigt.",
        0.85, 0.85, 0.85,
        true
    )
    GameTooltip:AddLine(
        "Deaktiviert: Der Tooltip kann passende Specs aller Klassen anzeigen.",
        0.85, 0.85, 0.85,
        true
    )

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Die Einstellungen werden gespeichert und bleiben nach einem Neustart erhalten.",
        0.45, 0.85, 1.0,
        true
    )

    GameTooltip:Show()
end)

trinketHelp:SetScript("OnLeave", function()
    trinketHelpText:SetTextColor(0.72, 0.72, 0.72)
    GameTooltip:Hide()
end)

ownClassCheckbox:SetScript("OnClick", function(self)
    if not G.db then return end
    G.db.trinketTiersAllClasses = not self:GetChecked()
end)

local tierLabel = trinketsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
tierLabel:SetPoint("TOPLEFT", ownClassCheckbox, "BOTTOMLEFT", 4, -4)
tierLabel:SetText("Tier:")

local tierCheckboxes = {}
local lastLabel = tierLabel

for _, tier in ipairs(TIER_ORDER) do
    local cb = CreateFrame(
        "CheckButton",
        "GrimoireTrinketsTierFilter" .. tier,
        trinketsFrame,
        "UICheckButtonTemplate"
    )
    cb:SetSize(22, 22)

    if lastLabel == tierLabel then
        cb:SetPoint("LEFT", tierLabel, "RIGHT", 6, 0)
    else
        cb:SetPoint("LEFT", lastLabel, "RIGHT", 8, 0)
    end

    local label = trinketsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", cb, "RIGHT", 0, 0)
    label:SetText(tier)

    local tc = GetTierColor(tier)
    label:SetTextColor(tc[1], tc[2], tc[3])

    cb.tier = tier
    cb.label = label
    cb:SetScript("OnClick", function(self)
        if not G.db then return end
        G.db.trinketTierFilters = G.db.trinketTierFilters or {}
        G.db.trinketTierFilters[self.tier] = self:GetChecked() and true or false
        if Refresh then Refresh() end
    end)

    tierCheckboxes[tier] = cb
    lastLabel = label
end

local infoText = trinketsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
infoText:SetPoint("LEFT", lastLabel, "RIGHT", 10, 0)
infoText:SetText("Wowhead")

local scrollFrame = CreateFrame(
    "ScrollFrame",
    "GrimoireTrinketsScrollFrame",
    trinketsFrame,
    "UIPanelScrollFrameTemplate"
)
local TOP_CONTROLS_HEIGHT = DD_HEIGHT + 54
scrollFrame:SetPoint("TOPLEFT", trinketsFrame, "TOPLEFT", 0, -(TOP_CONTROLS_HEIGHT + DD_GAP))
scrollFrame:SetPoint("RIGHT", trinketsFrame, "RIGHT", -26, 0)
scrollFrame:SetHeight(CONTENT_HEIGHT - TOP_CONTROLS_HEIGHT - DD_GAP)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetPoint("TOPLEFT")
scrollChild:SetWidth(1)
scrollChild:SetHeight(1)
scrollFrame:SetScrollChild(scrollChild)

scrollFrame:HookScript("OnSizeChanged", function(self)
    scrollChild:SetWidth(math.max(1, self:GetWidth()))
end)

-- ============================================================
-- Soft / inertial mouse-wheel scrolling
-- ============================================================
scrollFrame:EnableMouseWheel(true)

local smoothTarget = 0
local smoothCurrent = 0
local smoothRunning = false
local SCROLL_STEP = 78
local SCROLL_SPEED = 13

local function GetMaxScroll()
    local childHeight = scrollChild:GetHeight() or 0
    local frameHeight = scrollFrame:GetHeight() or 0
    return math.max(0, childHeight - frameHeight)
end

local function ClampScroll(value)
    return math.max(0, math.min(GetMaxScroll(), value))
end

local function StartSmoothScroll()
    if smoothRunning then return end
    smoothRunning = true

    scrollFrame:SetScript("OnUpdate", function(self, elapsed)
        local maxScroll = GetMaxScroll()
        smoothTarget = math.max(0, math.min(maxScroll, smoothTarget))

        local diff = smoothTarget - smoothCurrent
        if math.abs(diff) < 0.35 then
            smoothCurrent = smoothTarget
            self:SetVerticalScroll(smoothCurrent)
            self:SetScript("OnUpdate", nil)
            smoothRunning = false
            return
        end

        -- Framerate-unabhängiges Ease-Out. Dadurch fühlt sich das Mausrad
        -- eher wie ein weiches Trackpad/iPhone-Scrollen an als wie Zeilensprünge.
        local factor = 1 - math.exp(-SCROLL_SPEED * elapsed)
        smoothCurrent = smoothCurrent + diff * factor
        self:SetVerticalScroll(smoothCurrent)
    end)
end

scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    -- Falls der Scrollbalken zwischenzeitlich manuell bewegt wurde,
    -- von dessen aktueller Position weiterarbeiten.
    if not smoothRunning then
        smoothCurrent = self:GetVerticalScroll() or 0
        smoothTarget = smoothCurrent
    end

    smoothTarget = ClampScroll(smoothTarget - (delta * SCROLL_STEP))
    StartSmoothScroll()
end)

-- Wenn der Nutzer den normalen Blizzard-Scrollbalken zieht/klickt,
-- synchronisieren wir beim nächsten Mausradimpuls wieder von dort.
local scrollBar = scrollFrame.ScrollBar
if scrollBar then
    scrollBar:HookScript("OnValueChanged", function(_, value)
        if not smoothRunning then
            smoothCurrent = value or 0
            smoothTarget = smoothCurrent
        end
    end)
end

local rows = {}
local headers = {}

local fallbackText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetPoint("TOPLEFT", 4, -4)
fallbackText:SetPoint("RIGHT", scrollChild, "RIGHT", -4, 0)
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.6, 0.6, 0.6)
fallbackText:Hide()

local function CreateHeader(index)
    local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetJustifyH("LEFT")
    headers[index] = header
    return header
end

local function CreateRow(index)
    local row = CreateFrame("Frame", nil, scrollChild)
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
    iconTexture:SetTexture(134400)
    iconButton.texture = iconTexture

    iconButton:SetScript("OnEnter", function(self)
        if not self.itemId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemId)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", GameTooltip_Hide)
    row.iconButton = iconButton

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", iconButton, "TOPRIGHT", 7, -1)
    nameText:SetPoint("RIGHT", row, "RIGHT", -36, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    local detailText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    detailText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    detailText:SetPoint("RIGHT", row, "RIGHT", -36, 0)
    detailText:SetJustifyH("LEFT")
    detailText:SetWordWrap(false)
    row.detailText = detailText

    local tierText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tierText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    tierText:SetWidth(28)
    tierText:SetJustifyH("CENTER")
    row.tierText = tierText

    row:Hide()
    rows[index] = row
    return row
end

local function HideUnused(usedRows, usedHeaders)
    for i = usedRows + 1, #rows do
        rows[i]:Hide()
    end
    for i = usedHeaders + 1, #headers do
        headers[i]:Hide()
    end
end

local function ReportContentHeight()
    trinketsFrame:SetHeight(CONTENT_HEIGHT)
    if G.SetPanelContentHeight and G.GetActiveTab and G.GetActiveTab() == TAB_KEY then
        G.SetPanelContentHeight(CONTENT_HEIGHT)
    end
end

Refresh = function()
    if G.db then
        ownClassCheckbox:SetChecked(not G.db.trinketTiersAllClasses)
        for _, tier in ipairs(TIER_ORDER) do
            if tierCheckboxes[tier] then
                tierCheckboxes[tier]:SetChecked(IsTierEnabled(tier))
            end
        end
    else
        ownClassCheckbox:SetChecked(true)
        for _, tier in ipairs(TIER_ORDER) do
            if tierCheckboxes[tier] then
                tierCheckboxes[tier]:SetChecked(true)
            end
        end
    end

    local searchQuery = (searchBox:GetText() or ""):lower():match("^%s*(.-)%s*$") or ""

    contextDropdown:SetText(
        (function()
            for _, option in ipairs(CONTEXT_OPTIONS) do
                if option.key == selectedContext then return option.label end
            end
            return "Alle"
        end)()
    )

    contextDropdown:SetupMenu(function(_, rootDescription)
        for _, option in ipairs(CONTEXT_OPTIONS) do
            rootDescription:CreateRadio(
                option.label,
                function() return selectedContext == option.key end,
                function()
                    selectedContext = option.key
                    Refresh()
                end
            )
        end
    end)

    local classToken = G.GetSelectedClass and G.GetSelectedClass()
    local specKey = G.GetSelectedSpec and G.GetSelectedSpec()
    local trinkets = classToken and specKey and GetSpecTrinkets(classToken, specKey)

    fallbackText:Hide()

    if not trinkets or #trinkets == 0 then
        HideUnused(0, 0)
        fallbackText:SetText("Keine Trinket-Tierdaten für diese Spec verfügbar.")
        fallbackText:Show()
        scrollChild:SetHeight(60)
        ReportContentHeight()
        return
    end

    local byTier = {}
    for _, tier in ipairs(TIER_ORDER) do
        byTier[tier] = {}
    end

    for _, entry in ipairs(trinkets) do
        if entry.itemId
            and entry.tier
            and byTier[entry.tier]
            and IsTierEnabled(entry.tier)
            and HasContext(entry, selectedContext)
        then
            local include = true
            if searchQuery ~= "" then
                local itemName = GetCachedItemName(entry.itemId)
                include = itemName and itemName:lower():find(searchQuery, 1, true) ~= nil
            end

            if include then
                byTier[entry.tier][#byTier[entry.tier] + 1] = entry
            end
        end
    end

    local y = 0
    local rowIndex = 0
    local headerIndex = 0
    local any = false

    for _, tier in ipairs(TIER_ORDER) do
        local tierEntries = byTier[tier]
        if #tierEntries > 0 then
            any = true
            headerIndex = headerIndex + 1
            local header = headers[headerIndex] or CreateHeader(headerIndex)
            local tc = GetTierColor(tier)

            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 4, -y)
            header:SetText(tier .. "-Tier")
            header:SetTextColor(tc[1], tc[2], tc[3])
            header:Show()
            y = y + HEADER_HEIGHT

            for _, entry in ipairs(tierEntries) do
                rowIndex = rowIndex + 1
                local row = rows[rowIndex] or CreateRow(rowIndex)

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -y)
                row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

                row.iconButton.itemId = entry.itemId
                row.iconButton.texture:SetTexture(134400)

                row.nameText:SetText("Item " .. tostring(entry.itemId))
                row.nameText:SetTextColor(1, 1, 1)

                local context = ContextText(entry.contexts)
                if entry.source and entry.source ~= "" then
                    row.detailText:SetText(
                        (context ~= "" and (context .. "  •  ") or "") .. entry.source
                    )
                else
                    row.detailText:SetText(context)
                end

                local tc = GetTierColor(entry.tier)
                row.tierText:SetText(entry.tier)
                row.tierText:SetTextColor(tc[1], tc[2], tc[3])

                local equipped1 = GetInventoryItemID("player", INVSLOT_TRINKET1)
                local equipped2 = GetInventoryItemID("player", INVSLOT_TRINKET2)
                row.ownedHighlight:SetShown(entry.itemId == equipped1 or entry.itemId == equipped2)

                local item = Item:CreateFromItemID(entry.itemId)
                item:ContinueOnItemLoad(function()
                    -- Row kann inzwischen recycelt worden sein.
                    if row.iconButton.itemId ~= entry.itemId then return end

                    row.iconButton.texture:SetTexture(item:GetItemIcon() or 134400)
                    row.nameText:SetText(item:GetItemName() or ("Item " .. tostring(entry.itemId)))
                    SetFontStringItemQuality(row.nameText, item)
                end)

                row:Show()
                y = y + ROW_HEIGHT
            end

            y = y + 4
        end
    end

    HideUnused(rowIndex, headerIndex)

    if not any then
        fallbackText:SetText("Keine Trinkets passen zu Filter oder Suche.")
        fallbackText:Show()
        y = 60
    end

    scrollChild:SetHeight(math.max(y, scrollFrame:GetHeight()))
    ReportContentHeight()
end

G.RegisterTabContent(TAB_KEY, trinketsFrame)

if G.RegisterOnActiveTabChanged then
    G.RegisterOnActiveTabChanged(function(tabKey)
        if tabKey == TAB_KEY then
            Refresh()
            ReportContentHeight()
        end
    end)
end

G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(Refresh)

-- ============================================================
-- Tooltip: "Beste Ausrüstung"
-- Zeigt ALLE Klassen/Specs, für die das Item in den Wowhead-
-- Trinket-Tierdaten vorkommt.
-- ============================================================

local function GetTooltipItemID(tooltip, tooltipData)
    if tooltipData and type(tooltipData.id) == "number" then
        return tooltipData.id
    end

    if TooltipUtil and TooltipUtil.GetDisplayedItem then
        local first, second = TooltipUtil.GetDisplayedItem(tooltip)
        if type(first) == "number" then
            return first
        end
        if type(second) == "string" then
            local itemID = C_Item.GetItemInfoInstant(second)
            if itemID then return itemID end
        end
    end

    if tooltip and tooltip.GetItem then
        local _, itemLink = tooltip:GetItem()
        if itemLink then
            local itemID = C_Item.GetItemInfoInstant(itemLink)
            if itemID then return itemID end
        end
    end

    if tooltip and tooltip.GetTooltipData then
        local data = tooltip:GetTooltipData()
        if data then
            if type(data.id) == "number" then
                return data.id
            end
            if type(data.hyperlink) == "string" then
                local itemID = C_Item.GetItemInfoInstant(data.hyperlink)
                if itemID then return itemID end
            end
        end
    end

    return nil
end

local function TooltipAlreadyHasBestGear(tooltip)
    local tooltipName = tooltip and tooltip.GetName and tooltip:GetName()
    if not tooltipName or not tooltip.NumLines then return false end

    for i = 1, tooltip:NumLines() do
        local left = _G[tooltipName .. "TextLeft" .. i]
        local text = left and left:GetText()
        if text == "Beste Ausrüstung" then
            return true
        end
    end

    return false
end

local function FindTrinketMatches(itemID)
    local matches = {}

    local _, playerClassToken = UnitClass("player")
    local showAllClasses = G.db and G.db.trinketTiersAllClasses == true

    for _, classToken in ipairs(CLASS_ORDER) do
        if showAllClasses or classToken == playerClassToken then
            local classData = GrimoireGearData and GrimoireGearData[classToken]
            local specKeys = G.SPEC_KEYS and G.SPEC_KEYS[classToken]

            if classData and specKeys then
                for _, specKey in ipairs(specKeys) do
                    local specData = classData[specKey]
                    local bisGear = specData and specData.bisGear
                    local isOverallBisTrinket = false

                    if bisGear then
                        for _, contextEntry in ipairs(bisGear) do
                            if contextEntry.label
                                and contextEntry.label:lower() == "overall"
                                and contextEntry.slots
                            then
                                for _, slotEntry in ipairs(contextEntry.slots) do
                                    local slotName = slotEntry.slot and slotEntry.slot:lower()
                                    local id = slotEntry.item and slotEntry.item.itemId

                                    if slotName == "trinket" and id == itemID then
                                        isOverallBisTrinket = true
                                        break
                                    end
                                end
                                break
                            end
                        end
                    end

                    if isOverallBisTrinket then
                        local tier
                        local trinkets = specData and specData.trinkets
                        if trinkets then
                            for _, entry in ipairs(trinkets) do
                                if entry.itemId == itemID then
                                    tier = entry.tier
                                    break
                                end
                            end
                        end

                        if (not tier) or IsTierEnabled(tier) then
                            matches[#matches + 1] = {
                                classToken = classToken,
                                specKey = specKey,
                                tier = tier,
                            }
                        end
                    end
                end
            end
        end
    end

    return matches
end

local function OnTooltipTrinket(tooltip, tooltipData)
    local itemID = GetTooltipItemID(tooltip, tooltipData)
    if not itemID then return end

    local matches = FindTrinketMatches(itemID)
    if #matches == 0 then return end
    if TooltipAlreadyHasBestGear(tooltip) then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("Beste Ausrüstung", 1.00, 0.82, 0.20)

    for _, match in ipairs(matches) do
        local specName, specIcon = G.GetSpecInfo(match.classToken, match.specKey)
        local className = G.GetClassDisplayName(match.classToken) or match.classToken
        local leftText = ""

        if specIcon then
            leftText = G.GetSpecIconMarkup(specIcon, 14)
        end

        leftText = leftText .. (specName or match.specKey) .. " " .. className

        if match.tier then
            local tc = GetTierColor(match.tier)
            tooltip:AddDoubleLine(
                leftText,
                match.tier,
                1, 1, 1,
                tc[1], tc[2], tc[3]
            )
        else
            tooltip:AddLine(leftText, 1, 1, 1)
        end
    end

    tooltip:Show()
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipTrinket)
