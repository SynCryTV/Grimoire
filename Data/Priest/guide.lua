-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["PRIEST"] = {
  ["discipline"] = {
    label = "Discipline Priest",
    priorities = {
      {
        heroTalent = "Oracle", context = "Raid",
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
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Voidweaver", context = "Raid",
        stats = {
          { "Haste" },
          { "Intellect" },
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
      {
        heroTalent = "Oracle", context = "Dungeons",
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
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Voidweaver", context = "Dungeons",
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
  ["holy"] = {
    label = "Holy Priest",
    priorities = {
      {
        heroTalent = "Archon", context = "Raid",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Crit" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Oracle", context = "Raid",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
        previousStats = {
          { "Crit" },
          { "Versatility", "Mastery" },
          { "Haste" },
        },
        previousOperators = { ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Archon", context = "Dungeons\/Mythic+",
        stats = {
          { "Intellect" },
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Oracle", context = "Dungeons\/Mythic+",
        stats = {
          { "Intellect" },
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
        previousStats = {
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
    },
    talents = {},
    rotation = {},
  },
  ["shadow"] = {
    label = "Shadow Priest",
    priorities = {
      {
        heroTalent = "Archon", context = "General",
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
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        previousOperators = { ">", ">", ">" },
        changedDate = "2026-08-14",
      },
      {
        heroTalent = "Voidweaver", context = "General",
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