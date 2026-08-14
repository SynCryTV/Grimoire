# Grimoire

Ein WoW-Addon, das dir pro Spezialisierung zeigt, worauf's ankommt: Best-in-
Slot-Gear, Wertepriorität, die richtigen Omnium-Folio-Runen und was du dir
an Verzauberungen, Edelsteinen und Verbrauchsmaterial besorgen solltest –
alles an einer Stelle, ohne zehn Browser-Tabs offen haben zu müssen.

**Status:** Aktiver Neuaufbau. Die Kernfunktionen entstehen gerade von
Grund auf neu; dieses README beschreibt den angestrebten Funktionsumfang.

## Was das Addon zeigt

- **Best-in-Slot-Gear** von Wowhead, Icy-Veins und Archon
- **Wertepriorität** pro Spec/Hero-Talent, inklusive Hinweis, wenn sich die
  Reihenfolge seit dem letzten Update geändert hat
- **Omnium Folio** – die empfohlenen Runen pro Woche, mit echten
  Blizzard-Tooltips beim Hovern
- **Verzauberungen, Edelsteine, Verbrauchsmaterial** – inklusive
  Auctionator-Einkaufslisten-Export für jede der drei Kategorien
- Direktlinks zu Raidbots/SimulationCraft für genauere, individuelle Werte

## Was bewusst fehlt (und warum)

- **Talente & Rotation** – bewusst nicht enthalten, um den Traffic der
  Guide-Autoren nicht zu untergraben. Das Addon verlinkt stattdessen direkt
  zu Wowhead, Archon, Icy-Veins und Murlok.
- **Crafting & Embellishments** – nicht enthalten.
- **PvP** – nicht enthalten, reiner PvE-Fokus.
- **Sprachen** – nur Deutsch (Englisch bleibt als technischer Fallback für
  fehlende Übersetzungen).

## Daten aktuell halten

Die Daten werden über ein separates, lokales Scraper-Tool aktuell gehalten,
das nicht Teil dieses Repos ist. Updates landen als Commit/Release hier.

## Installation

Über [WowUp](https://wowup.io/) durch Hinzufügen dieses Repos als Quelle,
oder manuell: neuestes Release herunterladen, entpacken, in den
`Interface/AddOns`-Ordner legen.

## Lizenz

Eigenständiges Projekt.
