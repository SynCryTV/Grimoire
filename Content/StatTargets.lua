local ADDON_NAME, G = ...
local L = G.L

local STAT_ORDER = { "mastery", "haste", "crit", "versatility" }
local STAT_LABELS = {
    mastery = "Mastery", haste = "Haste", crit = "Critical Strike", versatility = "Versatility",
}
local STAT_COMBAT_RATING = {
    mastery = CR_MASTERY,
    haste = CR_HASTE_MELEE, -- Melee/Ranged/Spell-Haste nutzen denselben Rating-Wert
    crit = CR_CRIT_MELEE,   -- ebenso für Crit

    -- In Retail/Midnight gibt es keinen zuverlässigen allgemeinen
    -- CR_VERSATILITY-Wert. Für den sichtbaren Versatility-Ratingwert
    -- verwenden wir den Damage-Done-Ratingtyp.
    versatility = CR_VERSATILITY_DAMAGE_DONE or CR_VERSATILITY,
}

local body = CreateFrame("Frame", nil, G.GuideSections.statTargets.content)
body:SetHeight(20)

local CONTEXT_DD_HEIGHT = 24
local LABEL_HEIGHT = 14
local BAR_HEIGHT = 12
local ROW_HEIGHT = LABEL_HEIGHT + 2 + BAR_HEIGHT
local ROW_GAP = 10
local MAX_ROWS = 4

local contextDropdown = CreateFrame("DropdownButton", "GrimoireStatTargetContextDD", body, "WowStyle1DropdownTemplate")
contextDropdown:SetPoint("TOPLEFT", 0, 0)
contextDropdown:SetPoint("TOPRIGHT", -24, 0)
contextDropdown:SetHeight(CONTEXT_DD_HEIGHT)
contextDropdown:Hide()

-- Wird nur eingeblendet, wenn fuer die aktive Raid-Spec noch keine
-- ausreichend belastbaren Mythic-Daten vorliegen. Der HC-Endboss-Fallback
-- ist bewusst kein allgemeiner Fehlerzustand: Er wird ausschliesslich fuer
-- Specs markiert, bei denen der Mythic-Datensatz zu klein war.
local dataWarning = CreateFrame("Button", nil, body)
dataWarning:SetSize(20, 20)
dataWarning:SetPoint("TOPRIGHT", body, "TOPRIGHT", 0, 1)
dataWarning:EnableMouse(true)
local dataWarningText = dataWarning:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
dataWarningText:SetPoint("CENTER", 0, 0)
dataWarningText:SetText(G.L("!"))
dataWarningText:SetTextColor(1.0, 0.78, 0.12)
dataWarning:Hide()

local rows = {}
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
    barBg:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    barBg:SetPoint("RIGHT", 0, 0)
    barBg:SetHeight(BAR_HEIGHT)
    barBg:SetColorTexture(0.08, 0.08, 0.08, 1)
    row.barBg = barBg

    local bar = CreateFrame("StatusBar", nil, row)
    bar:SetPoint("TOPLEFT", barBg, "TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", barBg, "BOTTOMRIGHT", -1, 1)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 1)
    row.bar = bar

    -- Zielmarke: senkrechter Strich genau an der Stelle, wo das Wertziel
    -- innerhalb des Balken-Puffers (siehe BAR_HEADROOM) sitzt. Muss auf dem
    -- Balken selbst (nicht auf row) liegen, sonst zeichnet die Füllung des
    -- Balken-Kindrahmens darüber.
    local tick = bar:CreateTexture(nil, "OVERLAY")
    tick:SetWidth(2)
    tick:SetColorTexture(0.95, 0.86, 0.55, 0.95)
    row.tick = tick

    row:Hide()
    rows[i] = row
end

local fallbackText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackText:SetJustifyH("LEFT")
fallbackText:SetTextColor(0.5, 0.5, 0.5)
fallbackText:Hide()

local currentContext -- "Mythic+" oder "Raid"

local function HasLimitedData(snapshot)
    if not snapshot then return false end

    -- limited wird vom Scraper fuer explizite Fallbacks gesetzt. Die
    -- Quellenprüfung hält bereits ausgelieferte Daten kompatibel, die noch
    -- vor diesem Feld erzeugt wurden.
    if snapshot.limited then return true end
    return snapshot.source == "Warcraft Logs Heroisch-Endboss"
end

local function UpdateDataWarning(snapshot)
    if not HasLimitedData(snapshot) then
        dataWarning:Hide()
        return false
    end

    dataWarning.samples = tonumber(snapshot.samples) or 0
    dataWarning:Show()
    return true
end

dataWarning:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L("Begrenzte Raid-Daten"), 1.0, 0.78, 0.12)
    GameTooltip:AddLine(G.L(" "))
    GameTooltip:AddLine(
        L("Für diese Spec lagen noch nicht genug Mythic-Parse-Samples vor. Die Werteziele verwenden deshalb vorläufig Daten vom heroischen Endboss und können ungenauer sein."),
        0.9, 0.9, 0.9, true
    )
    if self.samples > 0 then
        GameTooltip:AddLine(G.L(string.format(L("Aktuell verwendete Samples: %d"), self.samples)), 0.65, 0.65, 0.65)
    end
    GameTooltip:Show()
end)
dataWarning:SetScript("OnLeave", GameTooltip_Hide)

local function GetLivePlayerStatRating(statKey)
    local ratingIndex = STAT_COMBAT_RATING[statKey]
    if not ratingIndex then
        return nil
    end

    local value = GetCombatRating(ratingIndex)
    if value == nil then
        return nil
    end

    return math.floor(value + 0.5)
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

-- Der Balken zeigt nicht nur bis zum Ziel, sondern noch etwas Puffer
-- darüber (30%), damit optisch sichtbar ist, WIE weit man über dem Ziel
-- liegt, statt einfach nur "voll" zu sein.
local BAR_HEADROOM = 1.3

-- Rendert die Wertezeilen unterhalb von yOffset (Platz fuer die
-- Kontext-Dropdown, falls sichtbar). Alle Positionen werden IMMER relativ
-- zu body neu gesetzt -- kein Zwischen-Rahmen, keine Altlasten von vorherigen
-- Refresh()-Laeufen.
local function RenderRows(snapshot, yOffset)
    local visibleCount = 0
    for _, statKey in ipairs(STAT_ORDER) do
        local target = snapshot.targets and snapshot.targets[statKey]
        target = tonumber(target)
        -- Ein Ziel von 0 ist absichtlich: Es bedeutet nicht, dass der Stat
        -- fehlt. Die Zeile bleibt sichtbar, damit klar ist, dass fuer diesen
        -- Wert aktuell kein Rating angestrebt wird.
        if target ~= nil and target >= 0 then
            visibleCount = visibleCount + 1
            local row = rows[visibleCount]
            local current = GetLivePlayerStatRating(statKey)

            -- Falls Blizzard für einen Ratingtyp temporär noch keinen Wert
            -- liefert, nicht fälschlich "0" anzeigen.
            if current == nil then
                current = 0
            end

            local kind = ClassifyDelta(current, target)
            local color = DELTA_COLORS[kind]

            row.label:SetText(G.L(STAT_LABELS[statKey] or statKey))
            row.valueText:SetText(G.L(string.format("%d / %d", current, target)))
            row.valueText:SetTextColor(color[1], color[2], color[3])

            -- StatusBars benötigen einen positiven Maximalwert. Bei einem
            -- expliziten 0-Ziel bleibt die Zielmarke links, der Balken zeigt
            -- aber weiterhin den eigenen aktuellen Wert als Füllung.
            local barMax = target == 0
                and math.max(current * BAR_HEADROOM, 1)
                or math.max(target * BAR_HEADROOM, 1)
            row.bar:SetMinMaxValues(0, barMax)
            row.bar:SetValue(math.min(current, barMax))
            row.bar:SetStatusBarColor(color[1], color[2], color[3])

            -- GetWidth() ist direkt nach SetPoint() unzuverlässig (WoW
            -- berechnet die tatsächliche Breite erst im naechsten Frame).
            -- Stattdessen die Breite aus der bekannten Panel-Breite ableiten
            -- (Panel minus die festen Seitenabstände entlang der Kette).
            local panelWidth = (G.db and G.db.panelWidth) or G.PANEL_WIDTH_DEFAULT
            local barWidth = panelWidth - 32
            local tickX = (target / barMax) * barWidth
            row.tick:ClearAllPoints()
            row.tick:SetPoint("TOP", row.barBg, "TOPLEFT", tickX, 0)
            row.tick:SetPoint("BOTTOM", row.barBg, "BOTTOMLEFT", tickX, 0)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -(yOffset + (visibleCount - 1) * (ROW_HEIGHT + ROW_GAP)))
            row:SetPoint("RIGHT", body, "RIGHT", 0, 0)
            row:Show()
        end
    end
    for i = visibleCount + 1, MAX_ROWS do
        rows[i]:Hide()
    end
    return visibleCount
end

-- Blendet alle Wertezeilen aus und zeigt stattdessen einen Hinweistext --
-- IMMER an derselben Stelle (direkt unter der Kontext-Dropdown, falls die
-- gerade sichtbar ist), egal welcher Zustand vorher aktiv war.
local function ShowFallback(text, yOffset)
    yOffset = yOffset or 0
    for i = 1, MAX_ROWS do rows[i]:Hide() end
    fallbackText:ClearAllPoints()
    fallbackText:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -yOffset)
    fallbackText:SetPoint("RIGHT", body, "RIGHT", 0, 0)
    fallbackText:SetText(G.L(text))
    fallbackText:Show()
    body:SetHeight(yOffset + (fallbackText:GetStringHeight() or 14) + 6)
end

local function Refresh()
    fallbackText:Hide()
    contextDropdown:Hide()
    dataWarning:Hide()

    if not G.IsOwnClassSelected() then
        ShowFallback(G.L(L("Werteziele zeigen nur deine eigenen Live-Werte — nicht verfügbar für eine andere Klasse.")))
        G.LayoutGuideTab()
        return
    end

    local classToken = G.GetSelectedClass()
    local specKey = G.GetSelectedSpec()
    local specData = GrimoireStatTargets and GrimoireStatTargets[classToken] and GrimoireStatTargets[classToken][specKey]
    if not specData then
        ShowFallback(G.L(L("Keine Werteziele für diese Spec verfügbar.")))
        G.LayoutGuideTab()
        return
    end

    local availableContexts = {}
    for _, ctx in ipairs({ "Mythic+", "Raid" }) do
        if specData[ctx] then table.insert(availableContexts, ctx) end
    end
    if #availableContexts == 0 then
        ShowFallback(G.L(L("Keine Werteziele für diese Spec verfügbar.")))
        G.LayoutGuideTab()
        return
    end

    local found = false
    for _, ctx in ipairs(availableContexts) do
        if ctx == currentContext then found = true break end
    end
    if not found then currentContext = availableContexts[1] end

    local snapshot = specData[currentContext]
    local hasLimitedData = UpdateDataWarning(snapshot)
    local yOffset = 0
    if #availableContexts > 1 then
        contextDropdown:SetText(G.L(currentContext))
        contextDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(availableContexts) do
                rootDescription:CreateRadio(L(ctx),
                    function() return currentContext == ctx end,
                    function() currentContext = ctx; Refresh() end)
            end
        end)
        contextDropdown:Show()
        yOffset = CONTEXT_DD_HEIGHT + 6
    elseif hasLimitedData then
        -- Ohne Kontext-Auswahl bekommt das Symbol eine eigene Zeile, damit
        -- es nie den rechten Live-Wert der ersten Balkenzeile überdeckt.
        yOffset = CONTEXT_DD_HEIGHT
    end

    if InCombatLockdown() then
        ShowFallback(G.L(L("Werteziele können im Kampf nicht aktualisiert werden.")), yOffset)
        G.LayoutGuideTab()
        return
    end

    local count = RenderRows(snapshot, yOffset)
    local rowsHeight = count > 0 and (count * ROW_HEIGHT + (count - 1) * ROW_GAP) or 0
    body:SetHeight(yOffset + rowsHeight)
    G.LayoutGuideTab()
end

G.SetGuideSectionBody("statTargets", body)

G.RegisterOnDatabaseReady(Refresh)
G.RegisterOnSelectionChanged(function() Refresh() end)

local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatcher:RegisterEvent("COMBAT_RATING_UPDATE")
combatWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
combatWatcher:RegisterEvent("UNIT_STATS")
combatWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")

local refreshPending = false

local function QueueLiveRefresh()
    if refreshPending then return end
    refreshPending = true

    C_Timer.After(0.05, function()
        refreshPending = false

        if G.panel:IsShown() and G.GetActiveTab() == "guide" then
            Refresh()
        end
    end)
end

combatWatcher:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_STATS" and unit and unit ~= "player" then
        return
    end

    QueueLiveRefresh()
end)
