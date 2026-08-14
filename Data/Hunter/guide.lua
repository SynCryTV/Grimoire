-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["HUNTER"] = {
  ["beast-mastery"] = {
    label = "Beast Mastery Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", heroTalentIcon = "wow-hero-talent-pack-leader", context = "General",
        stats = {
          { "Weapon Damage" },
          { "Agility" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">", ">" },
      },
      {
        heroTalent = "Dark Ranger", heroTalentIcon = "wow-hero-talent-dark-ranger", context = "General",
        stats = {
          { "Weapon Damage" },
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["marksmanship"] = {
    label = "Marksmanship Hunter",
    priorities = {
      {
        heroTalent = "Sentinel", heroTalentIcon = "wow-hero-talent-sentinel", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Dark Ranger", heroTalentIcon = "wow-hero-talent-dark-ranger", context = "General",
        stats = {
          { "Agility" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["survival"] = {
    label = "Survival Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", heroTalentIcon = "wow-hero-talent-pack-leader", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Critical Strike and Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">" },
      },
      {
        heroTalent = "Sentinel", heroTalentIcon = "wow-hero-talent-sentinel", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}