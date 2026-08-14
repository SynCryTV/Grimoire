# Grimoire — Funktionsspezifikation (Phase 1)

Diese Spezifikation beschreibt ausschließlich **Verhalten** — keine
Implementierung, keine Variablennamen, keine Codestruktur. Sie ist die
alleinige Grundlage für den Neuaufbau; der alte Class-Codex-Code wird beim
Schreiben nicht mehr eingesehen.

---

## 1. Fenster & Docking

- Grimoire hat **ein** Panel, kein separates Zweitfenster.
- Das Panel dockt an das Blizzard-Charakterfenster (PaperDollFrame) an und
  öffnet/schließt sich zusammen damit (Taste `C`).
- Keine Minimap-Icon, kein Floating-Modus.
- Slash-Befehle: `/grim` und `/grimoire` (Alias). `/grim help` listet
  verfügbare Unterbefehle.
- Panel-Breite ist einstellbar (Regler in den Settings, sinnvoller
  Wertebereich ca. 260–500px), mit einem Standardwert. Die Höhe passt sich
  automatisch dem Inhalt des aktiven Tabs an (kein manuelles Höhen-Ziehen).

## 2. Tab-Struktur

Vier Seiten-Tabs, senkrecht angeordnet an einer Kante des Panels:

1. **Guide** — Werteziele, Wertepriorität, Omnium Folio
2. **BiS-Gear**
3. **Trinkets**
4. **Enhancements** — Verzauberungen, Edelsteine, Verbrauchsmaterial

Jeder Tab zeigt nur seinen eigenen Inhalt; nur ein Tab ist gleichzeitig aktiv.
Der zuletzt gewählte Tab wird nicht zwingend gemerkt (Standard: erster Tab
beim Öffnen aktiv), es sei denn im Verlauf wird explizit anders entschieden.

## 2a. Klassen-/Spec-/Hero-Talent-Auswahl (ersetzt das alte Compendium-Fenster)

- Kein separates Fenster mehr zum Durchstöbern anderer Klassen — stattdessen
  eine Auswahl (Dropdown o.ä.) **oben im Guide-Tab**, direkt über/bei den
  Werteziele.
- Zwei Auswahlfelder: **Klasse** und **Hero-Talent** (welches Hero-Talent
  innerhalb der aktuellen Klasse/Spec — die Spec selbst ergibt sich aus dem
  Hero-Talent, analog zum bisherigen Verhalten).
- **Standardmäßig** vorausgewählt: die Klasse und das Hero-Talent, die der
  Charakter gerade aktiv spielt.
- Ändert man die Auswahl, wirkt sich das **auf alle vier Tabs gleichzeitig**
  aus — BiS-Gear, Trinkets und Enhancements zeigen dann automatisch die
  Daten der ausgewählten Klasse/Spec statt der eigenen.
- Werteziele (Live-Balken mit den tatsächlichen Charakterwerten) ergeben nur
  für die eigene, aktuell gespielte Spec Sinn — bei abweichender Auswahl wird
  dieser eine Unterabschnitt entsprechend ausgeblendet oder deutlich als
  "nicht deine aktuelle Spec" gekennzeichnet, der Rest (Wertepriorität,
  Omnium Folio, BiS-Gear, Trinkets, Enhancements) bleibt normal nutzbar.

## 3. Guide-Tab

Drei Abschnitte, von oben nach unten, **jeder einzeln ein-/ausklappbar**
(Klick auf die Abschnitts-Überschrift):

### 3.1 Werteziele (oberster Abschnitt)
- Zeigt die empirischen Sekundärwert-Ziele (Mastery/Haste/Crit/Versatility)
  für die aktuelle Spec, mit einer Quellen-Auswahl (z.B. Mythic+ / Raid,
  abhängig davon was an Daten vorhanden ist).
- Für jeden Wert: ein Fortschrittsbalken, der den aktuellen Live-Wert des
  Charakters gegen das Ziel darstellt (farblich markiert: über Ziel /
  am Ziel / unter Ziel).
- Wird während eines Kampfes (Combat Lockdown) nicht neu berechnet; stattdessen
  ein Hinweistext "kann im Kampf nicht aktualisiert werden".

### 3.2 Wertepriorität
- Rangliste der Sekundärwerte (1. Mastery, 2. Haste, ...), mit optionaler
  Kontext-Auswahl (z.B. Raid / Mythic+ / General), falls die Priorität sich
  je nach Kontext unterscheidet.
- Gleichrangige Werte werden in einer Zeile zusammengefasst
  ("Mastery / Critical Strike").
- **Änderungs-Hinweis:** Wenn sich die Reihenfolge seit dem letzten
  Daten-Update geändert hat, erscheint ein Hinweistext ("Wertepriorität vor
  X Tagen geändert, vorher: ...") — automatisch nach 14 Tagen wieder
  ausgeblendet.
- **Guide-Autoren-Hinweis + Links:** Direkt darunter ein kurzer Hinweistext
  ("Talente/Rotation/Crafting bewusst nicht dupliziert") mit vier klickbaren
  Links (Wowhead, Archon, Icy-Veins, Murlok) zu den jeweiligen Guide-Seiten
  der aktuellen Spec. Klick kopiert den Link in ein Popup zum Kopieren.
- **Sim-Hinweis:** Ein weiterer kurzer Hinweis mit zwei klickbaren Links
  (Raidbots Top Gear, SimulationCraft/CurseForge) für individuelles Simmen.

### 3.3 Omnium Folio
- Liste der empfohlenen Runen, eine Zeile pro Woche/Schritt, jede Zeile mit:
  Icon des Runen-Spells, Label (z.B. "Week 1", auch abweichende Labels wie
  "Week 1-4" oder "Week 4 - Swap Core Rune" möglich), Runenname.
- Beim Hovern über eine Zeile: der echte Blizzard-Spell-Tooltip zum
  jeweiligen Runen-Spell (Beschreibung, Werte — alles original von Blizzard).
- Abschnitt bleibt komplett ausgeblendet, wenn für die aktuelle Spec keine
  Folio-Daten vorliegen.

## 4. BiS-Gear-Tab

- Liste aller Ausrüstungsslots (Kopf, Schulter, Brust, ... bis Trinkets/Ring)
  mit dem empfohlenen Item pro Slot.
- **Quellen-Dropdown** oben: Wowhead / Icy-Veins / Archon, sofern für die
  jeweilige Quelle Daten vorhanden sind (Dropdown nur sichtbar, wenn mehr als
  eine Quelle verfügbar ist).
- **Kontext-Unterreiter** je nach Quelle: Archon z.B. Raid vs. Mythic+,
  Wowhead ggf. nur eine Liste.
- Pro Item: Icon, Name (farbig nach Qualität), Klick öffnet den
  Standard-Item-Tooltip; Item-Herkunft (z.B. "Raid — Bossname", "Catalyst",
  oder Kombinationen wie "Raid | Catalyst | Vault") wird als kleiner
  Zusatztext angezeigt, sofern die Quelle diese Info liefert.
- **Besitz-Markierung:** Items, die der Charakter bereits besitzt (angelegt
  oder im Inventar), werden in der Liste optisch hervorgehoben (z.B.
  abweichende Zeilen-Hintergrundfarbe), damit auf einen Blick klar ist, was
  schon vorhanden ist und was noch fehlt.
- Fällt eine Quelle für die aktuelle Spec komplett weg (keine Daten), wird
  sie im Dropdown nicht angeboten.

## 5. Trinkets-Tab

- Eigene Liste ausschließlich für Trinket-Empfehlungen (getrennt vom
  allgemeinen BiS-Gear-Tab, da mehrere gleichwertige Optionen pro Kontext
  üblich sind).
- Pro Trinket: Icon, Name, Kontext-Zuordnung (Raid/Dungeon/Delves/Crafting je
  nach Datenlage), Tier-Einstufung (S/A/B/C/D) sofern vorhanden.
- Gleiche Besitz-Markierung wie beim BiS-Gear-Tab (siehe oben).

## 6. Enhancements-Tab

Drei Unterabschnitte, jeweils **einzeln ein-/ausklappbar**:

### 6.1 Verzauberungen
- Eine Zeile pro Ausrüstungsslot, der eine Verzauberung erhalten sollte:
  Slot-Name, empfohlene Verzauberung (Icon + Name), optional eine
  Alternative darunter, wenn eine zweite Empfehlung existiert.

### 6.2 Edelsteine
- Primärer Sockel-Edelstein (z.B. "Prismatic") als erste Zeile, danach
  sekundäre Sockel-Edelsteine als weitere Zeilen.

### 6.3 Verbrauchsmaterial
- Feste Kategorien (Fläschchen, Kampftrank, Essen, Waffenverstärkung,
  Verstärkungsrune), pro Kategorie das empfohlene Item.

### 6.4 Einkaufslisten-Export
- **Drei separate kleine Knöpfe**, je einer an den Kopfzeilen von
  Verzauberungen, Edelsteinen und Verbrauchsmaterial.
- Klick sammelt die Namen der aktuell angezeigten Items dieser einen
  Kategorie und öffnet ein Kopier-Popup mit einem Auctionator-kompatiblen
  Einkaufslisten-Import-String (Format: `Kategoriename^Item1^Item2^...`).
- Kein kombinierter Knopf über alle drei Kategorien — bewusst getrennt.

## 7. Datenquellen

Alle Inhalte kommen aus separaten, vom Update-Tool erzeugten Lua-Dateien pro
Klasse (Struktur wird in Phase 2 mit neuen Tabellennamen festgelegt, aber
inhaltlich identisch zu: Wowhead-Gear, Icy-Veins-Gear, Archon-Gear+Stats,
Wertepriorität, Omnium Folio). Fehlen Daten für eine Spec komplett, blendet
sich der jeweilige Abschnitt/Dropdown-Eintrag unauffällig aus, statt einen
Fehler oder eine leere Box zu zeigen.

## 8. Sprache

Nur Deutsch als Zielsprache; Englisch bleibt als technischer Fallback für
fehlende Übersetzungen (kein zusätzlicher Sprachumschalter im UI).

## 9. Settings

Ein Einstellungsbereich (Blizzard-Settings-Kategorie) mit mindestens:
- Panel-Breiten-Regler
- Ein-/Ausblenden pro Sichtbarkeits-Kategorie (z.B. "Werteziele im Panel
  zeigen"), analog zu den vorhandenen Tabs/Abschnitten
- Login-Nachricht ein/aus ("Grimoire geladen — tippe /grim zum Öffnen")
- Wertepriorität in Tooltips ein/aus (siehe 10.1)
- Trinket-Tier-Liste in Tooltips ein/aus, plus Filter "alle Klassen" vs.
  "nur eigene Klasse" (siehe 10.2)

## 10. Globale Tooltip-Erweiterungen

Diese Funktionen wirken auf **jeden Item-Tooltip im gesamten Spiel**, nicht
nur innerhalb des Grimoire-Panels.

### 10.1 Wertepriorität in Tooltips
- Bei jedem Sekundärwert, der auf einem Item-Tooltip angezeigt wird (Mastery,
  Haste, Critical Strike, Versatility — auch bei kombinierten Zeilen wie
  "+16 Tempo und +7 kritischer Trefferwert"), wird direkt daneben der
  Rang aus der aktuellen Wertepriorität eingeblendet (z.B. `#1`, `#2`, `#3`),
  basierend auf dem aktuell ausgewählten Hero-Talent/Kontext.
- Ein-/ausschaltbar in den Settings.

### 10.2 Trinket-Tier-Liste in Tooltips
- Bei Trinket-Tooltips wird ein zusätzlicher Abschnitt ("Beste Ausrüstung")
  eingeblendet: eine Liste von Klassen/Specs mit ihrer jeweiligen
  Tier-Einstufung (S/A/B/C/D) für genau dieses Item, farblich nach Tier
  markiert.
- **Einstellung:** Umschaltbar, ob diese Liste für **alle Klassen**
  angezeigt wird oder nur für die **eigene aktuell gespielte Klasse/Spec**
  gefiltert wird.
- Ein-/ausschaltbar in den Settings (unabhängig von 10.1).

## 11. Was bewusst NICHT enthalten ist

- Talente, Rotation, Crafting, Embellishments, PvP — keine dieser Kategorien
  wird in irgendeiner Form dargestellt oder verlinkt-referenziert
  (Ausnahme: die Guide-Autoren-Links im Guide-Tab verweisen bewusst nach
  außen auf die Original-Guides, zeigen aber keine eigenen Talent-/
  Rotation-/Crafting-Daten im Addon selbst).

---

*Offene Punkte für die nächste Runde: genaue Settings-Liste, Verhalten bei
Klassenwechsel/Charakterwechsel, Fehlerbehandlung bei fehlenden Daten,
Farbschema/visuelle Gestaltung.*
