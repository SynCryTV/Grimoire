-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["SHAMAN"] = {
  ["elemental"] = {
    label = "Elemental Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["enhancement"] = {
    label = "Enhancement Shaman",
    priorities = {
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery", "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Haste" },
          { "Mastery", "Critical Strike" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Mastery", "Haste" },
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
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Versatility", "Mastery", "Haste" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Versatility", "Mastery", "Haste" },
        },
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
}