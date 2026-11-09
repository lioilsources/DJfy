#!/usr/bin/env python3
"""Check fastlane store metadata against App Store / Google Play length limits."""
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent / "fastlane" / "metadata"
LIMITS = {
    "ios": {"name.txt": 30, "subtitle.txt": 30, "keywords.txt": 100, "promotional_text.txt": 170,
            "description.txt": 4000, "release_notes.txt": 4000},
    "android": {"title.txt": 30, "short_description.txt": 80, "full_description.txt": 4000},
}

errors = []
for store, limits in LIMITS.items():
    for locale in sorted(p for p in (ROOT / store).iterdir() if p.is_dir()):
        for name, limit in limits.items():
            f = locale / name
            if not f.exists():
                errors.append(f"{store}/{locale.name}/{name}: missing")
                continue
            text = f.read_text(encoding="utf-8").rstrip("\n")
            if len(text) > limit:
                errors.append(f"{store}/{locale.name}/{name}: {len(text)} > {limit}")
            if name == "keywords.txt" and (", " in text or " ," in text):
                errors.append(f"{store}/{locale.name}/{name}: space around comma")

print("\n".join(errors) or "store metadata OK")
sys.exit(1 if errors else 0)
