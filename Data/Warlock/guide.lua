-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["WARLOCK"] = {
  ["affliction"] = {
    label = "Affliction Warlock",
    priorities = {
      {
        heroTalent = "Hellcaller", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
      },
      {
        heroTalent = "Soul Harvester", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["demonology"] = {
    label = "Demonology Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Soul Harvester", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["destruction"] = {
    label = "Destruction Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", context = "General",
        stats = {
          { "Haste" },
          { "Mastery>", "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Hellcaller", context = "General",
        stats = {
          { "Haste" },
          { "Mastery>", "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}