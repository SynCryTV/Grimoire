-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["PALADIN"] = {
  ["holy"] = {
    label = "Holy Paladin",
    priorities = {
      {
        heroTalent = "Herald of the Sun", context = "General",
        stats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Lightsmith", context = "General",
        stats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
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
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
          { "Critical Strike" },
        },
        changedDate = "2026-08-12",
      },
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
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
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Herald of the Sun", context = "General",
        stats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
}