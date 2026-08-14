-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["SHAMAN"] = {
  ["elemental"] = {
    label = "Elemental Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery to 1200 rating" },
          { "Haste", "Crit" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["enhancement"] = {
    label = "Enhancement Shaman",
    priorities = {
      {
        heroTalent = "Stormbringer", context = "General",
        stats = {
          { "Mastery", "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Mastery", "Haste" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["restoration"] = {
    label = "Restoration Shaman",
    priorities = {
      {
        heroTalent = "Farseer", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
      },
      {
        heroTalent = "Totemic", context = "General",
        stats = {
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}