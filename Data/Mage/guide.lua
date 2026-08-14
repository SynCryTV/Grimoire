-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    priorities = {
      {
        heroTalent = "Spellslinger", heroTalentIcon = "wow-hero-talent-spellslinger", context = "General",
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
        heroTalent = "Sunfury", heroTalentIcon = "wow-hero-talent-sunfury", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["fire"] = {
    label = "Fire Mage",
    priorities = {
      {
        heroTalent = "Sunfury", heroTalentIcon = "wow-hero-talent-sunfury", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Frostfire", heroTalentIcon = "wow-hero-talent-frostfire", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Mage",
    priorities = {
      {
        heroTalent = "Frostfire", heroTalentIcon = "wow-hero-talent-frostfire", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Spellslinger", heroTalentIcon = "wow-hero-talent-spellslinger", context = "General",
        stats = {
          { "Intellect" },
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