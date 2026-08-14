-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["PALADIN"] = {
  ["holy"] = {
    label = "Holy Paladin",
    priorities = {
      {
        heroTalent = "Herald of the Sun", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
        previousStats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Lightsmith", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
        previousStats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["protection"] = {
    label = "Protection Paladin",
    priorities = {
      {
        context = "General",
        stats = {
          { "Strength" },
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
        context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
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
    },
    talents = {},
    rotation = {},
  },
  ["retribution"] = {
    label = "Retribution Paladin",
    priorities = {
      {
        heroTalent = "Templar", context = "General",
        stats = {
          { "Strength" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Herald of the Sun", context = "General",
        stats = {
          { "Strength" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
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