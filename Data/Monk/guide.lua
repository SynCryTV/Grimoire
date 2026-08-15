-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["MONK"] = {
  ["brewmaster"] = {
    label = "Brewmaster Monk",
    priorities = {
      {
        heroTalent = "Shado-Pan", heroTalentIcon = "wow-hero-talent-shado-pan", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
        },
        operators = {  },
      },
      {
        heroTalent = "Master of Harmony", heroTalentIcon = "wow-hero-talent-master-of-harmony", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
        },
        operators = {  },
      },
      {
        heroTalent = "Shado-Pan", heroTalentIcon = "wow-hero-talent-shado-pan", context = "Offensive",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
      },
      {
        heroTalent = "Master of Harmony", heroTalentIcon = "wow-hero-talent-master-of-harmony", context = "Offensive",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
      },
    },
    talents = {},
    rotation = {},
  },
  ["mistweaver"] = {
    label = "Mistweaver Monk",
    priorities = {
      {
        context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Intellect" },
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">", ">" },
        changedDate = "2026-08-15",
      },
    },
    talents = {},
    rotation = {},
  },
  ["windwalker"] = {
    label = "Windwalker Monk",
    priorities = {
      {
        heroTalent = "Shado-pan", heroTalentIcon = "wow-hero-talent-shado-pan", context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Conduit of the Celestials", heroTalentIcon = "wow-hero-talent-conduit-of-the-celestials", context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}