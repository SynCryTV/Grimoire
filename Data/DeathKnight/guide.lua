-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["DEATHKNIGHT"] = {
  ["blood"] = {
    label = "Blood Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", context = "General",
        stats = {
          { "Haste" },
          { "Mastery", "Critical Strike", "Versatility" },
        },
      },
      {
        heroTalent = "Deathbringer", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery", "Versatility" },
          { "Haste" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Death Knight",
    priorities = {
      {
        heroTalent = "Deathbringer", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Rider of the Apocalypse", context = "General",
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
  ["unholy"] = {
    label = "Unholy Death Knight",
    priorities = {
      {
        heroTalent = "San'layn", context = "General",
        stats = {
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Rider of the Apocalypse", context = "General",
        stats = {
          { "Mastery" },
          { "Crit" },
          { "Haste" },
          { "Versatility" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
}