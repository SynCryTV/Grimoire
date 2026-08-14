-- Manuell aktualisiert via classcodex-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
ClassCodexData = ClassCodexData or {}
ClassCodexData["PRIEST"] = {
  ["discipline"] = {
    label = "Discipline Priest",
    priorities = {
      {
        heroTalent = "Oracle", context = "Raid",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Voidweaver", context = "Raid",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Oracle", context = "Dungeons",
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
        changedDate = "2026-08-12",
      },
      {
        heroTalent = "Voidweaver", context = "Dungeons",
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
        changedDate = "2026-08-12",
      },
    },
    talents = {},
    rotation = {},
  },
  ["holy"] = {
    label = "Holy Priest",
    priorities = {
      {
        heroTalent = "Archon", context = "Raid",
        stats = {
          { "Crit" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Oracle", context = "Raid",
        stats = {
          { "Crit" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Archon", context = "Dungeons\/Mythic+",
        stats = {
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
      },
      {
        heroTalent = "Oracle", context = "Dungeons\/Mythic+",
        stats = {
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["shadow"] = {
    label = "Shadow Priest",
    priorities = {
      {
        heroTalent = "Archon", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Voidweaver", context = "General",
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