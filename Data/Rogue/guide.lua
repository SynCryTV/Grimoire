-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["ROGUE"] = {
  ["assassination"] = {
    label = "Assassination Rogue",
    priorities = {
      {
        heroTalent = "Fatebound", heroTalentIcon = "wow-hero-talent-fatebound", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Deathstalker", heroTalentIcon = "wow-hero-talent-deathstalker", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["outlaw"] = {
    label = "Outlaw Rogue",
    priorities = {
      {
        heroTalent = "Trickster", heroTalentIcon = "wow-hero-talent-trickster", context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Fatebound", heroTalentIcon = "wow-hero-talent-fatebound", context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["subtlety"] = {
    label = "Subtlety Rogue",
    priorities = {
      {
        heroTalent = "Deathstalker", heroTalentIcon = "wow-hero-talent-deathstalker", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-09-03",
      },
      {
        heroTalent = "Trickster", heroTalentIcon = "wow-hero-talent-trickster", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-09-03",
      },
    },
    talents = {},
    rotation = {},
  },
}