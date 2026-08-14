-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["SHAMAN"] = {
  ["elemental"] = {
    label = "Elemental Shaman",
    priorities = {
      {
        heroTalent = "Farseer", heroTalentIcon = "wow-hero-talent-farseer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
          { "Intellect" },
        },
        operators = { ">", ">", ">" },
      },
      {
        heroTalent = "Stormbringer", heroTalentIcon = "wow-hero-talent-stormbringer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Critical Strike" },
          { "Versatility" },
          { "Intellect" },
        },
        operators = { ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["enhancement"] = {
    label = "Enhancement Shaman",
    priorities = {
      {
        heroTalent = "Stormbringer", heroTalentIcon = "wow-hero-talent-stormbringer", context = "General",
        stats = {
          { "Mastery", "Haste" },
        },
        operators = {  },
      },
      {
        heroTalent = "Totemic", heroTalentIcon = "wow-hero-talent-totemic", context = "General",
        stats = {
          { "Mastery", "Haste" },
        },
        operators = {  },
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Shaman",
    priorities = {
      {
        heroTalent = "Farseer", heroTalentIcon = "wow-hero-talent-farseer", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Totemic", heroTalentIcon = "wow-hero-talent-totemic", context = "General",
        stats = {
          { "Intellect" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}