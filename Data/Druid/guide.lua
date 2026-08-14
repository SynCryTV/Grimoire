-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DRUID"] = {
  ["balance"] = {
    label = "Balance Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
        previousStats = {
          { "Mastery" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Elune's Chosen", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["feral"] = {
    label = "Feral Druid",
    priorities = {
      {
        heroTalent = "Druid of the Claw", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Wildstalker", context = "General",
        stats = {
          { "Agility" },
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
  ["guardian"] = {
    label = "Guardian Druid",
    priorities = {
      {
        context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Wildstalker", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}