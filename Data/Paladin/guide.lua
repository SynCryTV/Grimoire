-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["PALADIN"] = {
  ["holy"] = {
    label = "Holy Paladin",
    priorities = {
      {
        heroTalent = "Herald of the Sun", heroTalentIcon = "wow-hero-talent-herald-of-the-sun", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
      },
      {
        heroTalent = "Lightsmith", heroTalentIcon = "wow-hero-talent-lightsmith", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
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
          { "Strength" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Strength" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-20",
      },
    },
    talents = {},
    rotation = {},
  },
  ["retribution"] = {
    label = "Retribution Paladin",
    priorities = {
      {
        heroTalent = "Templar", heroTalentIcon = "wow-hero-talent-templar", context = "General",
        stats = {
          { "Strength" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Herald of the Sun", heroTalentIcon = "wow-hero-talent-herald-of-the-sun", context = "General",
        stats = {
          { "Strength" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}