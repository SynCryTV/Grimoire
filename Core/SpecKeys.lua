local ADDON_NAME, G = ...

-- Nur noch für die ANZEIGE-Reihenfolge im Dropdown relevant (kosmetisch).
-- WICHTIG: entspricht NICHT mehr zwingend Blizzards echter Spec-Reihenfolge
-- (GetSpecializationInfo-Index) -- die wird seit dem Fix unten über
-- G.SPEC_IDS aufgelöst, weil der Index sich verschiebt, sobald Blizzard
-- eine neue Spec einer bestehenden Klasse hinzufügt (z.B. Devourer als
-- 3. Demon-Hunter-Spec) und ältere Specs dadurch nach hinten rutschen.
-- Die Keys selbst müssen weiterhin exakt zu den Ordner-/Tabellen-Keys
-- passen, die der Scraper verwendet.
G.SPEC_KEYS = {
    DEATHKNIGHT = { "blood", "frost", "unholy" },
    DEMONHUNTER = { "havoc", "vengeance", "devourer" },
    DRUID       = { "balance", "feral", "guardian", "restoration" },
    EVOKER      = { "devastation", "preservation", "augmentation" },
    HUNTER      = { "beast-mastery", "marksmanship", "survival" },
    MAGE        = { "arcane", "fire", "frost" },
    MONK        = { "brewmaster", "windwalker", "mistweaver" },
    PALADIN     = { "holy", "protection", "retribution" },
    PRIEST      = { "discipline", "holy", "shadow" },
    ROGUE       = { "assassination", "outlaw", "subtlety" },
    SHAMAN      = { "elemental", "enhancement", "restoration" },
    WARLOCK     = { "affliction", "demonology", "destruction" },
    WARRIOR     = { "arms", "fury", "protection" },
}

-- Stabile, klassenunabhängige Blizzard-Spezialisierungs-IDs (aus
-- ChrSpecialization.db2 -- ändern sich nie, im Gegensatz zum Index, der
-- sich verschiebt sobald eine neue Spec eingefügt wird). Quelle:
-- warcraft.wiki.gg/wiki/SpecID
G.SPEC_IDS = {
    DEATHKNIGHT = { blood = 250, frost = 251, unholy = 252 },
    DEMONHUNTER = { havoc = 577, vengeance = 581, devourer = 1480 },
    DRUID       = { balance = 102, feral = 103, guardian = 104, restoration = 105 },
    EVOKER      = { devastation = 1467, preservation = 1468, augmentation = 1473 },
    HUNTER      = { ["beast-mastery"] = 253, marksmanship = 254, survival = 255 },
    MAGE        = { arcane = 62, fire = 63, frost = 64 },
    MONK        = { brewmaster = 268, windwalker = 269, mistweaver = 270 },
    PALADIN     = { holy = 65, protection = 66, retribution = 70 },
    PRIEST      = { discipline = 256, holy = 257, shadow = 258 },
    ROGUE       = { assassination = 259, outlaw = 260, subtlety = 261 },
    SHAMAN      = { elemental = 262, enhancement = 263, restoration = 264 },
    WARLOCK     = { affliction = 265, demonology = 266, destruction = 267 },
    WARRIOR     = { arms = 71, fury = 72, protection = 73 },
}

-- Gibt den Spec-Key für die aktuell aktive Spezialisierung des Spielers
-- zurück, oder nil falls (noch) keine gewählt ist bzw. die SpecID (noch)
-- nicht in G.SPEC_IDS hinterlegt ist. Nutzt die SpecID statt des Index,
-- damit es unabhängig davon korrekt ist, an welcher Position Blizzard die
-- Spec tatsächlich führt.
function G.GetOwnSpecKey()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    local specID = GetSpecializationInfo(specIndex)
    local _, classToken = UnitClass("player")
    local ids = G.SPEC_IDS[classToken]
    if not ids then return nil end
    for key, id in pairs(ids) do
        if id == specID then return key end
    end
    return nil
end

-- classToken -> numerische Blizzard-ClassID (für GetSpecializationInfoForClassID).
G.CLASS_IDS = {}
for classID = 1, 13 do
    local _, classToken = GetClassInfo(classID)
    if classToken then
        G.CLASS_IDS[classToken] = classID
    end
end

-- Nutzt Blizzards eigene, bereits lokalisierte Klassennamen (Deutsch, wenn
-- der Client auf Deutsch läuft) statt einer eigenen Übersetzungstabelle.
function G.GetClassDisplayName(classToken)
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classToken]) or classToken
end

-- Liefert den lokalisierten Spec-Namen + Icon-Datei-ID direkt von Blizzard,
-- unabhängig davon, welche Klasse der Spieler selbst gerade spielt. Sucht
-- über die SpecID (G.SPEC_IDS), NICHT über die Position in G.SPEC_KEYS --
-- damit ist das Ergebnis korrekt, egal in welcher Reihenfolge Blizzard die
-- Specs intern führt.
function G.GetSpecInfo(classToken, specKey)
    local classID = G.CLASS_IDS[classToken]
    local specID = G.SPEC_IDS[classToken] and G.SPEC_IDS[classToken][specKey]
    if not classID or not specID then return nil end

    local numSpecs = GetNumSpecializationsForClassID and GetNumSpecializationsForClassID(classID) or 4
    for i = 1, numSpecs do
        local id, name, _, icon = GetSpecializationInfoForClassID(classID, i)
        if id == specID then
            return name, icon
        end
    end
    return nil
end

-- Baut einen "|T...|t" Icon-Text-Baustein, den man vor einen Anzeigenamen
-- setzen kann (funktioniert in FontStrings, Dropdown-Buttons und Menü-
-- Einträgen gleichermaßen).
local function IconMarkup(texturePath, size)
    return string.format("|T%s:%d|t ", texturePath, size or 16)
end

function G.GetClassIconMarkup(classToken, size)
    if not classToken then return "" end
    local atlasName = "classicon-" .. classToken:lower()
    return string.format("|A:%s:%d:%d|a ", atlasName, size or 16, size or 16)
end

function G.GetSpecIconMarkup(icon, size)
    if not icon then return "" end
    return IconMarkup(icon, size)
end
