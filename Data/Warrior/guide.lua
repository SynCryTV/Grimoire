-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["WARRIOR"] = {
  ["arms"] = {
    label = "Arms Warrior",
    priorities = {
      {
        heroTalent = "Colossus", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Slayer", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["fury"] = {
    label = "Fury Warrior",
    priorities = {
      {
        heroTalent = "Mountain Thane", context = "General",
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
        heroTalent = "Slayer", context = "General",
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
    },
    talents = {},
    rotation = {},
  },
  ["protection"] = {
    label = "Protection Warrior",
    priorities = {
      {
        context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}