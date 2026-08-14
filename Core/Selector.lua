local ADDON_NAME, G = ...

local selectedClassToken   -- z.B. "DEMONHUNTER"
local selectedSpecKey      -- z.B. "devourer"
local ownClassToken, ownSpecKey

-- Setzt die Auswahl zurück auf die aktuell gespielte Klasse/Spec.
local function ResetToOwnSpec()
    local _, classToken = UnitClass("player")
    ownClassToken = classToken
    ownSpecKey = G.GetOwnSpecKey()
    selectedClassToken = ownClassToken
    selectedSpecKey = ownSpecKey
end

function G.GetSelectedClass()
    return selectedClassToken
end

function G.GetSelectedSpec()
    return selectedSpecKey
end

function G.IsOwnSpecSelected()
    return selectedClassToken == ownClassToken and selectedSpecKey == ownSpecKey
end

function G.IsOwnClassSelected()
    return selectedClassToken == ownClassToken
end

local selectionChangedCallbacks = {}
function G.RegisterOnSelectionChanged(callback)
    table.insert(selectionChangedCallbacks, callback)
end
local function FireSelectionChanged(classToken, specKey)
    for _, callback in ipairs(selectionChangedCallbacks) do
        callback(classToken, specKey)
    end
end

function G.SetSelection(classToken, specKey)
    selectedClassToken = classToken
    selectedSpecKey = specKey
    FireSelectionChanged(classToken, specKey)
    if G.RefreshSelectorDropdowns then
        G.RefreshSelectorDropdowns()
    end
end

function G.ResetSelectionToOwnSpec()
    ResetToOwnSpec()
    FireSelectionChanged(selectedClassToken, selectedSpecKey)
    if G.RefreshSelectorDropdowns then
        G.RefreshSelectorDropdowns()
    end
end

-- Sichtbare Auswahl-Leiste oben im Guide-Tab.
local selectorBar = CreateFrame("Frame", "GrimoireSelectorBar", G.panel)
selectorBar:SetHeight(28)
selectorBar:SetPoint("TOPLEFT", G.panel, "TOPLEFT", 16, -16)
selectorBar:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
G.selectorBar = selectorBar

local classDropdown = CreateFrame("DropdownButton", "GrimoireClassDropdown", selectorBar, "WowStyle1DropdownTemplate")
classDropdown:SetPoint("LEFT", 0, 0)
classDropdown:SetSize(140, 24)
G.classDropdown = classDropdown

local specDropdown = CreateFrame("DropdownButton", "GrimoireSpecDropdown", selectorBar, "WowStyle1DropdownTemplate")
specDropdown:SetPoint("LEFT", classDropdown, "RIGHT", 8, 0)
specDropdown:SetSize(140, 24)
G.specDropdown = specDropdown

-- Sortierte Klassenliste (feste Reihenfolge statt zufälliger pairs()-Reihenfolge).
local CLASS_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK",
    "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

local function RefreshSelectorDropdowns()
    classDropdown:SetText(G.GetClassIconMarkup(selectedClassToken, 16) .. G.GetClassDisplayName(selectedClassToken))
    local specName, specIcon = G.GetSpecInfo(selectedClassToken, selectedSpecKey)
    specDropdown:SetText(G.GetSpecIconMarkup(specIcon, 16) .. (specName or ""))

    classDropdown:SetupMenu(function(_, rootDescription)
        for _, classToken in ipairs(CLASS_ORDER) do
            rootDescription:CreateRadio(
                G.GetClassIconMarkup(classToken, 16) .. G.GetClassDisplayName(classToken),
                function() return selectedClassToken == classToken end,
                function()
                    -- Klassenwechsel: erste Spec dieser Klasse vorauswählen.
                    local firstSpec = G.SPEC_KEYS[classToken] and G.SPEC_KEYS[classToken][1]
                    G.SetSelection(classToken, firstSpec)
                end
            )
        end
    end)

    specDropdown:SetupMenu(function(_, rootDescription)
        local specs = G.SPEC_KEYS[selectedClassToken] or {}
        for _, specKey in ipairs(specs) do
            local name, icon = G.GetSpecInfo(selectedClassToken, specKey)
            rootDescription:CreateRadio(
                G.GetSpecIconMarkup(icon, 16) .. (name or specKey),
                function() return selectedSpecKey == specKey end,
                function() G.SetSelection(selectedClassToken, specKey) end
            )
        end
    end)
end
G.RefreshSelectorDropdowns = RefreshSelectorDropdowns

G.RegisterOnDatabaseReady(function()
    ResetToOwnSpec()
    RefreshSelectorDropdowns()
end)

-- GetSpecialization() liefert beim frühen ADDON_LOADED oft noch falsche/leere
-- Werte, weil die Spec-Daten dann noch nicht vom Server synchronisiert sind.
-- Deshalb hier nochmal bei zuverlässigeren Zeitpunkten neu auflösen -- aber
-- nur, solange der Spieler noch nicht manuell eine andere Klasse/Spec zum
-- Durchstöbern gewählt hat.
local specWatcher = CreateFrame("Frame")
specWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specWatcher:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_SPECIALIZATION_CHANGED" and unit ~= "player" then return end
    if not G.db then return end -- SavedVariables evtl. noch nicht geladen
    if G.IsOwnSpecSelected() or selectedClassToken == nil then
        ResetToOwnSpec()
        RefreshSelectorDropdowns()
        FireSelectionChanged(selectedClassToken, selectedSpecKey)
    end
end)
