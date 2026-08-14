local ADDON_NAME, G = ...

local body = CreateFrame("Frame", nil, G.GuideSections.omniumFolio.content)
body:SetHeight(20)

local ROW_HEIGHT = 20
local ICON_SIZE = 16
local LABEL_WIDTH = 90

local rows = {}

local fallbackText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

-- Icon-Textur ist API-übergreifend robust: neuere Clients liefern sie über
-- C_Spell.GetSpellTexture, ältere über das globale GetSpellTexture. Fällt
-- beides aus (z.B. ungültige spellId), zeigen wir ein Fragezeichen-Icon
-- statt eines leeren Frames.
local function GetIconTexture(spellId)
    if C_Spell and C_Spell.GetSpellTexture then
        local tex = C_Spell.GetSpellTexture(spellId)
        if tex then return tex end
    end
    if GetSpellTexture then
        local tex = GetSpellTexture(spellId)
        if tex then return tex end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Die Scraper-Daten (entry.name) sind Rohtext von Wowhead, also englisch.
-- Der Tooltip zeigt trotzdem schon deutsche Namen an, weil GameTooltip:
-- SetSpellByID() Blizzards eigene, client-lokalisierte Datenbank nutzt --
-- dieselbe Quelle fragen wir hier für den Zeilentext ab, damit beides
-- konsistent deutsch ist. entry.name bleibt nur als Fallback, falls der
-- Client den Spell (noch) nicht kennt (z.B. sehr neue Season-Runen).
local function GetLocalizedSpellName(spellId, fallbackName)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellId)
        if info and info.name then return info.name end
    end
    if GetSpellInfo then
        local name = GetSpellInfo(spellId)
        if name then return name end
    end
    return fallbackName
end

local function CreateRow(i)
    local row = CreateFrame("Frame", nil, body)
    row:SetHeight(ROW_HEIGHT)

    local iconButton = CreateFrame("Button", nil, row)
    iconButton:SetSize(ICON_SIZE, ICON_SIZE)
    iconButton:SetPoint("LEFT", 0, 0)

    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
    iconTexture:SetAllPoints()
    iconButton.texture = iconTexture

    iconButton:SetScript("OnEnter", function(self)
        if not self.spellId then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(self.spellId)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", GameTooltip_Hide)
    row.iconButton = iconButton

    local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelText:SetPoint("LEFT", iconButton, "RIGHT", 6, 0)
    labelText:SetWidth(LABEL_WIDTH)
    labelText:SetJustifyH("LEFT")
    labelText:SetWordWrap(false)
    row.labelText = labelText

    -- KEIN Wortumbruch: die Zeile ist fest auf ROW_HEIGHT (eine Zeile) hoch.
    -- Bricht der Text um, überlappt er die nächste Zeile (genau das war
    -- der gemeldete Bug bei längeren -- v.a. englischen -- Runennamen). Bei
    -- zu langen Namen wird lieber rechts abgeschnitten als umgebrochen.
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", labelText, "RIGHT", 4, 0)
    nameText:SetPoint("RIGHT", 0, 0)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    row:Hide()
    rows[i] = row
    return row
end

local function ShowFallback(text)
    for _, row in ipairs(rows) do row:Hide() end
    fallbackText:ClearAllPoints()
    fallbackText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
    fallbackText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
    fallbackText:SetText(text)
    fallbackText:Show()
    body:SetHeight((fallbackText:GetStringHeight() or 14) + 6)
end

local function Refresh()
    fallbackText:Hide()

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()
    local entries = GrimoireOmniumFolio and GrimoireOmniumFolio[classToken] and GrimoireOmniumFolio[classToken][specKey]

    if not entries or #entries == 0 then
        ShowFallback("Kein Omnium Folio für diese Spec verfügbar.")
        G.LayoutGuideTab()
        return
    end

    for i, entry in ipairs(entries) do
        local row = rows[i] or CreateRow(i)

        row.iconButton.spellId = entry.spellId
        row.iconButton.texture:SetTexture(GetIconTexture(entry.spellId))
        row.labelText:SetText(entry.label)
        row.nameText:SetText(GetLocalizedSpellName(entry.spellId, entry.name))

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row:SetPoint("RIGHT", body, "RIGHT", 0, 0)
        row:Show()
    end
    for i = #entries + 1, #rows do
        rows[i]:Hide()
    end

    body:SetHeight(#entries * ROW_HEIGHT)
    G.LayoutGuideTab()
end

G.SetGuideSectionBody("omniumFolio", body)

G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(Refresh)
