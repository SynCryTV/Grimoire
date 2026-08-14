-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["WARRIOR"] = {
  ["arms"] = {
    label = "Arms Warrior",
    priorities = {
      {
        heroTalent = "Colossus", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Slayer", context = "General",
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
  ["fury"] = {
    label = "Fury Warrior",
    priorities = {
      {
        heroTalent = "Mountain Thane", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Slayer", context = "General",
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
  ["protection"] = {
    label = "Protection Warrior",
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
    },
    talents = {},
    rotation = {},
  },
}