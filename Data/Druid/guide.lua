-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["DRUID"] = {
  ["balance"] = {
    label = "Balance Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", context = "General",
        stats = {
          { "Mastery" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Elune's Chosen", context = "General",
        stats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["feral"] = {
    label = "Feral Druid",
    priorities = {
      {
        heroTalent = "Druid of the Claw", context = "General",
        stats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Wildstalker", context = "General",
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
  ["guardian"] = {
    label = "Guardian Druid",
    priorities = {
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
      },
      {
        heroTalent = "Wildstalker", context = "General",
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
}