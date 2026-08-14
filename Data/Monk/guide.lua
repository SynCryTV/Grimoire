-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["MONK"] = {
  ["brewmaster"] = {
    label = "Brewmaster Monk",
    priorities = {
      {
        heroTalent = "Shado-Pan", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Master of Harmony", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Shado-Pan", context = "Offensive",
        stats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Master of Harmony", context = "Offensive",
        stats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
  ["mistweaver"] = {
    label = "Mistweaver Monk",
    priorities = {
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
      },
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
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["windwalker"] = {
    label = "Windwalker Monk",
    priorities = {
      {
        heroTalent = "Shado-pan", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Conduit of the Celestials", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}