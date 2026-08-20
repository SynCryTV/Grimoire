-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DEATHKNIGHT"] = {
  ["blood"] = {
    label = "Blood Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", heroTalentIcon = "wow-hero-talent-sanlayn", context = "General",
        stats = {
          { "Strength" },
          { "Haste" },
          { "Mastery", "Critical Strike", "Versatility" },
        },
        operators = { ">", ">" },
      },
      {
        heroTalent = "Deathbringer", heroTalentIcon = "wow-hero-talent-deathbringer", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Mastery", "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Death Knight",
    priorities = {
      {
        heroTalent = "Deathbringer", heroTalentIcon = "wow-hero-talent-deathbringer", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Rider of the Apocalypse", heroTalentIcon = "wow-hero-talent-rider-of-the-apocalypse", context = "General",
        stats = {
          { "Strength" },
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
  ["unholy"] = {
    label = "Unholy Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", heroTalentIcon = "wow-hero-talent-sanlayn", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Strength" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-20",
      },
      {
        heroTalent = "Rider of the Apocalypse", heroTalentIcon = "wow-hero-talent-rider-of-the-apocalypse", context = "General",
        stats = {
          { "Strength" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Strength" },
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