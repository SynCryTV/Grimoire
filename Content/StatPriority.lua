local ADDON_NAME, G = ...

local body = CreateFrame("Frame", nil, G.GuideSections.statPriority.content)
body:SetHeight(20)

local MAX_ROWS = 5
local ROW_HEIGHT = 20
local DD_HEIGHT = 24
local DD_GAP = 6

local heroDropdown = CreateFrame("DropdownButton", "GrimoireStatPriorityHeroDD", body, "WowStyle1DropdownTemplate")
heroDropdown:SetPoint("TOPLEFT", 0, 0)
heroDropdown:SetSize(140, DD_HEIGHT)
heroDropdown:Hide()

local contextDropdown = CreateFrame("DropdownButton", "GrimoireStatPriorityContextDD", body, "WowStyle1DropdownTemplate")
contextDropdown:SetPoint("LEFT", heroDropdown, "RIGHT", 8, 0)
contextDropdown:SetSize(140, DD_HEIGHT)
contextDropdown:Hide()

local rows = {}
for i = 1, MAX_ROWS do
    local row = CreateFrame("Frame", nil, body)
    row:SetHeight(ROW_HEIGHT)

    local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rank:SetPoint("TOPLEFT", 0, 0)
    rank:SetWidth(20)
    rank:SetJustifyH("LEFT")
    row.rank = rank

    local statName = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statName:SetPoint("TOPLEFT", rank, "TOPRIGHT", 4, 0)
    statName:SetPoint("RIGHT", 0, 0)
    statName:SetJustifyH("LEFT")
    row.statName = statName

    row:Hide()
    rows[i] = row
end

local diffText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
diffText:SetJustifyH("LEFT")
diffText:SetJustifyV("TOP")
diffText:SetWordWrap(true)
diffText:SetTextColor(0.95, 0.78, 0.35)
diffText:Hide()

local fallbackText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

local selectedHero    -- aktuell gewähltes Hero-Talent (nil = "alle/universell")
local selectedContext

local RANK_COLORS = G.RANK_COLORS

-- Ein priorities-Eintrag ohne heroTalent gilt als universell und matcht
-- jede Hero-Talent-Auswahl (inklusive "keine Auswahl getroffen").
local function HeroMatches(entryHero, hero)
    return entryHero == nil or entryHero == hero
end

local function GetHeroOptions(priorities)
    local seen, options = {}, {}
    for _, entry in ipairs(priorities) do
        if entry.heroTalent and not seen[entry.heroTalent] then
            seen[entry.heroTalent] = true
            table.insert(options, entry.heroTalent)
        end
    end
    return options
end

local function GetContextOptions(priorities, hero)
    local seen, options = {}, {}
    for _, entry in ipairs(priorities) do
        if HeroMatches(entry.heroTalent, hero) and not seen[entry.context] then
            seen[entry.context] = true
            table.insert(options, entry.context)
        end
    end
    return options
end

local function FindEntry(priorities, hero, context)
    -- Bevorzugt einen Eintrag mit exakt passendem Hero-Talent; erst danach
    -- einen universellen (heroTalent == nil) als Fallback.
    local fallback
    for _, entry in ipairs(priorities) do
        if entry.context == context then
            if entry.heroTalent == hero then
                return entry
            elseif entry.heroTalent == nil then
                fallback = fallback or entry
            end
        end
    end
    return fallback
end

local function FormatStatGroups(groups)
    local parts = {}
    for _, group in ipairs(groups) do
        table.insert(parts, table.concat(group, " / "))
    end
    return table.concat(parts, " > ")
end

local function DaysSince(isoDate)
    local y, m, d = isoDate:match("(%d+)-(%d+)-(%d+)")
    if not y then return nil end
    local changedTime = time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0 })
    return math.floor((time() - changedTime) / 86400)
end

local function ShowFallback(text)
    for i = 1, MAX_ROWS do rows[i]:Hide() end
    diffText:Hide()
    fallbackText:ClearAllPoints()
    fallbackText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
    fallbackText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
    fallbackText:SetText(text)
    fallbackText:Show()
    body:SetHeight((fallbackText:GetStringHeight() or 14) + 6)
end

local function Refresh()
    fallbackText:Hide()
    diffText:Hide()
    heroDropdown:Hide()
    contextDropdown:Hide()

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()
    local specData = GrimoireData and GrimoireData[classToken] and GrimoireData[classToken][specKey]
    local priorities = specData and specData.priorities

    if not priorities or #priorities == 0 then
        ShowFallback("Keine Wertepriorität für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end

    local heroOptions = GetHeroOptions(priorities)
    local yOffset = 0

    if #heroOptions > 0 then
        local found = false
        for _, h in ipairs(heroOptions) do
            if h == selectedHero then found = true break end
        end
        if not found then selectedHero = heroOptions[1] end

        heroDropdown:SetText(selectedHero)
        heroDropdown:SetupMenu(function(_, rootDescription)
            for _, h in ipairs(heroOptions) do
                rootDescription:CreateRadio(h,
                    function() return selectedHero == h end,
                    function() selectedHero = h; Refresh() end)
            end
        end)
        heroDropdown:Show()
    else
        selectedHero = nil
    end

    local contextOptions = GetContextOptions(priorities, selectedHero)
    if #contextOptions == 0 then
        ShowFallback("Keine Wertepriorität für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end
    local foundCtx = false
    for _, c in ipairs(contextOptions) do
        if c == selectedContext then foundCtx = true break end
    end
    if not foundCtx then selectedContext = contextOptions[1] end

    if #heroOptions > 0 or #contextOptions > 1 then
        yOffset = DD_HEIGHT + DD_GAP
    end

    if #contextOptions > 1 then
        contextDropdown:SetText(selectedContext)
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, c in ipairs(contextOptions) do
                rootDescription:CreateRadio(c,
                    function() return selectedContext == c end,
                    function() selectedContext = c; Refresh() end)
            end
        end)
        contextDropdown:Show()
    end

    local entry = FindEntry(priorities, selectedHero, selectedContext)
    if not entry then
        ShowFallback("Keine Wertepriorität für diese Auswahl verfügbar.")
        G.LayoutGuideTab()
        return
    end

    local count = math.min(#entry.stats, MAX_ROWS)
    for i = 1, count do
        local row = rows[i]
        local color = RANK_COLORS[i] or RANK_COLORS[5]
        row.rank:SetTextColor(color[1], color[2], color[3])
        row.rank:SetText(i .. ".")
        row.statName:SetTextColor(color[1], color[2], color[3])
        row.statName:SetText(table.concat(entry.stats[i], " / "))
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -(yOffset + (i - 1) * ROW_HEIGHT))
        row:SetPoint("RIGHT", body, "RIGHT", 0, 0)
        row:Show()
    end
    for i = count + 1, MAX_ROWS do rows[i]:Hide() end

    local rowsHeight = count * ROW_HEIGHT
    local totalHeight = yOffset + rowsHeight

    if entry.previousStats and entry.changedDate then
        local days = DaysSince(entry.changedDate)
        if days and days >= 0 then
            local dayText = days == 0 and "heute" or ("vor " .. days .. " Tagen")
            diffText:ClearAllPoints()
            diffText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -(totalHeight + 6))
            diffText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
            diffText:SetText(string.format("Wertepriorität %s geändert (vorher: %s)", dayText, FormatStatGroups(entry.previousStats)))
            diffText:Show()
            totalHeight = totalHeight + (diffText:GetStringHeight() or 14) + 14
        end
    end

    body:SetHeight(totalHeight)
    G.LayoutGuideTab()
end

G.SetGuideSectionBody("statPriority", body)

G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(function()
    selectedHero, selectedContext = nil, nil -- bei Klassen-/Spec-Wechsel neu ableiten
    Refresh()
end)
