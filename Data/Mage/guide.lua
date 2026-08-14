-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    priorities = {
      {
        heroTalent = "Spellslinger", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Sunfury", context = "General",
        stats = {
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
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
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
      },
      {
        heroTalent = "Frostfire", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
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
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Spellslinger", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}