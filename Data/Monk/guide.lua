-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["MONK"] = {
  ["brewmaster"] = {
    label = "Brewmaster Monk",
    priorities = {
      {
        heroTalent = "Shado-Pan", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Master of Harmony", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Shado-Pan", context = "Offensive",
        stats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Master of Harmony", context = "Offensive",
        stats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
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
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
      },
      {
        context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["windwalker"] = {
    label = "Windwalker Monk",
    priorities = {
      {
        heroTalent = "Shado-pan", context = "General",
        stats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Conduit of the Celestials", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}