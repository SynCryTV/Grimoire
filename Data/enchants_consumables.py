"""
Grimoire Scraper — Wowhead Enchants / Gems / Consumables
================================================================

Nutzung:
    pip install requests
    python enchants_consumables.py
"""

import re
from bs4 import BeautifulSoup
from wowhead_gear import fetch_html, build_item_name_lookup, ITEM_TAG_RE, TABLE_RE, ROW_RE, TD_RE, BOLD_TAG_RE

# Slot-Namen aus der Enchants-Tabelle -> Zielschema
GEM_ROW_LABELS = {"diamond": "primary_gem", "other gems": "secondary_gem"}

CONSUMABLE_ROW_MAP = {
    "flask": "flask",
    "combat potion": "combatPotion",
    "food": "food",
    "weapon buff": "weaponBuff",
    "augment rune": "augmentRune",
    # "Health Potion" bewusst nicht gemappt -- kein Feld im Original-Schema
}


def extract_items_from_cell(cell_text: str, item_names: dict) -> list:
    """Eine Zelle kann mehrere Items enthalten (' or ' getrennt). Gibt Liste von {itemId,name}."""
    items = []
    for m in ITEM_TAG_RE.finditer(cell_text):
        item_id = int(m.group(1))
        items.append({"itemId": item_id, "name": item_names.get(item_id, "?")})
    return items


def parse_two_col_table(table_text: str, item_names: dict) -> dict:
    """Parst eine [Label | Item(e)] Tabelle -> {label_lower: [items]}."""
    result = {}
    for row_match in ROW_RE.finditer(table_text):
        tds = TD_RE.findall(row_match.group(1))
        if len(tds) < 2:
            continue
        label = BOLD_TAG_RE.sub("", tds[0].replace("\\/", "/")).strip()
        if label.lower() == "slot" or label.lower() == "type":
            continue
        items = extract_items_from_cell(tds[1], item_names)
        if items:
            result[label.lower()] = (label, items)
    return result



DOM_ITEM_RE = re.compile(r"/item=(\d+)", re.IGNORECASE)

CONSUMABLE_ALIASES = {
    "flask": "flask", "phial": "flask", "fläschchen": "flask", "phiole": "flask",
    "combat potion": "combatPotion", "kampftrank": "combatPotion",
    "food": "food", "essen": "food",
    "weapon buff": "weaponBuff", "weapon enhancement": "weaponBuff",
    "weapon oil": "weaponBuff", "oil": "weaponBuff",
    "waffenverstärkung": "weaponBuff", "waffenöl": "weaponBuff",
    "augment rune": "augmentRune", "augment runes": "augmentRune",
    "verstärkungsrune": "augmentRune", "verstärkungsrunen": "augmentRune",
}
ENCHANT_SLOT_WORDS = (
    "weapon", "cloak", "chest", "bracers", "wrist", "boots", "feet", "ring",
    "legs", "head", "shoulder", "waffe", "umhang", "brust", "armschienen",
    "handgelenk", "stiefel", "füße", "ringe", "beine", "kopf", "schulter",
)

def _dom_items(cell, item_names):
    result, seen = [], set()
    for a in cell.find_all("a", href=True):
        m = DOM_ITEM_RE.search(a.get("href", ""))
        if not m:
            continue
        iid = int(m.group(1))
        if iid in seen:
            continue
        seen.add(iid)
        result.append({"itemId": iid, "name": a.get_text(" ", strip=True) or item_names.get(iid, "?")})
    return result

def parse_enchants_gems_consumables_dom(html: str) -> dict:
    soup = BeautifulSoup(html, "html.parser")
    item_names = build_item_name_lookup(html)
    enchants, consumables = [], {}
    gems = {"primary": None, "secondary": []}

    for table in soup.find_all("table"):
        for row in table.find_all("tr"):
            cells = row.find_all(["td", "th"])
            if len(cells) < 2:
                continue
            label = re.sub(r"\s+", " ", cells[0].get_text(" ", strip=True)).strip()
            key = label.lower().strip(" :")
            if key in ("slot", "type", "typ", "platz", ""):
                continue

            items = []
            for cell in cells[1:]:
                items.extend(_dom_items(cell, item_names))
            # dedupe
            items = list({x["itemId"]: x for x in items}.values())
            if not items:
                continue

            if "diamond" in key or "primary gem" in key:
                gems["primary"] = items[0]
                continue
            if "other gems" in key:
                gems["secondary"] = items
                continue
            if key == "gems":
                if not gems["primary"]:
                    gems["primary"] = items[0]
                    gems["secondary"] = items[1:]
                continue

            field = None
            for alias, target in CONSUMABLE_ALIASES.items():
                if alias == key or alias in key:
                    field = target
                    break
            if field:
                consumables[field] = items[0]
                continue

            if any(word == key or word in key for word in ENCHANT_SLOT_WORDS):
                entry = {"slot": label, "best": items[0]}
                if len(items) > 1:
                    entry["alternate"] = items[1]
                enchants.append(entry)

    useful = len(enchants) + len(consumables) + (1 if gems["primary"] else 0)
    if useful:
        print(f"  [DOM Enhancements] Enchants: {len(enchants)}, Gems: {'ja' if gems['primary'] else 'nein'}, Consumables: {len(consumables)}")
        return {"enchants": enchants, "gems": gems, "consumables": consumables}
    return {}


SLOT_CANONICAL = {
    "shoulder": "Shoulders",
    "shoulders": "Shoulders",
    "boot": "Feet",
    "boots": "Feet",
    "feet": "Feet",
    "bracer": "Wrist",
    "bracers": "Wrist",
    "wrist": "Wrist",
    "helm": "Head",
    "head": "Head",
    "weapon": "Weapon",
    "main hand": "Weapon",
    "weapons (1h)": "Weapon",
    "weapon (2h)": "Weapon",
    "weapons (2h & dual-wield)": "Weapon",
    "ring": "Ring",
    "rings": "Ring",
    "chest": "Chest",
    "legs": "Legs",
}


def _canon_slot(slot):
    raw = re.sub(r"\s+", " ", str(slot or "")).strip()
    return SLOT_CANONICAL.get(raw.lower(), raw)


def _dedupe_enchants(entries):
    out = []
    seen = set()

    for entry in entries or []:
        best = entry.get("best") or {}
        item_id = best.get("itemId")
        if not item_id:
            continue

        slot = _canon_slot(entry.get("slot"))
        key = (slot.lower(), int(item_id))

        if key in seen:
            continue
        seen.add(key)

        copy = dict(entry)
        copy["slot"] = slot
        out.append(copy)

    return out


def _infer_missing_from_dom(html, data):
    """Fill obvious missing categories from item names/row text without guessing IDs."""
    soup = BeautifulSoup(html, "html.parser")
    item_names = build_item_name_lookup(html)

    all_items = {}
    for a in soup.find_all("a", href=True):
        m = DOM_ITEM_RE.search(a.get("href", ""))
        if not m:
            continue
        iid = int(m.group(1))
        name = a.get_text(" ", strip=True) or item_names.get(iid, "?")
        all_items[iid] = name

    gems = data["gems"]
    consumables = data["consumables"]

    # Primary Midnight gem: a Diamond is unambiguously the primary gem recommendation.
    if not gems.get("primary"):
        for iid, name in all_items.items():
            if "diamond" in name.lower():
                gems["primary"] = {"itemId": iid, "name": name}
                break

    # Known semantic item-name classes. These only classify items already present
    # on the current Wowhead page; no external item is invented.
    for iid, name in all_items.items():
        low = name.lower()
        item = {"itemId": iid, "name": name}

        if "weaponBuff" not in consumables and any(
            token in low for token in (" oil", "oil ", "whetstone", "weightstone")
        ):
            consumables["weaponBuff"] = item

        if "augmentRune" not in consumables and "augment rune" in low:
            consumables["augmentRune"] = item

        if "flask" not in consumables and (
            low.startswith("flask ") or " flask " in low
        ):
            consumables["flask"] = item

        if "combatPotion" not in consumables and (
            "potion" in low or "draught" in low
        ):
            # Health potions are intentionally not treated as combat potions.
            if "health" not in low and "healing" not in low:
                consumables["combatPotion"] = item

    return data


def _merge_enhancement_data(dom, legacy, html):
    dom = dom or {"enchants": [], "gems": {"primary": None, "secondary": []}, "consumables": {}}
    legacy = legacy or {"enchants": [], "gems": {"primary": None, "secondary": []}, "consumables": {}}

    result = {
        "enchants": _dedupe_enchants((dom.get("enchants") or []) + (legacy.get("enchants") or [])),
        "gems": {
            "primary": (dom.get("gems") or {}).get("primary")
                or (legacy.get("gems") or {}).get("primary"),
            "secondary": [],
        },
        "consumables": {},
    }

    # Secondary gems: preserve all distinct recommendations.
    seen_gems = set()
    for source in (dom, legacy):
        for gem in (source.get("gems") or {}).get("secondary", []) or []:
            iid = gem.get("itemId")
            if iid and iid not in seen_gems:
                seen_gems.add(iid)
                result["gems"]["secondary"].append(gem)

    # DOM wins, legacy fills gaps.
    for field in ("flask", "combatPotion", "healthPotion", "weaponBuff", "augmentRune", "food"):
        value = (dom.get("consumables") or {}).get(field)
        if value is None:
            value = (legacy.get("consumables") or {}).get(field)
        if value is not None:
            result["consumables"][field] = value

    return _infer_missing_from_dom(html, result)



# Guaranteed utility consumables.
# These are intentionally present for every spec even if a Wowhead author
# forgets to include them in that spec's table.
PERMANENT_CONSUMABLES = {
    "healthPotion": {
        "itemId": 271884,
        "name": "Concentrated Silvermoon Health Potion",
        "label": "Health Potion",
    },
    "invisibilityPotion": {
        "itemId": 241303,
        "name": "Void-Shrouded Tincture",
        "label": "Invisibility Potion",
    },
}


def _dynamic_consumable_key(label: str, item_id: int) -> str:
    """Stable Lua-safe key for extra Wowhead consumable rows."""
    low = re.sub(r"\s+", " ", (label or "")).strip().lower()

    known = {
        "flask": "flask",
        "phial": "flask",
        "combat potion": "combatPotion",
        "health potion": "healthPotion",
        "healing potion": "healthPotion",
        "invisiblity potion": "invisibilityPotion",  # Wowhead currently has this typo
        "invisibility potion": "invisibilityPotion",
        "weapon buff": "weaponBuff",
        "weapon oil": "weaponBuff",
        "augment rune": "augmentRune",
        "food": "food",
        "group feast": "food",
    }
    if low in known:
        return known[low]

    # Dynamic extras are retained instead of being discarded.
    slug = re.sub(r"[^a-z0-9]+", "_", low).strip("_")
    if not slug:
        slug = f"extra_{item_id}"
    return "extra_" + slug


def parse_all_consumables_dom(html: str) -> dict:
    """
    Read the visible Wowhead 'Best Consumables' table as-is.

    Unlike the old fixed schema, every row with an item is preserved. This
    means spec-specific utility consumables survive automatically.
    """
    soup = BeautifulSoup(html, "html.parser")
    item_names = build_item_name_lookup(html)
    result = {}

    for table in soup.find_all("table"):
        rows = table.find_all("tr")
        if not rows:
            continue

        table_text = re.sub(r"\s+", " ", table.get_text(" ", strip=True)).lower()

        # Restrict to the actual consumables table; don't harvest unrelated
        # item tables from the guide.
        if not any(x in table_text for x in (
            "combat potion", "health potion", "weapon buff",
            "weapon oil", "augment rune", "group feast",
            "invisiblity potion", "invisibility potion",
        )):
            continue

        for row in rows:
            cells = row.find_all(["td", "th"])
            if len(cells) < 2:
                continue

            label = re.sub(r"\s+", " ", cells[0].get_text(" ", strip=True)).strip()
            if label.lower() in ("type", "typ", "consumable", ""):
                continue

            items = []
            for cell in cells[1:]:
                items.extend(_dom_items(cell, item_names))

            # Keep every recommendation from the row. The first item remains
            # the primary value for backwards compatibility; alternatives are
            # stored as additional dynamic entries.
            seen = set()
            items = [x for x in items if not (x["itemId"] in seen or seen.add(x["itemId"]))]

            for idx, item in enumerate(items):
                key = _dynamic_consumable_key(label, item["itemId"])
                if idx > 0 or key in result:
                    key = f"{key}_{item['itemId']}"

                value = dict(item)
                value["label"] = label
                result[key] = value

    return result


def _merge_dynamic_consumables(result: dict, html: str) -> dict:
    consumables = result.setdefault("consumables", {})

    # --------------------------------------------------------
    # Globale Deduplizierung nach itemId.
    #
    # Ein Item darf pro Spec nur EINMAL vorkommen, egal ob es
    # aus Legacy, DOM, einer dynamischen Wowhead-Zeile oder
    # unserem permanenten Fallback stammt.
    # --------------------------------------------------------
    deduped = {}
    seen_item_ids = set()

    # Bestehende Parser-Daten haben Priorität.
    for key, item in list(consumables.items()):
        if not isinstance(item, dict):
            continue

        item_id = item.get("itemId")
        if not item_id:
            continue

        item_id = int(item_id)
        if item_id in seen_item_ids:
            continue

        seen_item_ids.add(item_id)
        deduped[key] = item

    consumables.clear()
    consumables.update(deduped)

    # Danach ALLE sichtbaren Wowhead-Consumables ergänzen,
    # aber niemals dieselbe itemId ein zweites Mal.
    dynamic = parse_all_consumables_dom(html)

    for key, item in dynamic.items():
        item_id = item.get("itemId")
        if not item_id:
            continue

        item_id = int(item_id)
        if item_id in seen_item_ids:
            continue

        final_key = key
        if final_key in consumables:
            final_key = f"{key}_{item_id}"

        consumables[final_key] = item
        seen_item_ids.add(item_id)

    # Die beiden universellen Utility-Items nur hinzufügen,
    # wenn genau diese itemId noch NICHT vorhanden ist.
    for key, item in PERMANENT_CONSUMABLES.items():
        item_id = int(item["itemId"])

        if item_id in seen_item_ids:
            continue

        final_key = key
        if final_key in consumables:
            final_key = f"{key}_{item_id}"

        consumables[final_key] = dict(item)
        seen_item_ids.add(item_id)

    return result


def parse_enchants_gems_consumables(html: str) -> dict:
    # Parse BOTH representations. A partially successful DOM parse must not
    # suppress categories that the legacy Wowhead data still exposes.
    dom = parse_enchants_gems_consumables_dom(html)

    try:
        legacy = parse_enchants_gems_consumables_bbcode(html)
    except Exception:
        legacy = {
            "enchants": [],
            "gems": {"primary": None, "secondary": []},
            "consumables": {},
        }

    merged = _merge_enhancement_data(dom, legacy, html)
    merged = _merge_dynamic_consumables(merged, html)

    print(
        f"  [Merged Enhancements] Enchants: {len(merged['enchants'])}, "
        f"Gems: {'ja' if merged['gems'].get('primary') else 'nein'}, "
        f"Consumables: {len(merged['consumables'])}"
    )

    return merged


def parse_enchants_gems_consumables_bbcode(html: str) -> dict:
    item_names = build_item_name_lookup(html)
    tables = TABLE_RE.findall(html)

    enchants = []
    gems = {"primary": None, "secondary": []}
    consumables = {}

    for table_text in tables:
        parsed = parse_two_col_table(table_text, item_names)
        if not parsed:
            continue

        # Gems/Enchants-Tabelle: erkennbar an einer 'Diamond'-Zeile ODER einer
        # 'Weapon'-Slot-Zeile (manche Klassenseiten haben keine saubere Gem-Zeile).
        is_enchants_table = any("diamond" in key for key in parsed) or "weapon" in parsed
        if is_enchants_table:
            for key, (label, items) in parsed.items():
                if "diamond" in key:
                    gems["primary"] = items[0]
                elif key == "other gems":
                    gems["secondary"] = items
                elif key == "gems":
                    # Unsauberer Freitext-Fall (z.B. "One X and a mix of Y and Z") --
                    # bestmoegliche Zuordnung: erstes Item als primary, Rest als secondary.
                    if items:
                        gems["primary"] = items[0]
                        gems["secondary"] = items[1:]
                else:
                    entry = {"slot": label, "best": items[0]}
                    if len(items) > 1:
                        entry["alternate"] = items[1]
                    enchants.append(entry)

        # Consumables-Tabelle enthaelt 'flask' als Zeile
        elif "flask" in parsed:
            for key, (label, items) in parsed.items():
                field = CONSUMABLE_ROW_MAP.get(key)
                if field:
                    consumables[field] = items[0]

    print(f"  Enchants: {len(enchants)}, Gems: {'ja' if gems['primary'] else 'nein'}, "
          f"Consumables: {len(consumables)}")

    return {"enchants": enchants, "gems": gems, "consumables": consumables}


def to_lua_snippet(data: dict) -> str:
    lines = []

    lines.append("    enchants = {")
    for e in data["enchants"]:
        alt = ""
        if "alternate" in e:
            a = e["alternate"]
            alt = f', alternate = {{ itemId = {a["itemId"]}, name = "{a["name"]}" }}'
        b = e["best"]
        lines.append(f'      {{ slot = "{e["slot"]}", best = {{ itemId = {b["itemId"]}, name = "{b["name"]}" }}{alt} }},')
    lines.append("    },")

    g = data["gems"]
    lines.append("    gems = {")
    if g["primary"]:
        lines.append(f'      primary = {{ itemId = {g["primary"]["itemId"]}, name = "{g["primary"]["name"]}" }},')
    lines.append("      secondary = {")
    for s in g["secondary"]:
        lines.append(f'        {{ itemId = {s["itemId"]}, name = "{s["name"]}" }},')
    lines.append("      },")
    lines.append("    },")

    lines.append("    consumables = {")
    for field, item in data["consumables"].items():
        lines.append(f'      {field} = {{ itemId = {item["itemId"]}, name = "{item["name"]}" }},')
    lines.append("    },")

    return "\n".join(lines)


def main():
    url = "https://www.wowhead.com/guide/classes/demon-hunter/devourer/enchants-gems-pve-dps"
    print(f"Fetching {url} ...")
    html = fetch_html(url)
    data = parse_enchants_gems_consumables(html)
    print("\n=== Lua-Output ===")
    print(to_lua_snippet(data))


if __name__ == "__main__":
    main()
