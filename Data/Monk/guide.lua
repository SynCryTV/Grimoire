-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["MONK"] = {
  ["brewmaster"] = {
    label = "Brewmaster Monk",
    priorities = {
      {
        heroTalent = "Shado-Pan", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Master of Harmony", context = "Defensive",
        stats = {
          { "Versatility", "Critical Strike", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Versatility", "Critical Strike", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Shado-Pan", context = "Offensive",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Master of Harmony", context = "Offensive",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Critical Strike" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
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
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
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
          { "Haste" },
          { "Critical Strike" },
          { "Versatility" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
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
          { "Agility" },
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Critical Strike" },
          { "Mastery" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Conduit of the Celestials", context = "General",
        stats = {
          { "Agility" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
}