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
classDropdown:SetWidth(140)
G.classDropdown = classDropdown

local specDropdown = CreateFrame("DropdownButton", "GrimoireSpecDropdown", selectorBar, "WowStyle1DropdownTemplate")
specDropdown:SetPoint("LEFT", classDropdown, "RIGHT", 8, 0)
specDropdown:SetWidth(140)
G.specDropdown = specDropdown

-- Sortierte Klassenliste (feste Reihenfolge statt zufälliger pairs()-Reihenfolge).
local CLASS_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK",
    "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

local function RefreshSelectorDropdowns()
    classDropdown:SetText(G.CLASS_DISPLAY_NAMES[selectedClassToken] or "?")
    specDropdown:SetText(G.GetSpecDisplayName(selectedSpecKey))

    classDropdown:SetupMenu(function(_, rootDescription)
        for _, classToken in ipairs(CLASS_ORDER) do
            rootDescription:CreateRadio(
                G.CLASS_DISPLAY_NAMES[classToken],
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
            rootDescription:CreateRadio(
                G.GetSpecDisplayName(specKey),
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
