local ADDON_NAME, G = ...

-- Reihenfolge entspricht der Blizzard-Spezialisierungs-Reihenfolge
-- (GetSpecializationInfo(1..4)) je Klasse. Die Keys selbst müssen exakt zu
-- den Ordner-/Tabellen-Keys passen, die der Scraper verwendet.
G.SPEC_KEYS = {
    DEATHKNIGHT = { "blood", "frost", "unholy" },
    DEMONHUNTER = { "devourer", "havoc", "vengeance" },
    DRUID       = { "balance", "feral", "guardian", "restoration" },
    EVOKER      = { "augmentation", "devastation", "preservation" },
    HUNTER      = { "beast-mastery", "marksmanship", "survival" },
    MAGE        = { "arcane", "fire", "frost" },
    MONK        = { "brewmaster", "mistweaver", "windwalker" },
    PALADIN     = { "holy", "protection", "retribution" },
    PRIEST      = { "discipline", "holy", "shadow" },
    ROGUE       = { "assassination", "outlaw", "subtlety" },
    SHAMAN      = { "elemental", "enhancement", "restoration" },
    WARLOCK     = { "affliction", "demonology", "destruction" },
    WARRIOR     = { "arms", "fury", "protection" },
}

-- Gibt den Spec-Key für die aktuell aktive Spezialisierung des Spielers
-- zurück, oder nil falls (noch) keine gewählt ist.
function G.GetOwnSpecKey()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    local _, classToken = UnitClass("player")
    local keys = G.SPEC_KEYS[classToken]
    return keys and keys[specIndex]
end

G.CLASS_DISPLAY_NAMES = {
    DEATHKNIGHT = "Death Knight", DEMONHUNTER = "Demon Hunter", DRUID = "Druid",
    EVOKER = "Evoker", HUNTER = "Hunter", MAGE = "Mage", MONK = "Monk",
    PALADIN = "Paladin", PRIEST = "Priest", ROGUE = "Rogue", SHAMAN = "Shaman",
    WARLOCK = "Warlock", WARRIOR = "Warrior",
}

-- "beast-mastery" -> "Beast Mastery"
function G.GetSpecDisplayName(specKey)
    if not specKey then return "" end
    local parts = {}
    for word in specKey:gmatch("[^-]+") do
        table.insert(parts, word:sub(1, 1):upper() .. word:sub(2))
    end
    return table.concat(parts, " ")
end
