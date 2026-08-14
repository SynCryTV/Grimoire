-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["EVOKER"] = {
  ["augmentation"] = {
    label = "Augmentation Evoker",
    priorities = {
      {
        heroTalent = "Chronowarden", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Scalecommander", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["devastation"] = {
    label = "Devastation Evoker",
    priorities = {
      {
        heroTalent = "Flameshaper", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Scalecommander", context = "General",
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
  ["preservation"] = {
    label = "Preservation Evoker",
    priorities = {
      {
        context = "General",
        stats = {
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        context = "General",
        stats = {
          { "Crit" },
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}