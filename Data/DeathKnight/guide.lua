-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DEATHKNIGHT"] = {
  ["blood"] = {
    label = "Blood Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Mastery", "Critical Strike", "Versatility" },
        },
        operators = { ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery", "Critical Strike", "Versatility" },
        },
        previousOperators = { ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Deathbringer", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Mastery", "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Mastery", "Versatility" },
          { "Haste" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Death Knight",
    priorities = {
      {
        heroTalent = "Deathbringer", context = "General",
        stats = {
          { "Strength" },
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
        heroTalent = "Rider of the Apocalypse", context = "General",
        stats = {
          { "Strength" },
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
  ["unholy"] = {
    label = "Unholy Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", context = "General",
        stats = {
          { "Strength" },
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
        heroTalent = "Rider of the Apocalypse", context = "General",
        stats = {
          { "Strength" },
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
    },
    talents = {},
    rotation = {},
  },
}