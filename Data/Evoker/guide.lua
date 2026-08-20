-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["EVOKER"] = {
  ["augmentation"] = {
    label = "Augmentation Evoker",
    priorities = {
      {
        heroTalent = "Chronowarden", heroTalentIcon = "wow-hero-talent-chronowarden", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Scalecommander", heroTalentIcon = "wow-hero-talent-scalecommander", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["devastation"] = {
    label = "Devastation Evoker",
    priorities = {
      {
        heroTalent = "Flameshaper", heroTalentIcon = "wow-hero-talent-flameshaper", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Scalecommander", heroTalentIcon = "wow-hero-talent-scalecommander", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
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
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-20",
      },
    },
    talents = {},
    rotation = {},
  },
}