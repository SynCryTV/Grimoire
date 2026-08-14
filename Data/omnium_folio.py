"""
Grimoire Scraper — Omnium Folio Empfehlungen (Wowhead BiS-Gear-Seite)
=============================================================================

Wowhead listet auf der BiS-Gear-Seite pro Spec einen "Omnium Folio Powers"
Abschnitt mit einer [rotation-timeline] aus 5 Wochen-Schritten
([rt-step=SPELLID text="Week N"]). Die Spell-Namen kommen aus dem
WH.Gatherer.addData(6, ...) Block (Datentyp 6 = Spells), analog zum
Item-Namens-Lookup fuer Datentyp 3.

Nutzung:
    pip install requests
    python omnium_folio.py
"""

import re
from bs4 import BeautifulSoup
from wowhead_gear import fetch_html

SPELL_LOOKUP_BLOCK_RE = re.compile(r"WH\.Gatherer\.addData\(6,\s*\d+,\s*(\{.*?\})\);", re.DOTALL)
SPELL_ENTRY_RE = re.compile(r'"(\d+)":\{"name_enus":"([^"]*)"')
FOLIO_SECTION_RE = re.compile(
    r'toc=\\"Omnium Folio\\"\](.*?)(?:\[h2 |\Z)',
    re.DOTALL,
)
TIMELINE_BLOCK_RE = re.compile(r'\[rotation-timeline\](.*?)\[\\/rotation-timeline\]', re.DOTALL)
RT_STEP_RE = re.compile(r'\[rt-step(?:-group)?=(\d+)\s+text=\\"([^\\"]*)\\"\]')


def build_spell_name_lookup(html: str) -> dict:
    """Baut ein SpellID -> Name Dict aus allen addData(6, ...) Bloecken."""
    lookup = {}
    for block_match in SPELL_LOOKUP_BLOCK_RE.finditer(html):
        for spell_id, name in SPELL_ENTRY_RE.findall(block_match.group(1)):
            lookup[int(spell_id)] = name
    return lookup



DOM_SPELL_RE = re.compile(r"/spell=(\d+)", re.IGNORECASE)
WEEK_RE = re.compile(r"(?:week|woche)\s*(\d+)", re.IGNORECASE)

def parse_omnium_folio_dom(html: str) -> list:
    soup = BeautifulSoup(html, "html.parser")
    spell_names = build_spell_name_lookup(html)

    # Find the Omnium section.
    heading = next(
        (
            h for h in soup.find_all(["h2", "h3", "h4"])
            if "omnium folio" in h.get_text(" ", strip=True).lower()
        ),
        None,
    )

    # Current rendered Wowhead HTML sometimes has the Omnium text inside a
    # normal content block instead of a dedicated heading. In that case find
    # the first rotation timeline whose nearby text mentions Omnium Folio.
    timeline = None

    if heading:
        timeline = heading.find_next(
            "div",
            class_=lambda c: c and "wh-rotation-timeline" in c,
        )

    if timeline is None:
        for candidate in soup.find_all(
            "div",
            class_=lambda c: c and "wh-rotation-timeline" in c,
        ):
            previous_text = ""
            cur = candidate
            for _ in range(8):
                cur = cur.find_previous()
                if cur is None:
                    break
                try:
                    previous_text += " " + cur.get_text(" ", strip=True)
                except Exception:
                    pass
                if "omnium folio" in previous_text.lower():
                    timeline = candidate
                    break
            if timeline is not None:
                break

    if timeline is None:
        return []

    result = []
    seen = set()

    # IMPORTANT:
    # Outlaw/Subtlety currently include visible labels "Rune 1", "Rune 2", ...
    # Assassination does NOT. The five links are still in the correct order,
    # so order in the rotation timeline is the reliable source of truth.
    for link in timeline.find_all("a", href=True):
        href = link.get("href", "")
        sm = DOM_SPELL_RE.search(href)

        if not sm:
            continue

        spell_id = int(sm.group(1))
        if spell_id in seen:
            continue

        seen.add(spell_id)

        name = (
            link.get("aria-label")
            or link.get_text(" ", strip=True)
            or spell_names.get(spell_id, "?")
        )

        result.append({
            "label": f"Rune {len(result) + 1}",
            "spellId": spell_id,
            "name": name,
        })

        # Omnium Folio currently consists of five ordered rune choices.
        if len(result) >= 5:
            break

    if result:
        print(f"  [DOM Omnium Folio] {len(result)} Schritte")

    return result

def parse_omnium_folio(html: str) -> list:
    dom = parse_omnium_folio_dom(html)
    if dom:
        return dom
    return parse_omnium_folio_bbcode(html)

def parse_omnium_folio_bbcode(html: str) -> list:
    """Gibt [{week, spellId, name}, ...] zurueck (leer, wenn kein Abschnitt
    gefunden -- z.B. Tank-/Heal-Specs koennen abweichende Struktur haben)."""
    section_match = FOLIO_SECTION_RE.search(html)
    if not section_match:
        print("  !! Omnium-Folio-Abschnitt nicht gefunden")
        return []

    spell_names = build_spell_name_lookup(html)
    result = []
    for timeline_block in TIMELINE_BLOCK_RE.findall(section_match.group(1)):
        for spell_id, label in RT_STEP_RE.findall(timeline_block):
            spell_id = int(spell_id)
            result.append({
                "label": label.strip(),
                "spellId": spell_id,
                "name": spell_names.get(spell_id, "?"),
            })

    print(f"  Omnium Folio: {len(result)} Schritte")
    return result


def main():
    url = "https://www.wowhead.com/guide/classes/demon-hunter/devourer/bis-gear"
    print(f"Fetching {url} ...")
    html = fetch_html(url)
    result = parse_omnium_folio(html)
    for e in result:
        print(e)


if __name__ == "__main__":
    main()
