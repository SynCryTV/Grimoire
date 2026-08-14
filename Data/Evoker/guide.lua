-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["EVOKER"] = {
  ["augmentation"] = {
    label = "Augmentation Evoker",
    priorities = {
      {
        heroTalent = "Chronowarden", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Scalecommander", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
  ["devastation"] = {
    label = "Devastation Evoker",
    priorities = {
      {
        heroTalent = "Flameshaper", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Scalecommander", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
  ["preservation"] = {
    label = "Preservation Evoker",
    priorities = {
      {
        context = "General",
        stats = {
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        context = "General",
        stats = {
          { "Crit" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}