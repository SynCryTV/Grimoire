local ADDON_NAME, G = ...

local selectedClassToken   -- z.B. "DEMONHUNTER"
local selectedHeroTalent   -- z.B. "Annihilator"
local ownClassToken, ownSpecIndex

local function GetOwnClassToken()
    local _, classToken = UnitClass("player")
    return classToken
end

-- Setzt die Auswahl zurück auf die aktuell gespielte Klasse/Spec. Die
-- konkrete Hero-Talent-Erkennung (welches der beiden Hero-Talente aktiv ist)
-- hängt von echten Talentdaten ab und wird in Phase 3 verdrahtet; hier nur
-- das Grundgerüst mit einem Platzhalter.
local function ResetToOwnSpec()
    ownClassToken = GetOwnClassToken()
    selectedClassToken = ownClassToken
    selectedHeroTalent = nil -- Phase 3: aus C_ClassTalents/aktivem Loadout auslesen
end

function G.GetSelectedClass()
    return selectedClassToken
end

function G.GetSelectedHeroTalent()
    return selectedHeroTalent
end

function G.IsOwnSpecSelected()
    return selectedClassToken == ownClassToken
end

function G.SetSelection(classToken, heroTalent)
    selectedClassToken = classToken
    selectedHeroTalent = heroTalent
    if G.OnSelectionChanged then
        G.OnSelectionChanged(classToken, heroTalent)
    end
end

function G.ResetSelectionToOwnSpec()
    ResetToOwnSpec()
    if G.OnSelectionChanged then
        G.OnSelectionChanged(selectedClassToken, selectedHeroTalent)
    end
end

-- Sichtbare Auswahl-Leiste oben im Guide-Tab. Die eigentlichen Dropdown-
-- Inhalte (Klassenliste, Hero-Talent-Liste je Klasse) werden befüllt,
-- sobald in Phase 3 echte Daten verfügbar sind.
local selectorBar = CreateFrame("Frame", "GrimoireSelectorBar", G.panel)
selectorBar:SetHeight(28)
selectorBar:SetPoint("TOPLEFT", G.panel, "TOPLEFT", 16, -16)
selectorBar:SetPoint("RIGHT", G.panel, "RIGHT", -16, 0)
G.selectorBar = selectorBar

local classDropdown = CreateFrame("DropdownButton", "GrimoireClassDropdown", selectorBar, "WowStyle1DropdownTemplate")
classDropdown:SetPoint("LEFT", 0, 0)
classDropdown:SetWidth(140)
G.classDropdown = classDropdown

local heroDropdown = CreateFrame("DropdownButton", "GrimoireHeroDropdown", selectorBar, "WowStyle1DropdownTemplate")
heroDropdown:SetPoint("LEFT", classDropdown, "RIGHT", 8, 0)
heroDropdown:SetWidth(140)
G.heroDropdown = heroDropdown

G.RegisterOnDatabaseReady(function()
    ResetToOwnSpec()
end)
