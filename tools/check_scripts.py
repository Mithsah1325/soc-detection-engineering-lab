from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

BASH_FILES = [
    ROOT / "Attack-Simulations" / "brute_force_attack.sh",
    ROOT / "Attack-Simulations" / "exfiltration_attack.sh",
    ROOT / "Automation-Scripts" / "block_ip.sh",
]

PS1_FILES = [
    ROOT / "Attack-Simulations" / "process_injection_attack.ps1",
    ROOT / "Automation-Scripts" / "block_ip.ps1",
]


def _check_bash_file(path: Path) -> list[str]:
    content = path.read_text(encoding="utf-8")
    errors: list[str] = []
    if not content.startswith("#!/bin/bash"):
        errors.append("Missing or incorrect bash shebang")
    if "set -euo pipefail" not in content:
        errors.append("Missing 'set -euo pipefail'")
    return [f"{path.name}: {error}" for error in errors]


def _check_ps_file(path: Path) -> list[str]:
    content = path.read_text(encoding="utf-8")
    errors: list[str] = []
    if "$ErrorActionPreference = \"Stop\"" not in content:
        errors.append("Missing strict error handling ('$ErrorActionPreference = \"Stop\"')")
    return [f"{path.name}: {error}" for error in errors]


def main() -> int:
    all_errors: list[str] = []

    for script in BASH_FILES:
        all_errors.extend(_check_bash_file(script))

    for script in PS1_FILES:
        all_errors.extend(_check_ps_file(script))

    if all_errors:
        print("Script quality checks failed:")
        for error in all_errors:
            print(f"- {error}")
        return 1

    print("Script quality checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
