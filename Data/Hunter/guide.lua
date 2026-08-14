-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["HUNTER"] = {
  ["beast-mastery"] = {
    label = "Beast Mastery Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", context = "General",
        stats = {
          { "Weapon Damage" },
          { "Agility" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">", ">" },
        previousStats = {
          { "Weapon Damage" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Dark Ranger", context = "General",
        stats = {
          { "Weapon Damage" },
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">", ">" },
        previousStats = {
          { "Weapon Damage" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["marksmanship"] = {
    label = "Marksmanship Hunter",
    priorities = {
      {
        heroTalent = "Sentinel", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Dark Ranger", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["survival"] = {
    label = "Survival Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Critical Strike and Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">" },
        previousStats = {
          { "Mastery" },
          { "Critical Strike and Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Sentinel", context = "General",
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
}