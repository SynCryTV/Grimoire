-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    priorities = {
      {
        heroTalent = "Spellslinger", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Sunfury", context = "General",
        stats = {
          { "Haste" },
          { "Versatility" },
          { "Critical Strike" },
          { "Mastery" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["fire"] = {
    label = "Fire Mage",
    priorities = {
      {
        heroTalent = "Sunfury", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
      },
      {
        heroTalent = "Frostfire", context = "General",
        stats = {
          { "Haste" },
          { "Mastery" },
          { "Versatility" },
          { "Critical Strike" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["frost"] = {
    label = "Frost Mage",
    priorities = {
      {
        heroTalent = "Frostfire", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Spellslinger", context = "General",
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
}