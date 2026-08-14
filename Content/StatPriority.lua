local ADDON_NAME, G = ...

local body = CreateFrame("Frame", nil, G.GuideSections.statPriority.content)
body:SetHeight(20)

local DD_HEIGHT = 24
local DD_GAP = 6

local heroDropdown = CreateFrame(
    "DropdownButton",
    "GrimoireStatPriorityHeroDD",
    body,
    "WowStyle1DropdownTemplate"
)
heroDropdown:SetPoint("TOPLEFT", 0, 0)
heroDropdown:SetSize(178, DD_HEIGHT)
heroDropdown:Hide()

local contextDropdown = CreateFrame(
    "DropdownButton",
    "GrimoireStatPriorityContextDD",
    body,
    "WowStyle1DropdownTemplate"
)
contextDropdown:SetPoint("LEFT", heroDropdown, "RIGHT", 8, 0)
contextDropdown:SetSize(140, DD_HEIGHT)
contextDropdown:Hide()

-- Eine kompakte Prioritätszeile statt nummerierter Einzelzeilen:
-- Tempo > Krit > Meisterschaft = Vielseitigkeit
local priorityText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
priorityText:SetJustifyH("LEFT")
priorityText:SetJustifyV("TOP")
priorityText:SetWordWrap(true)
priorityText:Hide()

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

local selectedHero      -- interner EN-Wowhead-Key aus guide.lua
local selectedContext
local heroManuallySelected = false

local RANK_COLORS = G.RANK_COLORS

-- ============================================================
-- Hero-Talent Anzeige
-- ============================================================
-- Namen bleiben deutsch, Icons werden NICHT geraten.
-- Wenn der Scraper heroTalentIcon mitspeichert, wird genau dieses Symbol
-- verwendet. Alte guide.lua-Dateien ohne heroTalentIcon funktionieren
-- weiterhin, nur eben ohne Icon.

local HERO_TALENT_DE = {
    ["Deathbringer"] = "Todesbringer",
    ["Rider of the Apocalypse"] = "Reiter der Apokalypse",
    ["San'layn"] = "San'layn",

    ["Aldrachi Reaver"] = "Häscher der Aldrachi",
    ["Fel-Scarred"] = "Teufelsgezeichnet",
    ["Void-Scarred"] = "Leerenvernarbt",
    ["Annihilator"] = "Vernichter",

    ["Keeper of the Grove"] = "Hüter des Hains",
    ["Elune's Chosen"] = "Auserwählter Elunes",
    ["Wildstalker"] = "Wildpirscher",
    ["Druid of the Claw"] = "Druide der Klaue",

    ["Chronowarden"] = "Chronowächter",
    ["Flameshaper"] = "Flammenformer",
    ["Scalecommander"] = "Schuppenkommandant",

    ["Dark Ranger"] = "Dunkler Waldläufer",
    ["Pack Leader"] = "Rudelführer",
    ["Sentinel"] = "Wächter",

    ["Frostfire"] = "Frostfeuer",
    ["Spellslinger"] = "Zauberwerfer",
    ["Sunfury"] = "Sonnenzorn",

    ["Conduit of the Celestials"] = "Medium der Erhabenen",
    ["Master of Harmony"] = "Meister der Harmonie",
    ["Shado-Pan"] = "Shado-Pan",

    ["Herald of the Sun"] = "Herold der Sonne",
    ["Lightsmith"] = "Lichtschmied",
    ["Templar"] = "Templer",

    ["Archon"] = "Archon",
    ["Oracle"] = "Orakel",
    ["Voidweaver"] = "Leerenweber",

    ["Deathstalker"] = "Todespirscher",
    ["Fatebound"] = "Schicksalsgebundener",
    ["Trickster"] = "Trixer",

    ["Farseer"] = "Scharfseher",
    ["Stormbringer"] = "Sturmbringer",
    ["Totemic"] = "Totemiker",

    ["Diabolist"] = "Diaboliker",
    ["Hellcaller"] = "Höllenrufer",
    ["Soul Harvester"] = "Seelenernter",

    ["Colossus"] = "Koloss",
    ["Mountain Thane"] = "Bergthan",
    ["Slayer"] = "Schlächter",
}

local function LocalizeHeroName(heroKey)
    return HERO_TALENT_DE[heroKey] or heroKey or ""
end

local function FindHeroIconInPriorities(priorities, heroKey)
    for _, entry in ipairs(priorities or {}) do
        if entry.heroTalent == heroKey and entry.heroTalentIcon then
            return entry.heroTalentIcon
        end
    end
    return nil
end

local function HeroDisplayText(priorities, heroKey)
    local name = LocalizeHeroName(heroKey)
    local icon = FindHeroIconInPriorities(priorities, heroKey)

    if icon and icon ~= "" then
        -- Wowhead [symbol=wow-hero-talent-*] entspricht einem Blizzard-Atlas.
        return string.format("|A:%s:18:18|a %s", icon, name)
    end

    return name
end

-- ============================================================
-- Lokalisierung
-- ============================================================

local STAT_TRANSLATIONS = {
    ["intellect"] = "Intelligenz",
    ["agility"] = "Beweglichkeit",
    ["strength"] = "Stärke",
    ["haste"] = "Tempo",
    ["critical strike"] = "Kritischer Trefferwert",
    ["crit"] = "Kritischer Trefferwert",
    ["mastery"] = "Meisterschaft",
    ["versatility"] = "Vielseitigkeit",
}

local CONTEXT_TRANSLATIONS = {
    ["General"] = "Allgemein",
    ["Dungeons"] = "Dungeons",
    ["Dungeon"] = "Dungeon",
    ["Raid"] = "Raid",
    ["Raids"] = "Raids",
    ["Defensive"] = "Defensiv",
    ["Offensive"] = "Offensiv",
}

local function LocalizeStat(raw)
    if not raw or raw == "" then return "" end

    -- Breakpoints wie "(bis 800)" / "(ab 800)" erhalten.
    local base, suffix = raw:match("^%s*(.-)%s*(%b())%s*$")
    if not base then
        base = raw
        suffix = ""
    end

    local amount, prefixedStat = base:match(
        "^(%d+(?:%.%d+)?)%s+(.+)$"
    )

    local translated
    if amount and prefixedStat then
        translated = amount
            .. " "
            .. (
                STAT_TRANSLATIONS[prefixedStat:lower()]
                or prefixedStat
            )
    else
        translated = STAT_TRANSLATIONS[base:lower()]
            or base
    end

    if suffix and suffix ~= "" then
        return translated .. " " .. suffix
    end

    return translated
end

local function LocalizeContext(context)
    return CONTEXT_TRANSLATIONS[context] or context
end

local function ColorHex(color)
    color = color or { 1, 1, 1 }
    return string.format(
        "%02x%02x%02x",
        math.floor((color[1] or 1) * 255 + 0.5),
        math.floor((color[2] or 1) * 255 + 0.5),
        math.floor((color[3] or 1) * 255 + 0.5)
    )
end

local OPERATOR_DISPLAY = {
    [">"]  = ">",
    [">="] = "≥",
    [">>"] = "»",
}

local function FormatStatGroups(groups, operators, colored)
    local parts = {}

    for groupIndex, group in ipairs(groups or {}) do
        local equalParts = {}
        local color = RANK_COLORS[groupIndex]
            or RANK_COLORS[5]
            or { 1, 1, 1 }
        local hex = ColorHex(color)

        for _, rawStat in ipairs(group) do
            local stat = LocalizeStat(rawStat)

            if colored then
                stat = "|cff" .. hex .. stat .. "|r"
            end

            equalParts[#equalParts + 1] = stat
        end

        parts[#parts + 1] = table.concat(
            equalParts,
            " |cffb8b8b8=|r "
        )
    end

    if #parts == 0 then
        return ""
    end

    local result = parts[1]

    for i = 2, #parts do
        local rawOperator = operators
            and operators[i - 1]
            or ">"
        local displayOperator = OPERATOR_DISPLAY[rawOperator]
            or rawOperator
            or ">"

        result = result
            .. " |cffffd100"
            .. displayOperator
            .. "|r "
            .. parts[i]
    end

    return result
end

-- ============================================================
-- Hero-Talente
-- ============================================================

local function HeroMatches(entryHero, hero)
    return entryHero == nil or entryHero == hero
end

local function GetHeroOptions(priorities)
    local seen, options = {}, {}
    for _, entry in ipairs(priorities) do
        if entry.heroTalent and not seen[entry.heroTalent] then
            seen[entry.heroTalent] = true
            options[#options + 1] = entry.heroTalent
        end
    end
    return options
end


local function FindHeroDataByKey(heroData, key)
    for _, data in ipairs(heroData or {}) do
        if data.key == key then return data end
    end
    return nil
end

local function SelectActiveHeroIfPossible(classToken, specKey, heroData)
    if heroManuallySelected then return false end
    if not GetOwnSelectedSpecMatches(classToken, specKey) then return false end
    if not C_ClassTalents or not C_ClassTalents.GetActiveHeroTalentSpec then
        return false
    end

    local activeSubTreeID = C_ClassTalents.GetActiveHeroTalentSpec()
    if not activeSubTreeID then return false end

    for _, data in ipairs(heroData or {}) do
        if data.subTreeID == activeSubTreeID then
            selectedHero = data.key
            return true
        end
    end

    return false
end

-- ============================================================
-- Datenwahl
-- ============================================================

local function GetContextOptions(priorities, hero)
    local seen, options = {}, {}
    for _, entry in ipairs(priorities) do
        if HeroMatches(entry.heroTalent, hero) and not seen[entry.context] then
            seen[entry.context] = true
            options[#options + 1] = entry.context
        end
    end
    return options
end

local function FindEntry(priorities, hero, context)
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

local function DaysSince(isoDate)
    local y, m, d = isoDate:match("(%d+)-(%d+)-(%d+)")
    if not y then return nil end

    local changedTime = time({
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = 0,
    })
    return math.floor((time() - changedTime) / 86400)
end

local function ShowFallback(text)
    priorityText:Hide()
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
    priorityText:Hide()
    diffText:Hide()
    heroDropdown:Hide()
    contextDropdown:Hide()

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()
    local specData = GrimoireData
        and GrimoireData[classToken]
        and GrimoireData[classToken][specKey]
    local priorities = specData and specData.priorities

    if not priorities or #priorities == 0 then
        ShowFallback("Keine Wertepriorität für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end

    local heroOptions = GetHeroOptions(priorities)
    local yOffset = 0

    if #heroOptions > 0 then
        -- Beim ersten Öffnen der eigenen Spec automatisch den aktuell
        -- tatsächlich gespielten Hero-Baum wählen.
        local found = false
        for _, h in ipairs(heroOptions) do
            if h == selectedHero then
                found = true
                break
            end
        end

        if not found then
            selectedHero = heroOptions[1]
        end

        heroDropdown:SetText(
            HeroDisplayText(priorities, selectedHero)
        )

        heroDropdown:SetupMenu(function(_, rootDescription)
            for _, h in ipairs(heroOptions) do
                rootDescription:CreateRadio(
                    HeroDisplayText(priorities, h),
                    function()
                        return selectedHero == h
                    end,
                    function()
                        selectedHero = h
                        heroManuallySelected = true
                        selectedContext = nil
                        Refresh()
                    end
                )
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
        if c == selectedContext then
            foundCtx = true
            break
        end
    end
    if not foundCtx then
        selectedContext = contextOptions[1]
    end

    if #heroOptions > 0 or #contextOptions > 1 then
        yOffset = DD_HEIGHT + DD_GAP
    end

    if #contextOptions > 1 then
        contextDropdown:SetText(LocalizeContext(selectedContext))
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, c in ipairs(contextOptions) do
                rootDescription:CreateRadio(
                    LocalizeContext(c),
                    function()
                        return selectedContext == c
                    end,
                    function()
                        selectedContext = c
                        Refresh()
                    end
                )
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

    priorityText:ClearAllPoints()
    priorityText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -yOffset)
    priorityText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
    priorityText:SetText(FormatStatGroups(entry.stats, entry.operators, true))
    priorityText:Show()

    local priorityHeight = math.max(20, priorityText:GetStringHeight() or 20)
    local totalHeight = yOffset + priorityHeight

    if entry.previousStats and entry.changedDate then
        local days = DaysSince(entry.changedDate)
        if days and days >= 0 then
            local dayText = days == 0 and "heute" or ("vor " .. days .. " Tagen")

            diffText:ClearAllPoints()
            diffText:SetPoint(
                "TOPLEFT",
                body,
                "TOPLEFT",
                0,
                -(totalHeight + 7)
            )
            diffText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
            diffText:SetText(string.format(
                "Wertepriorität %s geändert\nVorher: %s",
                dayText,
                FormatStatGroups(entry.previousStats, entry.previousOperators, false)
            ))
            diffText:Show()

            totalHeight = totalHeight
                + (diffText:GetStringHeight() or 14)
                + 14
        end
    end

    body:SetHeight(totalHeight)
    G.LayoutGuideTab()
end

G.SetGuideSectionBody("statPriority", body)

G.RegisterOnDatabaseReady(Refresh)

G.RegisterOnSelectionChanged(function()
    selectedHero = nil
    selectedContext = nil
    heroManuallySelected = false
    Refresh()
end)

-- Wenn der Spieler sein Loadout/Hero-Talent wechselt, soll beim nächsten
-- Refresh wieder automatisch der tatsächlich aktive Hero-Baum vorausgewählt
-- werden.
local talentWatcher = CreateFrame("Frame")
talentWatcher:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
talentWatcher:RegisterEvent("SELECTED_LOADOUT_CHANGED")
talentWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
talentWatcher:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_SPECIALIZATION_CHANGED"
        and unit
        and unit ~= "player"
    then
        return
    end

    if G.GetSelectedClass and G.GetSelectedSpec then
        local classToken = G.GetSelectedClass()
        local specKey = G.GetSelectedSpec()

        if GetOwnSelectedSpecMatches(classToken, specKey) then
            selectedHero = nil
            selectedContext = nil
            heroManuallySelected = false

            if G.panel and G.panel:IsShown()
                and (not G.GetActiveTab or G.GetActiveTab() == "guide")
            then
                C_Timer.After(0.05, Refresh)
            end
        end
    end
end)
