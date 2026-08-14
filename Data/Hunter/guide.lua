-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- talents/rotation bewusst als Platzhalter -- siehe Projektnotizen
GrimoireData = GrimoireData or {}
GrimoireData["HUNTER"] = {
  ["beast-mastery"] = {
    label = "Beast Mastery Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", context = "General",
        stats = {
          { "Weapon Damage" },
          { "Mastery" },
          { "Critical Strike" },
          { "Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Dark Ranger", context = "General",
        stats = {
          { "Weapon Damage" },
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
  ["marksmanship"] = {
    label = "Marksmanship Hunter",
    priorities = {
      {
        heroTalent = "Sentinel", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
      },
      {
        heroTalent = "Dark Ranger", context = "General",
        stats = {
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
          { "Haste" },
        },
      },
    },
    talents = {},
    rotation = {},
  },
  ["survival"] = {
    label = "Survival Hunter",
    priorities = {
      {
        heroTalent = "Pack Leader", context = "General",
        stats = {
          { "Mastery" },
          { "Critical Strike and Haste" },
          { "Versatility" },
        },
      },
      {
        heroTalent = "Sentinel", context = "General",
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