-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DEMONHUNTER"] = {
  ["devourer"] = {
    label = "Devourer Demon Hunter",
    priorities = {
      {
        heroTalent = "Annihilator", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Void-Scarred", context = "General",
        stats = {
          { "Intellect" },
          { "Haste (bis 800)" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste (ab 800)" },
        },
        operators = { ">", ">", ">", ">", ">" },
        previousStats = {
          { "Haste (bis 800)" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste (ab 800)" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["havoc"] = {
    label = "Havoc Demon Hunter",
    priorities = {
      {
        heroTalent = "Fel-Scarred", context = "General",
        stats = {
          { "Agility" },
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
        heroTalent = "Aldrachi Reaver", context = "General",
        stats = {
          { "Agility" },
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
  ["vengeance"] = {
    label = "Vengeance Demon Hunter",
    priorities = {
      {
        heroTalent = "Aldrachi Reaver", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Crit" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Annihilator", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Crit" },
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