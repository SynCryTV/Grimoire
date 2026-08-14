-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["DEMONHUNTER"] = {
  ["devourer"] = {
    label = "Devourer Demon Hunter",
    priorities = {
      {
        heroTalent = "Annihilator", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Void-Scarred", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste." },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["havoc"] = {
    label = "Havoc Demon Hunter",
    priorities = {
      {
        heroTalent = "Fel-Scarred", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Aldrachi Reaver", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["vengeance"] = {
    label = "Vengeance Demon Hunter",
    priorities = {
      {
        heroTalent = "Aldrachi Reaver", context = "General",
        stats = {
          { "Haste" },
          { "Crit" },
          { "Versatility" },
          { "Mastery" },
        },
      },
      {
        heroTalent = "Annihilator", context = "General",
        stats = {
          { "Haste" },
          { "Crit" },
          { "Versatility" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}