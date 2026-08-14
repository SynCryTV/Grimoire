-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    priorities = {
      {
        heroTalent = "Spellslinger", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Sunfury", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["fire"] = {
    label = "Fire Mage",
    priorities = {
      {
        heroTalent = "Sunfury", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Frostfire", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Mage",
    priorities = {
      {
        heroTalent = "Frostfire", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Spellslinger", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}