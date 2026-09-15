local ADDON_NAME, G = ...

local TAB_KEY = "keystoneloot"
local frame = CreateFrame("Frame", "GrimoireKeystoneLootTab", G.panel)
frame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
frame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)

local ROW_HEIGHT, ICON_SIZE = 33, 24
local selectedContext = "Overall"
local rows = {}

local contextDropdown = CreateFrame("DropdownButton", "GrimoireKeystoneLootContextDD", frame, "WowStyle1DropdownTemplate")
contextDropdown:SetPoint("TOPLEFT", 0, 0)
contextDropdown:SetSize(150, 24)

local updatedText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
updatedText:SetPoint("LEFT", contextDropdown, "RIGHT", 8, 0)

local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hint:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -31)
hint:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
hint:SetJustifyH("LEFT")
hint:SetText("BiS: KeystoneLoot • Sockel und VZ stammen direkt aus der jeweiligen Liste. Fläschchen, Essen und Tränke: Wowhead.")

local fallback = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallback:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -57)
fallback:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
fallback:SetJustifyH("LEFT")
fallback:SetTextColor(0.5, 0.5, 0.5)
fallback:Hide()

local function CreateRow(index)
    local row = CreateFrame("Button", nil, frame)
    row:SetHeight(ROW_HEIGHT)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", 0, 0)
    row.icon = icon
    local title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 7, -1)
    title:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    title:SetJustifyH("LEFT")
    row.title = title
    local detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    detail:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 7, 1)
    detail:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    detail:SetJustifyH("LEFT")
    row.detail = detail
    row:SetScript("OnEnter", function(self)
        if not self.itemID then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemID)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", GameTooltip_Hide)
    rows[index] = row
    return row
end

local function ItemName(row, itemID)
    row.title:SetText("Item " .. tostring(itemID))
    row.icon:SetTexture(134400)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        if row.itemID ~= itemID then return end
        row.title:SetText(item:GetItemName() or ("Item " .. tostring(itemID)))
        row.icon:SetTexture(item:GetItemIcon() or 134400)
        local color = item:GetItemQualityColor()
        if type(color) == "table" and color.r then row.title:SetTextColor(color.r, color.g, color.b) end
    end)
end

local function GetList()
    local classToken, specKey = G.GetSelectedClass(), G.GetSelectedSpec()
    local data = GrimoireKeystoneLootData and GrimoireKeystoneLootData[classToken] and GrimoireKeystoneLootData[classToken][specKey]
    if not data then return nil, nil end
    for _, list in ipairs(data.lists or {}) do
        if list.label == selectedContext then return list, data.updated end
    end
    return data.lists and data.lists[1], data.updated
end

local function Refresh()
    fallback:Hide()
    local classToken, specKey = G.GetSelectedClass(), G.GetSelectedSpec()
    local data = GrimoireKeystoneLootData and GrimoireKeystoneLootData[classToken] and GrimoireKeystoneLootData[classToken][specKey]
    if not data or not data.lists then
        fallback:SetText("Keine KeystoneLoot-Daten für diese Spec verfügbar.")
        fallback:Show()
        for _, row in ipairs(rows) do row:Hide() end
        frame:SetHeight(82)
        return
    end
    local options = {}
    for _, list in ipairs(data.lists) do options[#options + 1] = list.label end
    local exists = false
    for _, label in ipairs(options) do if label == selectedContext then exists = true end end
    if not exists then selectedContext = options[1] end
    contextDropdown:SetText(selectedContext)
    contextDropdown:SetupMenu(function(_, root)
        for _, label in ipairs(options) do
            root:CreateRadio(label, function() return selectedContext == label end, function() selectedContext = label; Refresh() end)
        end
    end)
    updatedText:SetText("Aktualisiert: " .. (data.updated or "unbekannt"))
    local list = GetList()
    local visible = 0
    for _, entry in ipairs((list and list.slots) or {}) do
        if (entry.tier or 2) == 3 then
            visible = visible + 1
            local row = rows[visible] or CreateRow(visible)
            row.itemID = entry.itemId
            ItemName(row, entry.itemId)
            local details = { "BiS" }
            if entry.gems and #entry.gems > 0 then table.insert(details, #entry.gems == 1 and "Sockel" or (#entry.gems .. " Sockel")) end
            if entry.enchant and entry.enchant > 0 then table.insert(details, "VZ empfohlen") end
            row.detail:SetText(table.concat(details, " • "))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -57 - (visible - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
            row:Show()
        end
    end
    for i = visible + 1, #rows do rows[i]:Hide() end
    frame:SetHeight(57 + visible * ROW_HEIGHT)
    if G.SetPanelContentHeight and G.GetActiveTab and G.GetActiveTab() == TAB_KEY then G.SetPanelContentHeight(frame:GetHeight()) end
end

G.RegisterTabContent(TAB_KEY, frame)
G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(Refresh)
if G.RegisterOnActiveTabChanged then G.RegisterOnActiveTabChanged(function(key) if key == TAB_KEY then Refresh() end end) end
