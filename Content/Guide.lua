local ADDON_NAME, G = ...

local guideFrame = CreateFrame("Frame", "GrimoireGuideTab", G.panel)
guideFrame:SetPoint("TOPLEFT", G.selectorBar, "BOTTOMLEFT", 0, -20)
guideFrame:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
guideFrame:SetPoint("BOTTOM", G.panel, "BOTTOM", 0, 16)

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
    local y = 0
    for _, key in ipairs(G.GuideSectionOrder) do
        local entry = G.GuideSections[key]
        entry.section:ClearAllPoints()
        entry.section:SetPoint("TOPLEFT", guideFrame, "TOPLEFT", 0, y)
        entry.section:SetPoint("RIGHT", guideFrame, "RIGHT", 0, 0)

        local sectionHeight = 22 -- Header-Höhe
        if not entry.section.IsCollapsed() then
            sectionHeight = sectionHeight + (entry.body and entry.body:GetHeight() or 0)
        end
        entry.section:SetHeight(sectionHeight)

        y = y - sectionHeight - SECTION_GAP
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
