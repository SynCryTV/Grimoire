local ADDON_NAME, G = ...

local STAT_ORDER = { "mastery", "haste", "crit", "versatility" }
local STAT_LABELS = {
    mastery = "Mastery", haste = "Haste", crit = "Critical Strike", versatility = "Versatility",
}
local STAT_COMBAT_RATING = {
    mastery = CR_MASTERY,
    haste = CR_HASTE_MELEE, -- Melee/Ranged/Spell-Haste sind auf demselben Rating-Wert gebündelt
    crit = CR_CRIT_MELEE,   -- ebenso für Crit
    versatility = CR_VERSATILITY,
}

local body = CreateFrame("Frame", nil, G.GuideSections.statTargets.content)
body:SetHeight(20)

local contextDropdown = CreateFrame("DropdownButton", "GrimoireStatTargetContextDD", body, "WowStyle1DropdownTemplate")
contextDropdown:SetPoint("TOPLEFT", 0, 0)
contextDropdown:SetPoint("TOPRIGHT", 0, 0)
contextDropdown:SetHeight(24)
contextDropdown:Hide()

local rows = {}
local ROW_HEIGHT = 36
local MAX_ROWS = 4
for i = 1, MAX_ROWS do
    local row = CreateFrame("Frame", nil, body)
    row:SetHeight(ROW_HEIGHT)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", 0, 0)
    row.label = label

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("TOPRIGHT", 0, 0)
    row.valueText = valueText

    local barBg = row:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("BOTTOMLEFT", 0, 0)
    barBg:SetPoint("BOTTOMRIGHT", 0, 0)
    barBg:SetHeight(12)
    barBg:SetColorTexture(0.08, 0.08, 0.08, 1)
    row.barBg = barBg

    local bar = CreateFrame("StatusBar", nil, row)
    bar:SetPoint("TOPLEFT", barBg, "TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", barBg, "BOTTOMRIGHT", -1, 1)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 1)
    row.bar = bar

    row:Hide()
    rows[i] = row
end

local fallbackText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetPoint("TOPLEFT", 0, 0)
fallbackText:SetPoint("RIGHT", 0, 0)
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

local currentContext -- "Mythic+" oder "Raid"

local function GetLivePlayerStatRating(statKey)
    local ratingIndex = STAT_COMBAT_RATING[statKey]
    if not ratingIndex then return 0 end
    return GetCombatRating(ratingIndex) or 0
end

local function ClassifyDelta(current, target)
    if target <= 0 then return "at" end
    local ratio = current / target
    if ratio > 1.05 then return "above"
    elseif ratio >= 0.95 then return "at"
    else return "below" end
end

local DELTA_COLORS = {
    above = { 0.35, 0.65, 1.00 },
    at    = { 0.40, 1.00, 0.45 },
    below = { 0.95, 0.40, 0.40 },
}

local function RenderRows(snapshot)
    local visibleCount = 0
    for _, statKey in ipairs(STAT_ORDER) do
        local target = snapshot.targets and snapshot.targets[statKey]
        if target and target > 0 then
            visibleCount = visibleCount + 1
            local row = rows[visibleCount]
            local current = GetLivePlayerStatRating(statKey)
            local kind = ClassifyDelta(current, target)
            local color = DELTA_COLORS[kind]

            row.label:SetText(STAT_LABELS[statKey] or statKey)
            row.valueText:SetText(string.format("%d / %d", current, target))
            row.valueText:SetTextColor(color[1], color[2], color[3])
            row.bar:SetMinMaxValues(0, math.max(target, current, 1))
            row.bar:SetValue(current)
            row.bar:SetStatusBarColor(color[1], color[2], color[3])

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -(visibleCount - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", body, "RIGHT", 0, 0)
            row:Show()
        end
    end
    for i = visibleCount + 1, MAX_ROWS do
        rows[i]:Hide()
    end
    return visibleCount
end

local function ShowFallback(text)
    for i = 1, MAX_ROWS do rows[i]:Hide() end
    fallbackText:SetText(text)
    fallbackText:Show()
    body:SetHeight(20)
end

local function Refresh()
    fallbackText:Hide()

    if not G.IsOwnSpecSelected() then
        contextDropdown:Hide()
        ShowFallback("Werteziele zeigen nur deine eigenen Live-Werte — nicht verfügbar für eine andere Spec.")
        G.LayoutGuideTab()
        return
    end

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()
    local specData = GrimoireArchonStats and GrimoireArchonStats[classToken] and GrimoireArchonStats[classToken][specKey]
    if not specData then
        contextDropdown:Hide()
        ShowFallback("Keine Werteziele für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end

    local availableContexts = {}
    for _, ctx in ipairs({ "Mythic+", "Raid" }) do
        if specData[ctx] then table.insert(availableContexts, ctx) end
    end
    if #availableContexts == 0 then
        contextDropdown:Hide()
        ShowFallback("Keine Werteziele für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end

    local found = false
    for _, ctx in ipairs(availableContexts) do
        if ctx == currentContext then found = true break end
    end
    if not found then currentContext = availableContexts[1] end

    local yOffset = 0
    if #availableContexts > 1 then
        contextDropdown:SetText(currentContext)
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(availableContexts) do
                rootDescription:CreateRadio(ctx,
                    function() return currentContext == ctx end,
                    function() currentContext = ctx; Refresh() end)
            end
        end)
        contextDropdown:Show()
        yOffset = 30
    else
        contextDropdown:Hide()
    end

    for i = 1, MAX_ROWS do
        rows[i]:ClearAllPoints()
    end

    if InCombatLockdown() then
        ShowFallback("Werteziele können im Kampf nicht aktualisiert werden.")
        fallbackText:ClearAllPoints()
        fallbackText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -yOffset)
        fallbackText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
        body:SetHeight(yOffset + 20)
        G.LayoutGuideTab()
        return
    end

    local snapshot = specData[currentContext]
    local offsetBody = CreateFrame("Frame", nil, body)
    offsetBody:SetPoint("TOPLEFT", 0, -yOffset)
    offsetBody:SetPoint("RIGHT", 0, 0)
    for i = 1, MAX_ROWS do
        rows[i]:SetParent(offsetBody)
    end
    local count = RenderRows(snapshot)
    body:SetHeight(yOffset + count * ROW_HEIGHT)
    G.LayoutGuideTab()
end

G.SetGuideSectionBody("statTargets", body)

G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(function() Refresh() end)

local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatcher:RegisterEvent("COMBAT_RATING_UPDATE")
combatWatcher:SetScript("OnEvent", function()
    if G.panel:IsShown() and G.GetActiveTab() == "guide" then
        Refresh()
    end
end)
