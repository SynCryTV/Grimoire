-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["WARLOCK"] = {
  ["affliction"] = {
    label = "Affliction Warlock",
    priorities = {
      {
        heroTalent = "Hellcaller", heroTalentIcon = "wow-hero-talent-hellcaller", context = "General",
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
        heroTalent = "Soul Harvester", heroTalentIcon = "wow-hero-talent-soul-harvester", context = "General",
        stats = {
          { "Intellect" },
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
  ["demonology"] = {
    label = "Demonology Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", heroTalentIcon = "wow-hero-talent-diabolist", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
      },
      {
        heroTalent = "Soul Harvester", heroTalentIcon = "wow-hero-talent-soul-harvester", context = "General",
        stats = {
          { "Haste", "Critical Strike" },
        },
        operators = {  },
      },
    },
    talents = {},
    rotation = {},
  },
  ["destruction"] = {
    label = "Destruction Warlock",
    priorities = {
      {
        heroTalent = "Diabolist", heroTalentIcon = "wow-hero-talent-diabolist", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
        },
        operators = { ">=" },
      },
      {
        heroTalent = "Hellcaller", heroTalentIcon = "wow-hero-talent-hellcaller", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
        },
        operators = { ">=" },
      },
    },
    talents = {},
    rotation = {},
  },
}