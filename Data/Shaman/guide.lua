-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["SHAMAN"] = {
  ["elemental"] = {
    label = "Elemental Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
          { "Intellect" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
          { "Intellect" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["enhancement"] = {
    label = "Enhancement Shaman",
    priorities = {
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery", "Haste" },
        },
        operators = {  },
        previousStats = {
          { "Mastery", "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Mastery", "Haste" },
        },
        operators = {  },
        previousStats = {
          { "Mastery", "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}