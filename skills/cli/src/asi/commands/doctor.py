from __future__ import annotations

import json
import shutil
from typing import Any


REQUIRED_TOOLS = {
    "git": {
        "name": "git",
        "install": "https://git-scm.com/downloads",
    },
    "jq": {
        "name": "jq",
        "install": "https://jqlang.github.io/jq/download/",
        "optional": True,
    },
}


def check_tool(name: str) -> dict[str, Any]:
    path = shutil.which(name)
    info = REQUIRED_TOOLS.get(name, {"name": name, "install": "Unknown"})

    if not path:
        return {
            "name": name,
            "available": False,
            "path": None,
            "install": info["install"],
            "optional": info.get("optional", False),
        }

    return {
        "name": name,
        "available": True,
        "path": path,
        "install": info["install"],
        "optional": info.get("optional", False),
    }


def run_doctor() -> dict[str, Any]:
    results: dict[str, Any] = {}
    all_ok = True

    for tool in REQUIRED_TOOLS:
        check = check_tool(tool)
        results[tool] = check
        if not check["available"] and not check.get("optional", False):
            all_ok = False

    return {
        "ok": all_ok,
        "tools": results,
        "message": "All required dependencies available" if all_ok else "Missing dependencies",
    }


def cmd_doctor() -> int:
    result = run_doctor()
    print(json.dumps(result, indent=2))
    return 0 if result["ok"] else 1
