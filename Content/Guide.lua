local ADDON_NAME, G = ...

local guideFrame = CreateFrame("Frame", "GrimoireGuideTab", G.panel)
guideFrame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
guideFrame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
-- KEIN BOTTOM-Anchor mehr: guideFrame bekommt seine Höhe explizit über
-- SetHeight() in LayoutGuideTab() aus der Summe seiner Abschnitte. Ein
-- zusätzlicher BOTTOM-Anchor an G.panel würde das wieder überschreiben
-- (WoW priorisiert zwei gegenüberliegende Anker vor SetHeight) und den
-- Inhalt wieder auf die Panel-Höhe zwingen statt umgekehrt.

local SECTION_GAP = 8

local function MakePlaceholderBody(parent, text)
    local body = CreateFrame("Frame", nil, parent)
    body:SetHeight(40)
    local fs = body:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", 4, -4)
    fs:SetPoint("RIGHT", -4, 0)
    fs:SetJustifyH("LEFT")
    fs:SetTextColor(0.5, 0.5, 0.5)
    fs:SetText(text)
    return body
end

-- key -> { section, content, body }. Von aussen (Content/StatTargets.lua
-- etc.) ueber G.SetGuideSectionBody() befuellbar.
G.GuideSections = {}

local function LayoutGuideTab()
    local totalHeight = 0
    for _, key in ipairs(G.GuideSectionOrder) do
        local entry = G.GuideSections[key]
        entry.section:ClearAllPoints()
        entry.section:SetPoint("TOPLEFT", guideFrame, "TOPLEFT", 0, -totalHeight)
        entry.section:SetPoint("RIGHT", guideFrame, "RIGHT", 0, 0)

        local sectionHeight = 22 -- Header-Höhe
        if not entry.section.IsCollapsed() then
            sectionHeight = sectionHeight + (entry.body and entry.body:GetHeight() or 0)
        end
        entry.section:SetHeight(sectionHeight)

        totalHeight = totalHeight + sectionHeight + SECTION_GAP
    end
    if totalHeight > 0 then
        totalHeight = totalHeight - SECTION_GAP -- kein Gap nach der letzten Section
    end

    guideFrame:SetHeight(totalHeight)
    -- Nur anfassen, wenn dieser Tab gerade aktiv ist -- sonst würde ein
    -- Hintergrund-Refresh (z.B. StatTargets.lua bei COMBAT_RATING_UPDATE,
    -- während z.B. BiS-Gear sichtbar ist) die Panel-Höhe verstellen, obwohl
    -- der Guide-Tab-Inhalt gar nicht zu sehen ist.
    if G.SetPanelContentHeight and (not G.GetActiveTab or G.GetActiveTab() == "guide") then
        G.SetPanelContentHeight(totalHeight)
    end
end
G.LayoutGuideTab = LayoutGuideTab

-- Ersetzt den aktuellen Inhalt eines Guide-Abschnitts (z.B. Platzhalter durch
-- echte, mit Daten befuellte Darstellung) und layoutet neu.
function G.SetGuideSectionBody(key, newBody)
    local entry = G.GuideSections[key]
    if not entry then return end
    if entry.body and entry.body ~= newBody then
        entry.body:Hide()
    end
    entry.body = newBody
    newBody:ClearAllPoints()
    newBody:SetPoint("TOPLEFT", 0, 0)
    newBody:SetPoint("RIGHT", 0, 0)
    newBody:Show()
    LayoutGuideTab()
end

local function AddSection(key, title, placeholderText)
    local section, header, content = G.UI.CreateCollapsibleSection({
        parent = guideFrame,
        title = title,
        onToggle = LayoutGuideTab,
    })
    local body = MakePlaceholderBody(content, placeholderText)
    body:SetPoint("TOPLEFT", 0, 0)
    body:SetPoint("RIGHT", 0, 0)

    G.GuideSections[key] = { section = section, content = content, body = body }
end

-- Reihenfolge gemäß Spezifikation: Werteziele, Wertepriorität, Omnium Folio.
G.GuideSectionOrder = { "statTargets", "statPriority", "omniumFolio" }
AddSection("statTargets", "Werteziele", "Werteziele werden geladen, sobald Daten für diese Spec verfügbar sind.")
AddSection("statPriority", "Wertepriorität", "Wertepriorität wird geladen, sobald Daten für diese Spec verfügbar sind.")
AddSection("omniumFolio", "Omnium Folio", "Omnium-Folio-Empfehlungen werden geladen, sobald Daten für diese Spec verfügbar sind.")

LayoutGuideTab()
G.RegisterTabContent("guide", guideFrame)
G.SetActiveTab("guide")

-- Guide-Tab war evtl. im Hintergrund und der Guard in LayoutGuideTab() hat
-- G.SetPanelContentHeight() deshalb übersprungen -- beim Aktivwerden einmal
-- nachholen, damit die Panel-Höhe wieder zum tatsächlich sichtbaren Inhalt passt.
if G.RegisterOnActiveTabChanged then
    G.RegisterOnActiveTabChanged(function(tabKey)
        if tabKey == "guide" then
            LayoutGuideTab()
        end
    end)
end
