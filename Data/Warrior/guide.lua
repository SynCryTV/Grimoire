-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["WARRIOR"] = {
  ["arms"] = {
    label = "Arms Warrior",
    priorities = {
      {
        heroTalent = "Colossus", heroTalentIcon = "wow-hero-talent-colossus", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Slayer", heroTalentIcon = "wow-hero-talent-slayer", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["fury"] = {
    label = "Fury Warrior",
    priorities = {
      {
        heroTalent = "Mountain Thane", heroTalentIcon = "wow-hero-talent-mountain-thane", context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Slayer", heroTalentIcon = "wow-hero-talent-slayer", context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
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
          { "Strength" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}