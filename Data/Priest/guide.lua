-- Manuell aktualisiert via Grimoire-scraper (nicht offiziell)
-- Wowhead-Operatoren werden originalgetreu gespeichert
-- talents/rotation bewusst als Platzhalter
GrimoireData = GrimoireData or {}
GrimoireData["PRIEST"] = {
  ["discipline"] = {
    label = "Discipline Priest",
    priorities = {
      {
        heroTalent = "Oracle", heroTalentIcon = "wow-hero-talent-oracle", context = "Raid",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Voidweaver", heroTalentIcon = "wow-hero-talent-voidweaver", context = "Raid",
        stats = {
          { "Haste" },
          { "Intellect" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Oracle", heroTalentIcon = "wow-hero-talent-oracle", context = "Dungeons",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Voidweaver", heroTalentIcon = "wow-hero-talent-voidweaver", context = "Dungeons",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["holy"] = {
    label = "Holy Priest",
    priorities = {
      {
        heroTalent = "Archon", heroTalentIcon = "wow-hero-talent-archon", context = "Raid",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
      },
      {
        heroTalent = "Oracle", heroTalentIcon = "wow-hero-talent-oracle", context = "Raid",
        stats = {
          { "Versatility", "Mastery" },
        },
        operators = {  },
      },
      {
        heroTalent = "Archon", heroTalentIcon = "wow-hero-talent-archon", context = "Dungeons\/Mythic+",
        stats = {
          { "Intellect" },
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Oracle", heroTalentIcon = "wow-hero-talent-oracle", context = "Dungeons\/Mythic+",
        stats = {
          { "Intellect" },
          { "Versatility" },
          { "Critical Strike" },
          { "Haste" },
          { "Mastery" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
  ["shadow"] = {
    label = "Shadow Priest",
    priorities = {
      {
        heroTalent = "Archon", heroTalentIcon = "wow-hero-talent-archon", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
      {
        heroTalent = "Voidweaver", heroTalentIcon = "wow-hero-talent-totemic", context = "General",
        stats = {
          { "Intellect" },
          { "Haste" },
          { "Mastery" },
          { "Critical Strike" },
          { "Versatility" },
        },
        operators = { ">", ">", ">", ">" },
      },
    },
    talents = {},
    rotation = {},
  },
}