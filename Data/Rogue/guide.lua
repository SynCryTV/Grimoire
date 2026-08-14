-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["ROGUE"] = {
  ["assassination"] = {
    label = "Assassination Rogue",
    priorities = {
      {
        heroTalent = "Fatebound", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Deathstalker", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["outlaw"] = {
    label = "Outlaw Rogue",
    priorities = {
      {
        heroTalent = "Trickster", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
      },
      {
        heroTalent = "Fatebound", context = "General",
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
  ["subtlety"] = {
    label = "Subtlety Rogue",
    priorities = {
      {
        heroTalent = "Deathstalker", context = "General",
        stats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Trickster", context = "General",
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
}