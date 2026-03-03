import json
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
SIGMA_DIR = ROOT / "Sigma-Rules"
EVENTS_PATH = ROOT / "tests" / "data" / "events.jsonl"
EXPECTATIONS_PATH = ROOT / "tests" / "data" / "expectations.json"


def _load_events(path: Path) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        events.append(json.loads(line))
    return events


def _normalize(value: Any) -> str:
    if value is None:
        return ""
    return str(value)


def _match_field(event: dict[str, Any], key: str, expected: Any) -> bool:
    if "|contains" in key:
        field = key.split("|", 1)[0]
        current = _normalize(event.get(field)).lower()
        if isinstance(expected, list):
            return any(str(item).lower() in current for item in expected)
        return str(expected).lower() in current

    if "|endswith" in key:
        field = key.split("|", 1)[0]
        current = _normalize(event.get(field)).lower()
        return current.endswith(str(expected).lower())

    current = event.get(key)
    if isinstance(expected, list):
        return current in expected
    return current == expected


def _event_matches(rule: dict[str, Any], event: dict[str, Any]) -> bool:
    detection = rule.get("detection", {})
    selection = detection.get("selection", {})
    if not isinstance(selection, dict) or not selection:
        return False

    for field_expr, expected in selection.items():
        if not _match_field(event, field_expr, expected):
            return False
    return True


def _validate_rule_schema(rule_path: Path, rule: dict[str, Any]) -> list[str]:
    required = ["title", "id", "logsource", "detection", "level", "tags"]
    errors: list[str] = []

    for item in required:
        if item not in rule:
            errors.append(f"Missing required field '{item}'")

    tags = rule.get("tags", [])
    if not isinstance(tags, list) or not tags:
        errors.append("Field 'tags' must be a non-empty list")

    return [f"{rule_path.name}: {error}" for error in errors]


def main() -> int:
    events = _load_events(EVENTS_PATH)
    expected = json.loads(EXPECTATIONS_PATH.read_text(encoding="utf-8"))

    all_errors: list[str] = []

    for rule_path in sorted(SIGMA_DIR.glob("*.yml")):
        rule = yaml.safe_load(rule_path.read_text(encoding="utf-8"))
        if not isinstance(rule, dict):
            all_errors.append(f"{rule_path.name}: rule is not a valid YAML object")
            continue

        all_errors.extend(_validate_rule_schema(rule_path, rule))

        rel = str(rule_path.relative_to(ROOT)).replace("\\", "/")
        expected_ids = set(expected.get(rel, []))
        matched_ids = {event.get("id") for event in events if _event_matches(rule, event)}

        if expected_ids and not expected_ids.issubset(matched_ids):
            missing = sorted(expected_ids - matched_ids)
            all_errors.append(
                f"{rule_path.name}: expected events not matched: {', '.join(missing)}"
            )

    if all_errors:
        print("Detection test failures:")
        for error in all_errors:
            print(f"- {error}")
        return 1

    print("All Sigma rule checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
