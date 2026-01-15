"""Parse and manage doctor artifacts."""

import hashlib
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml


DOCTOR_DIR = Path(".doctor")
EVIDENCE_DIR = DOCTOR_DIR / "evidence"
SESSION_FILE = DOCTOR_DIR / "session.yaml"
TREATMENT_FILE = DOCTOR_DIR / "treatment.md"

VALID_STATUSES = ("investigating", "diagnosed", "treated", "abandoned")
SYMPTOM_CATEGORIES = ("error", "timeout", "crash", "wrong_output", "performance", "unknown")
RISK_LEVELS = ("low", "medium", "high")
EFFORT_LEVELS = ("trivial", "small", "medium", "large")


def now_utc() -> datetime:
    """Return current UTC time."""
    return datetime.now(timezone.utc)


def to_rfc3339(dt: datetime) -> str:
    """Convert datetime to RFC3339 UTC string."""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def hash_content(content: str) -> str:
    """Generate short hash for content."""
    return hashlib.sha256(content.encode()).hexdigest()[:12]


def ensure_doctor_dir() -> None:
    """Create .doctor directory structure."""
    DOCTOR_DIR.mkdir(exist_ok=True)
    EVIDENCE_DIR.mkdir(exist_ok=True)


def session_exists() -> bool:
    """Check if a session file exists."""
    return SESSION_FILE.exists()


def load_session() -> dict[str, Any] | None:
    """Load current session from disk."""
    if not SESSION_FILE.exists():
        return None
    content = SESSION_FILE.read_text(encoding="utf-8")
    return yaml.safe_load(content) or {}


def save_session(session: dict[str, Any]) -> None:
    """Save session to disk."""
    ensure_doctor_dir()
    session["updated_at"] = to_rfc3339(now_utc())
    SESSION_FILE.write_text(yaml.dump(session, default_flow_style=False, sort_keys=False), encoding="utf-8")


def init_session(patient: str = "") -> dict[str, Any]:
    """Initialize a new diagnosis session."""
    ensure_doctor_dir()
    now = to_rfc3339(now_utc())
    session = {
        "status": "investigating",
        "created_at": now,
        "updated_at": now,
        "patient": patient or Path.cwd().name,
        "symptoms": [],
        "hypotheses": [],
        "diagnosis": None,
        "evidence_files": [],
    }
    save_session(session)
    return session


def add_symptom(description: str, category: str = "unknown", evidence: str = "") -> dict[str, Any]:
    """Add a symptom to the current session."""
    session = load_session()
    if session is None:
        session = init_session()
    
    symptom = {
        "description": description,
        "category": category if category in SYMPTOM_CATEGORIES else "unknown",
        "evidence": evidence,
    }
    session["symptoms"].append(symptom)
    save_session(session)
    return session


def add_hypothesis(description: str, confidence: int, falsifiable_by: str = "") -> dict[str, Any]:
    """Add a hypothesis to the current session."""
    session = load_session()
    if session is None:
        session = init_session()
    
    hypothesis = {
        "description": description,
        "confidence": max(0, min(100, confidence)),
        "evidence_for": [],
        "evidence_against": [],
        "falsifiable_by": falsifiable_by,
    }
    session["hypotheses"].append(hypothesis)
    save_session(session)
    return session


def set_diagnosis(summary: str, confidence: int, root_cause: str = "", factors: list[str] | None = None) -> dict[str, Any]:
    """Set the diagnosis for the current session."""
    session = load_session()
    if session is None:
        session = init_session()
    
    session["diagnosis"] = {
        "summary": summary,
        "confidence": max(0, min(100, confidence)),
        "root_cause": root_cause,
        "contributing_factors": factors or [],
    }
    session["status"] = "diagnosed"
    save_session(session)
    return session


def surface_scan(patterns: list[str] | None = None, path: str = ".") -> list[str]:
    """
    Scan for relevant files using glob patterns.
    Returns list of matching file paths.
    """
    if patterns is None:
        patterns = ["*.py", "*.ts", "*.js", "*.yaml", "*.yml", "*.json", "*.md", "*.toml"]
    
    results = []
    base = Path(path)
    
    for pattern in patterns:
        for f in base.rglob(pattern):
            # Skip hidden directories and common noise
            parts = f.parts
            allowed_hidden = {".doctor", ".github", ".circleci", ".devcontainer"}
            if any(p.startswith(".") and p not in allowed_hidden for p in parts):
                continue
            if any(p in ["node_modules", "__pycache__", "venv", ".venv", "dist", "build"] for p in parts):
                continue
            results.append(str(f))
    
    return sorted(set(results))


def grep_search(term: str, path: str = ".", file_type: str = "") -> tuple[list[dict], int]:
    """
    Search for term using grep. Returns matches and count.
    This is the parameterized determinism pattern:
    - Agent provides subjective term
    - Script returns deterministic results
    """
    cmd = ["grep", "-rn", "--color=never"]

    for d in [".git", "node_modules", "__pycache__", "venv", ".venv", "dist", "build", "vendor"]:
        cmd.extend(["--exclude-dir", d])
    if file_type:
        cmd.extend(["--include", f"*.{file_type}"])
    cmd.extend([term, path])
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        lines = result.stdout.strip().split("\n") if result.stdout.strip() else []
    except (subprocess.TimeoutExpired, FileNotFoundError):
        lines = []
    
    matches = []
    for line in lines[:100]:  # Limit results
        if ":" in line:
            parts = line.split(":", 2)
            if len(parts) >= 3:
                matches.append({
                    "file": parts[0],
                    "line": parts[1],
                    "content": parts[2].strip(),
                })
    
    return matches, len(lines)


def save_evidence(term: str, matches: list[dict], count: int) -> str:
    """Save evidence snapshot to .doctor/evidence/."""
    ensure_doctor_dir()
    
    content = f"# Evidence: {term}\n\n"
    content += f"**Date:** {to_rfc3339(now_utc())}\n"
    content += f"**Matches:** {count}\n\n"
    content += "## Results\n\n"
    
    for m in matches[:50]:
        content += f"- `{m['file']}:{m['line']}` — {m['content'][:80]}\n"
    
    if count > 50:
        content += f"\n*...and {count - 50} more matches*\n"
    
    file_hash = hash_content(content)
    filename = f"{file_hash}.md"
    filepath = EVIDENCE_DIR / filename
    filepath.write_text(content, encoding="utf-8")
    
    # Update session
    session = load_session()
    if session:
        if filename not in session.get("evidence_files", []):
            session.setdefault("evidence_files", []).append(filename)
            save_session(session)
    
    return filename


def generate_treatment(diagnosis: dict[str, Any], options: list[dict[str, Any]], recommended: str = "") -> str:
    """Generate treatment plan markdown from schema."""
    normalized_options: list[dict[str, Any]] = []
    for opt in options:
        risk = opt.get("risk", "medium")
        if risk not in RISK_LEVELS:
            risk = "medium"

        effort = opt.get("effort", "medium")
        if effort not in EFFORT_LEVELS:
            effort = "medium"

        normalized_options.append(
            {
                "name": opt.get("name", "Unnamed"),
                "description": opt.get("description", ""),
                "risk": risk,
                "effort": effort,
                "reversible": bool(opt.get("reversible", True)),
                "steps": opt.get("steps", []) or [],
            }
        )

    treatment_obj = {
        "diagnosis_summary": diagnosis.get("summary", "N/A"),
        "confidence": int(diagnosis.get("confidence", 0) or 0),
        "root_cause": diagnosis.get("root_cause", "N/A"),
        "options": normalized_options,
        "recommended": recommended,
        "caveats": [],
        "follow_up": [],
    }

    generated_at = to_rfc3339(now_utc())

    content = "---\n"
    content += yaml.safe_dump(treatment_obj, sort_keys=False)
    content += "---\n\n"

    content += "# Treatment Plan\n\n"
    content += f"**Generated:** {generated_at}\n\n"
    content += "---\n\n"

    content += "## Diagnosis\n\n"
    content += f"**Summary:** {treatment_obj['diagnosis_summary']}\n"
    content += f"**Confidence:** {treatment_obj['confidence']}%\n"
    content += f"**Root Cause:** {treatment_obj['root_cause']}\n\n"

    factors = diagnosis.get("contributing_factors", [])
    if factors:
        content += "**Contributing Factors:**\n"
        for f in factors:
            content += f"- {f}\n"
        content += "\n"

    content += "---\n\n"
    content += "## Treatment Options\n\n"

    for i, opt in enumerate(treatment_obj["options"], 1):
        rec_marker = " ⭐ *Recommended*" if opt.get("name") == treatment_obj.get("recommended") else ""
        content += f"### Option {i}: {opt.get('name', 'Unnamed')}{rec_marker}\n\n"
        content += f"{opt.get('description', '')}\n\n"
        content += f"- **Risk:** {opt.get('risk', 'unknown')}\n"
        content += f"- **Effort:** {opt.get('effort', 'unknown')}\n"
        content += f"- **Reversible:** {'Yes' if opt.get('reversible', True) else 'No'}\n\n"

        steps = opt.get("steps", [])
        if steps:
            content += "**Steps:**\n\n"
            for j, step in enumerate(steps, 1):
                content += f"{j}. {step}\n"
            content += "\n"

    content += "---\n\n"
    content += "## Caveats\n\n"
    content += "*None specified*\n\n"
    content += "## Follow-up\n\n"
    content += "*None specified*\n"
    
    TREATMENT_FILE.write_text(content, encoding="utf-8")
    
    # Update session
    session = load_session()
    if session:
        session["status"] = "treated"
        save_session(session)
    
    return str(TREATMENT_FILE)


def clean_doctor() -> bool:
    """Remove .doctor directory."""
    if not DOCTOR_DIR.exists():
        return False
    import shutil
    shutil.rmtree(DOCTOR_DIR)
    return True


def get_status() -> dict[str, Any]:
    """Get comprehensive status of current session."""
    if not session_exists():
        return {"exists": False}
    
    session = load_session()
    if session is None:
        return {"exists": False}
    
    evidence_count = len(list(EVIDENCE_DIR.glob("*.md"))) if EVIDENCE_DIR.exists() else 0
    
    return {
        "exists": True,
        "status": session.get("status", "investigating"),
        "patient": session.get("patient", "unknown"),
        "symptoms": len(session.get("symptoms", [])),
        "hypotheses": len(session.get("hypotheses", [])),
        "evidence_files": evidence_count,
        "diagnosed": session.get("diagnosis") is not None,
        "treated": TREATMENT_FILE.exists(),
    }
