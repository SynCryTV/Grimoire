-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["PALADIN"] = {
  ["holy"] = {
    label = "Holy Paladin",
    priorities = {
      {
        heroTalent = "Herald of the Sun", context = "General",
        stats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Lightsmith", context = "General",
        stats = {
          { "Mastery" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["protection"] = {
    label = "Protection Paladin",
    priorities = {
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["retribution"] = {
    label = "Retribution Paladin",
    priorities = {
      {
        heroTalent = "Templar", context = "General",
        stats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Herald of the Sun", context = "General",
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