# Änderungsverlauf

## 5.2.15

- Fensteranker auf den bewährten Stand aus 5.2.9 zurückgestellt.
- Automatische Abenteuerführer-Abfragen beim Aufbau der BiS-Liste entfernt; sie konnten die Blizzard-Fensterverwaltung stören.
- BiS-Itemnamen ohne Alternativen behalten die volle Zeilenbreite.

## 5.2.11

- Grimoire-Fenster ist vom geschützten CharacterFrame-Ankersystem entkoppelt; das Öffnen erzeugt keinen „anchor family connection“-Lua-Fehler mehr.

## 5.2.10

- BiS-Listen ohne Alternativen nutzen die volle Zeilenbreite für Itemnamen.
- Murlok- und KeystoneLoot-Einträge ergänzen nach dem Laden die echte Boss-/Instanzquelle aus dem Abenteuerführer.

## 5.2.9

- Wertepriorität: Heldentalent- und Kontext-Dropdown haben nun einen festen sichtbaren Abstand und überlappen nicht mehr.

## 5.2.8

- Trinket-Tooltips: Persönliche S+-Markierungen stehen immer ganz oben als auffällige lila Zeile mit Spec-Icon und bleiben auch bei ausgeblendeten normalen Tiers sichtbar.
- Danach folgen zuerst die aktuell eingeloggte Klasse, dann weitere Klassen; innerhalb jeder Gruppe S bis D.

## 5.2.7

- Trinket-Tooltip verwendet wieder die ursprüngliche Klassen- und Spec-Reihenfolge statt einer Tier-Sortierung.

## 5.2.6

- Trinket-Tooltip wieder global nach S, A, B, C und D sortiert; bei gleichem Tier wird die eingeloggte Klasse bevorzugt.

## 5.2.5

- In Trinket-Tooltips stehen alle Einträge der aktuell eingeloggten Klasse grundsätzlich vor anderen Klassen; innerhalb jeder Gruppe bleibt die Reihenfolge S bis D erhalten.

## 5.2.4

- Trinket-Tierhinweise im Item-Tooltip werden nun immer nach S, A, B, C und D sortiert. Bei gleichem Tier erscheint die eigene Klasse vor anderen Klassen.

## 5.2.3

- Item-Tooltips verwenden nun die vollständige Trinket-Tierliste statt nur der beiden Overall-BiS-Slots. Alle eingeblendeten S- bis D-Tiers erscheinen dadurch zuverlässig, ebenso persönlich markierte S+-Trinkets.
- Heldentalent-Empfehlungen werden für beide Hero-Bäume pro Spec korrekt zugeordnet; der Kontext-Dropdown bleibt innerhalb der Guide-Ansicht.

## 5.2.2

- Bestehende Profile werden auf die getrennten Trinket-Tooltipfilter migriert: Normale Tierhinweise bleiben neben persönlichen S+-Markierungen sichtbar.
- Der Einstellungs-Schalter für normale Trinket-Tierhinweise schaltet nun die Tierfilter S bis D gemeinsam; die persönliche S+-Anzeige bleibt unabhängig.

## 5.2.0

- Wertepriorität verwendet nun KeystoneLoot statt Wowhead, einschließlich der Item-Tooltip-Ränge.
- Der Heldentalent-Dropdown markiert die von KeystoneLoot aktuell empfohlene Auswahl.
- Der Standardlauf des Scrapers aktualisiert Wertepriorität und Heldentalent-Empfehlung gemeinsam mit den KeystoneLoot-BiS-Daten; der frühere Wowhead-Prioritätslauf entfällt.
- Auktionshaus-Ansicht scrollt per Mausrad nun weich und trägheitsbasiert.

## 5.1.6

- Trinket-Tab: Separate Tooltip-Tierauswahl für S, A, B, C und D. Sie beeinflusst die Item-Tooltips, ohne die sichtbare Trinketliste zu verändern.

## 5.1.5

- KeystoneLoot-Daten werden beim Addon-Start im Hintergrund geladen, verbreitern das Grimoire-Fenster aber erst, wenn der BiS-Tab aktiv geöffnet ist und Alternativen vorliegen.

## 5.1.4

- Persönliche S+-Trinketmarkierungen, die S+-Kategorie und ihre Tooltip-Hinweise verwenden nun Lila statt Artefaktorange.

## 5.1.3

- KeystoneLoot-BiS prüft beim Zurückwechseln in den Tab erneut auf Alternativen und verbreitert die Ansicht dann zuverlässig.
- Das BiS-Fenster animiert beim Verbreitern und beim Zurückkehren zur normalen Breite weich.

## 5.1.2

- Trinketliste: Persönlich markierte Items erscheinen automatisch ganz oben in „S+-Tier (Markiert)“ in Artefaktfarbe.
- Neuer S+-Schalter direkt oben in der Trinketansicht, um nur persönliche S+-Marker in Item-Tooltips ein- oder auszublenden.

## 5.1.1

- Normale Trinket-Tierwertungen bleiben sichtbar; die persönliche Empfehlung steht separat als S+ in Artefaktfarbe daneben.
- Die BiS-Ansicht wird nur bei KeystoneLoot mit vorhandenen Slot-Alternativen verbreitert; sonst nutzt Grimoire wieder die normale Fensterbreite.

## 5.1.0

- Trinkets lassen sich rechts in der Liste als persönliche S-Tier-Empfehlung markieren; aktive Marker erscheinen in Artefaktfarbe.
- Neue Einstellung für die normalen Trinket-Tierhinweise im Tooltip. Wenn sie deaktiviert ist, zeigt der Tooltip ausschließlich persönliche S-Tier-Markierungen.

## 5.0.0

- Liquid-Armory-Trinket-Integration wieder entfernt.
- Versionsnummer für WowUp-Update erhöht.

## 4.1.10

- KeystoneLoot-Slotzuordnung korrigiert: Die zweite Waffe wird zuverlässig als Nebenhand angezeigt, auch wenn WoW beide Einhandwaffen technisch als Mainhand meldet.

## 4.1.9

- KeystoneLoot-Alternativen in der BiS-Liste erhalten Item-Icons und vollständige Tooltips beim Darüberfahren.

## 4.1.8

- Gewählte Quelle und Kontext werden für BiS-Gear, Enhancements und den Auktionshaus-Tab dauerhaft gespeichert.
- Der Auktionshaus-Tab merkt sich zusätzlich Klasse und Spezialisierung.

## 4.1.7

- Quellenübersicht in den Einstellungen optisch vereinfacht.

## 4.1.6

- KeystoneLoot-BiS breiter und kompakter: Hauptempfehlung links, alle Alternativen desselben Slots rechts daneben.

## 4.1.5

- Einstellungen um „Info & Quellen“ erweitert: Links zu allen verwendeten Datenquellen lassen sich direkt kopieren.

## 4.1.4

- Auktionshaus-Tab um die Wowhead-/KeystoneLoot-Quellenwahl ergänzt.
- KeystoneLoot-Edelsteine inklusive aller Alternativen können nun direkt gesucht, favorisiert oder an Auctionator übergeben werden.
- Der KeystoneLoot-API-Zeitstempel wird im Auktionshaus-Tab angezeigt; der Scraper aktualisiert diese Daten bei jedem normalen Komplettlauf.

## 4.1.3

- KeystoneLoot-BiS zeigt nun alle API-Empfehlungen: Slot-Alternativen und Einträge mit unbekanntem Slot werden nicht länger ausgeblendet.

## 4.1.2

- Eigenen KeystoneLoot-Tab entfernt: Die Quelle ist ausschließlich in der vorhandenen BiS-Gear-Auswahl integriert.
- KeystoneLoot-Edelsteine zeigen nun sämtliche API-Alternativen der gewählten Overall-, Mythic+- oder Raid-Liste.

## 4.1.1

- KeystoneLoot-Dual-Wield korrigiert: Mainhand und Nebenhand werden getrennt angezeigt, unter anderem für Dämonenjäger.
- Fernkampfwaffen werden bei KeystoneLoot ebenfalls als Waffe erkannt.

## 4.1.0

- KeystoneLoot als neue, umschaltbare BiS-Quelle ergänzt: Overall, Mythic+ und Raid für alle Specs.
- KeystoneLoot-BiS-Items inklusive gemeldeter Sockel und VZ-Hinweise ergänzt.
- Im Tab „Verzauberungen & Verbrauchsgüter“ ist KeystoneLoot als Quelle auswählbar; die Edelsteine folgen dem gewählten KeystoneLoot-Kontext.
- Fläschchen, Essen, Tränke und kaufbare Verzauberungs-Items bleiben bei Wowhead, da KeystoneLoot diese Daten nicht per API bereitstellt. Damit bleiben Auctionator-Einkaufslisten vollständig nutzbar.

## 4.0.3

- Archon als Datenquelle entfernt.
- Murlok ergänzt: aktuelle Mythic+-BiS-Listen und sekundäre Werteziele für alle Specs.
- Murlok-BiS vollständig: alle 16 Ausrüstungsslots einschließlich Hände und Beine.
- Raid-Werteziele: Median aus etwa 1.000 Mythic-Rankings pro Spec, gleichmäßig über alle Bosse der aktuellen Raidzone verteilt.
- Die Raid-Daten stammen von Warcraft Logs; M+-Werteziele und BiS stammen von Murlok.
- Itemwerte werden lokal gecacht, damit spätere Aktualisierungen deutlich schneller laufen.
