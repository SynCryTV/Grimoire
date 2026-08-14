-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["DRUID"] = {
  ["balance"] = {
    label = "Balance Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", heroTalentIcon = "wow-hero-talent-keeper-of-the-grove", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
      },
      {
        heroTalent = "Elune's Chosen", heroTalentIcon = "wow-hero-talent-elunes-chosen", context = "General",
        stats = {
          { "Intellect" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["feral"] = {
    label = "Feral Druid",
    priorities = {
      {
        heroTalent = "Druid of the Claw", heroTalentIcon = "wow-hero-talent-druid-of-the-claw", context = "General",
        stats = {
          { "Agility" },
          { "Mastery" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Wildstalker", heroTalentIcon = "wow-hero-talent-Wildstalker", context = "General",
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
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Druid",
    priorities = {
      {
        heroTalent = "Keeper of the Grove", heroTalentIcon = "wow-hero-talent-keeper-of-the-grove", context = "General",
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
        heroTalent = "Wildstalker", heroTalentIcon = "wow-hero-talent-wildstalker", context = "General",
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
}