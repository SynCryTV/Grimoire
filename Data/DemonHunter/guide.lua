-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DEMONHUNTER"] = {
  ["devourer"] = {
    label = "Devourer Demon Hunter",
    priorities = {
      {
        heroTalent = "Annihilator", heroTalentIcon = "wow-hero-talent-annihilator", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Void-Scarred", heroTalentIcon = "wow-hero-talent-void-scarred", context = "General",
        stats = {
          { "Intellect" },
          { "Haste (bis 800)" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste (ab 800)" },
        },
        operators = { ">", ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["havoc"] = {
    label = "Havoc Demon Hunter",
    priorities = {
      {
        heroTalent = "Fel-Scarred", heroTalentIcon = "wow-hero-talent-fel-scarred", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Aldrachi Reaver", heroTalentIcon = "wow-hero-talent-aldrachi-reaver", context = "General",
        stats = {
          { "Agility" },
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
  ["vengeance"] = {
    label = "Vengeance Demon Hunter",
    priorities = {
      {
        heroTalent = "Aldrachi Reaver", heroTalentIcon = "wow-hero-talent-aldrachi-reaver", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">" },
      },
      {
        heroTalent = "Annihilator", heroTalentIcon = "wow-hero-talent-annihilator", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}