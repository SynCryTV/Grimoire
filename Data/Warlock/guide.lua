-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["WARLOCK"] = {
  ["affliction"] = {
    label = "Affliction Warlock",
    priorities = {
      {
        heroTalent = "Hellcaller", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Soul Harvester", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
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
  ["demonology"] = {
    label = "Demonology Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
        previousStats = {
          { "Haste", "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Soul Harvester", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
        previousStats = {
          { "Haste", "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["destruction"] = {
    label = "Destruction Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
        },
        operators = { ">=" },
        previousStats = {
          { "Haste" },
          { "Mastery>", "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Hellcaller", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
        },
        operators = { ">=" },
        previousStats = {
          { "Haste" },
          { "Mastery>", "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}