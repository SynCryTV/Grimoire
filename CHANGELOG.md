# Änderungsverlauf

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
