local ADDON_NAME, G = ...

-- Ordnet einen Wowhead-Statnamen (englisch, wie vom Scraper geliefert)
-- unserem internen Statschlüssel zu. Teilstring-Suche statt exaktem
-- Abgleich, weil Wowhead je nach Quelle "Crit", "Critical Strike" oder
-- "Crit Rating" schreibt -- exakter Abgleich hätte das verpasst.
local function ClassifyStatName(name)
    local lower = name:lower()
    if lower:find("mastery") then return "mastery"
    elseif lower:find("haste") then return "haste"
    elseif lower:find("crit") then return "crit"
    elseif lower:find("versatility") then return "versatility"
    end
    return nil
end

-- Teilstrings, an denen wir die jeweilige Statzeile im (lokalisierten)
-- Tooltip-Text erkennen. Deutsche Client-Begriffe.
local STAT_NAME_SUBSTRING = {
    mastery = "meisterschaft",
    haste = "tempo",
    crit = "kritisch",
    versatility = "vielseitigkeit",
}

-- Ermittelt Rang 1..4 je Statschlüssel aus den priorities-Daten der
-- angegebenen Klasse/Spec. Nimmt den ersten passenden Kontext -- für einen
-- schnellen Tooltip-Blick reicht das, eine Kontext-Auswahl wäre hier
-- übertrieben.
local function GetPriorityRanks(classToken, specKey, heroTalent)
    local specData = GrimoireData and GrimoireData[classToken] and GrimoireData[classToken][specKey]
    if not specData or not specData.priorities then return nil end

    local entry
    for _, e in ipairs(specData.priorities) do
        if e.heroTalent == nil or e.heroTalent == heroTalent then
            entry = e
            break
        end
    end
    -- Kein universeller/passender Eintrag gefunden -- als Fallback fuer den
    -- Tooltip einfach den ersten verfuegbaren nehmen, besser als gar keine
    -- Rang-Anzeige.
    if not entry and specData.priorities[1] then
        entry = specData.priorities[1]
    end
    if not entry then return nil end

    local ranks = {}
    for i, group in ipairs(entry.stats) do
        for _, statName in ipairs(group) do
            local key = ClassifyStatName(statName)
            if key then ranks[key] = i end
        end
    end
    return ranks
end

-- Fuegt "#N" direkt hinter das erkannte Statwort in einer Tooltip-Zeile ein.
-- Deckt auch kombinierte Zeilen ("Tempo und kritischer Trefferwert") ab,
-- indem bis zum naechsten " und " (oder Zeilenende) geschnitten wird.
local function AppendRankToLine(fontString, statKey, rank)
    local text = fontString:GetText()
    if not text then return end

    local pattern = STAT_NAME_SUBSTRING[statKey]
    local lowerText = text:lower()
    local wordPos = lowerText:find(pattern, 1, true)
    if not wordPos then return end

    local wordEnd = wordPos + #pattern
    local cutPos = lowerText:find(" und ", wordEnd, true) or (#text + 1)

    local color = G.RANK_COLORS[rank] or G.RANK_COLORS[5]
    local hexColor = string.format("%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)

    local segment = text:sub(wordPos, cutPos - 1)
    if segment:find("|cff%x%x%x%x%x%x#%d+|r") then return end

    local before = text:sub(1, cutPos - 1)
    local after = text:sub(cutPos)
    fontString:SetText(before .. " |cff" .. hexColor .. "#" .. rank .. "|r" .. after)
end

local function GetDisplayedItemLink(tooltip)
    -- Moderne Tooltip-API: funktioniert auch mit ShoppingTooltip/Comparison-Tooltips.
    if TooltipUtil and TooltipUtil.GetDisplayedItem then
        local _, itemLink = TooltipUtil.GetDisplayedItem(tooltip)
        if itemLink then return itemLink end
    end

    -- Fallback fuer Tooltip-Typen/Clients, die GetItem noch anbieten.
    if tooltip.GetItem then
        local _, itemLink = tooltip:GetItem()
        if itemLink then return itemLink end
    end

    -- Weiterer Fallback ueber die TooltipData-Struktur.
    if tooltip.GetTooltipData then
        local data = tooltip:GetTooltipData()
        if data and data.hyperlink then
            return data.hyperlink
        end
    end

    return nil
end

local function OnTooltipSetItem(tooltip)
    if not G.db or not G.db.showStatPriorityInTooltips then return end

    local itemLink = GetDisplayedItemLink(tooltip)
    if not itemLink then return end

    local itemStats = C_Item.GetItemStats(itemLink)
    if not itemStats then return end

    local _, classToken = UnitClass("player")
    local specKey = G.GetOwnSpecKey and G.GetOwnSpecKey()
    if not classToken or not specKey then return end

    local ranks = GetPriorityRanks(classToken, specKey, nil)
    if not ranks then return end

    -- Nur fuer Statkategorien einfuegen, die das Item tatsaechlich hat.
    local relevantRanks = {}
    if itemStats["ITEM_MOD_MASTERY_RATING_SHORT"] and ranks.mastery then
        relevantRanks.mastery = ranks.mastery
    end
    if itemStats["ITEM_MOD_HASTE_RATING_SHORT"] and ranks.haste then
        relevantRanks.haste = ranks.haste
    end
    if itemStats["ITEM_MOD_CRIT_RATING_SHORT"] and ranks.crit then
        relevantRanks.crit = ranks.crit
    end
    if itemStats["ITEM_MOD_VERSATILITY"] and ranks.versatility then
        relevantRanks.versatility = ranks.versatility
    end
    if not next(relevantRanks) then return end

    local tooltipName = tooltip.GetName and tooltip:GetName()
    if not tooltipName then return end

    for i = 2, tooltip:NumLines() do
        local fs = _G[tooltipName .. "TextLeft" .. i]
        if fs then
            for statKey, rank in pairs(relevantRanks) do
                AppendRankToLine(fs, statKey, rank)
            end
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
