#!/usr/bin/env python3
"""Verify the structure and identity of an N64Recomp .nrm package."""

from __future__ import annotations

import argparse
import json
import sys
import zipfile
from pathlib import Path


MANIFEST_ENTRY = "mod.json"
REQUIRED_ENTRIES = {MANIFEST_ENTRY, "mod_binary.bin", "mod_syms.bin"}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("package", type=Path)
    parser.add_argument("--game-id", required=True)
    parser.add_argument("--mod-id", required=True)
    args = parser.parse_args()

    try:
        with zipfile.ZipFile(args.package) as archive:
            names = set(archive.namelist())
            missing = REQUIRED_ENTRIES - names
            if missing:
                raise ValueError(f"missing package entries: {', '.join(sorted(missing))}")
            manifest = json.loads(archive.read(MANIFEST_ENTRY))
    except (OSError, zipfile.BadZipFile, json.JSONDecodeError, ValueError) as exc:
        print(f"invalid NRM package: {exc}", file=sys.stderr)
        return 1

    expected = {"game_id": args.game_id, "id": args.mod_id}
    mismatches = {
        key: (value, manifest.get(key))
        for key, value in expected.items()
        if manifest.get(key) != value
    }
    if mismatches:
        for key, (expected_value, actual_value) in mismatches.items():
            print(
                f"manifest {key}: expected {expected_value!r}, got {actual_value!r}",
                file=sys.stderr,
            )
        return 1

    print(
        f"verified {args.package}: {manifest['id']} {manifest.get('version', '?')} "
        f"for {manifest['game_id']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
