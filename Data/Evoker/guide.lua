-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["EVOKER"] = {
  ["augmentation"] = {
    label = "Augmentation Evoker",
    priorities = {
      {
        heroTalent = "Chronowarden", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Scalecommander", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["devastation"] = {
    label = "Devastation Evoker",
    priorities = {
      {
        heroTalent = "Flameshaper", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Scalecommander", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
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
        previousStats = {
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
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
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}