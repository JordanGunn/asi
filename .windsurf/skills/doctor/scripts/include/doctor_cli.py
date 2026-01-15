#!/usr/bin/env python3
"""Doctor CLI - Diagnostic skill with parameterized subjectivity."""

import argparse
import sys
from pathlib import Path

from doctor_parse import (
    DOCTOR_DIR,
    add_hypothesis,
    add_symptom,
    clean_doctor,
    generate_treatment,
    get_status,
    grep_search,
    init_session,
    load_session,
    save_evidence,
    session_exists,
    set_diagnosis,
    surface_scan,
)


def cmd_status(args: argparse.Namespace) -> int:
    """Show current session status."""
    status = get_status()
    
    if not status.get("exists"):
        print("no active session")
        print("run 'doctor init' to start")
        return 0
    
    print(f"patient: {status.get('patient', 'unknown')}")
    print(f"status: {status.get('status', 'investigating')}")
    print(f"symptoms: {status.get('symptoms', 0)}")
    print(f"hypotheses: {status.get('hypotheses', 0)}")
    print(f"evidence files: {status.get('evidence_files', 0)}")
    print(f"diagnosed: {'yes' if status.get('diagnosed') else 'no'}")
    print(f"treated: {'yes' if status.get('treated') else 'no'}")
    
    return 0


def cmd_init(args: argparse.Namespace) -> int:
    """Initialize a new diagnosis session."""
    if session_exists() and not args.force:
        print("error: session already exists", file=sys.stderr)
        print("use --force to overwrite", file=sys.stderr)
        return 1
    
    if session_exists() and args.force:
        clean_doctor()
    
    patient = args.patient or ""
    session = init_session(patient)
    print(f"created: {DOCTOR_DIR}")
    print(f"patient: {session['patient']}")
    print(f"status: {session['status']}")
    return 0


def cmd_surface(args: argparse.Namespace) -> int:
    """Scan for relevant files (deterministic globbing)."""
    patterns = args.patterns if args.patterns else None
    path = args.path or "."
    
    files = surface_scan(patterns, path)
    
    if not files:
        print("no files found")
        return 0
    
    print(f"found {len(files)} files:")
    for f in files[:50]:
        print(f"  {f}")
    
    if len(files) > 50:
        print(f"  ... and {len(files) - 50} more")
    
    return 0


def cmd_grep(args: argparse.Namespace) -> int:
    """Search for term (parameterized determinism)."""
    term = args.term
    path = args.path or "."
    file_type = args.type or ""
    
    print(f"searching: '{term}'")
    matches, count = grep_search(term, path, file_type)
    
    if not matches:
        print("no matches found")
        return 0
    
    print(f"found {count} matches:")
    for m in matches[:20]:
        print(f"  {m['file']}:{m['line']} — {m['content'][:60]}")
    
    if count > 20:
        print(f"  ... and {count - 20} more")
    
    # Save evidence
    if args.save:
        filename = save_evidence(term, matches, count)
        print(f"\nevidence saved: .doctor/evidence/{filename}")
    
    return 0


def cmd_symptom(args: argparse.Namespace) -> int:
    """Add a symptom to the session."""
    description = args.description
    category = args.category or "unknown"
    evidence = args.evidence or ""
    
    session = add_symptom(description, category, evidence)
    print(f"added symptom: {description[:50]}")
    print(f"total symptoms: {len(session.get('symptoms', []))}")
    return 0


def cmd_hypothesize(args: argparse.Namespace) -> int:
    """Add a hypothesis with confidence."""
    description = args.description
    confidence = args.confidence
    falsifiable = args.falsifiable or ""
    
    session = add_hypothesis(description, confidence, falsifiable)
    print(f"added hypothesis: {description[:50]}")
    print(f"confidence: {confidence}%")
    print(f"total hypotheses: {len(session.get('hypotheses', []))}")
    return 0


def cmd_diagnose(args: argparse.Namespace) -> int:
    """Set the diagnosis."""
    summary = args.summary
    confidence = args.confidence
    root_cause = args.cause or ""
    factors = args.factors or []
    
    session = set_diagnosis(summary, confidence, root_cause, factors)
    print(f"diagnosis set: {summary[:50]}")
    print(f"confidence: {confidence}%")
    print(f"status: {session.get('status')}")
    return 0


def cmd_treat(args: argparse.Namespace) -> int:
    """Generate treatment plan from diagnosis."""
    session = load_session()
    if session is None or session.get("diagnosis") is None:
        print("error: no diagnosis set", file=sys.stderr)
        print("run 'doctor diagnose' first", file=sys.stderr)
        return 1
    
    diagnosis = session["diagnosis"]
    
    # Build options from args or prompt
    options = []
    if args.option:
        for opt_str in args.option:
            parts = opt_str.split(":", 2)
            name = parts[0]
            desc = parts[1] if len(parts) > 1 else ""
            risk = parts[2] if len(parts) > 2 else "medium"
            options.append({
                "name": name,
                "description": desc,
                "risk": risk,
                "effort": "medium",
                "reversible": True,
                "steps": [],
            })
    
    if not options:
        # Default option
        options.append({
            "name": "Default Fix",
            "description": "Address the root cause directly",
            "risk": "medium",
            "effort": "medium",
            "reversible": True,
            "steps": ["Implement fix based on diagnosis"],
        })
    
    recommended = args.recommend or options[0]["name"]
    path = generate_treatment(diagnosis, options, recommended)
    print(f"treatment plan generated: {path}")
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    """Remove .doctor directory."""
    if args.dry_run:
        if session_exists():
            print(f"would remove: {DOCTOR_DIR}")
        else:
            print("no session to clean")
        return 0
    
    if clean_doctor():
        print(f"removed: {DOCTOR_DIR}")
    else:
        print("no session to clean")
    
    return 0


def cmd_help(args: argparse.Namespace) -> int:
    """Show help."""
    print("""doctor - Diagnostic skill with parameterized subjectivity

Commands:
  help                 Show this help message
  validate             Verify the skill is runnable
  status               Show current session status
  init [--patient X]   Start new diagnosis session
  surface              Scan for relevant files (globbing)
  grep <term>          Search for term (parameterized determinism)
  symptom <desc>       Add a symptom to the session
  intake <desc>        Alias for symptom
  hypothesize <desc>   Add a hypothesis with confidence
  diagnose <summary>   Set the diagnosis
  treat                Generate treatment plan from schema
  clean                Remove .doctor/ artifacts

Usage:
  doctor init --patient "my-service"
  doctor surface --patterns "*.py" "*.yaml"
  doctor grep "connection timeout" --save
  doctor grep "database" --type py --path src/
  doctor symptom "API returns 500" --category error
  doctor intake "API returns 500" --category error
  doctor hypothesize "Race condition in cache" --confidence 70
  doctor diagnose "Cache invalidation bug" --confidence 85 --cause "Stale TTL"
  doctor treat --option "Fix TTL:Update cache TTL logic:low"
  doctor clean

Artifacts are stored in .doctor/

Key Pattern:
  Agent provides subjective input (terms, hypotheses, confidence)
  Scripts return deterministic results (grep matches, file lists)
  Session state enables idempotent re-runs until confident diagnosis
""")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Validate CLI is runnable."""
    import shutil
    errors = []

    if shutil.which("uv") is None:
        errors.append("missing command: uv")

    if shutil.which("grep") is None:
        errors.append("missing command: grep")

    include_dir = Path(__file__).resolve().parent
    if not (include_dir / "pyproject.toml").is_file():
        errors.append(f"missing {include_dir / 'pyproject.toml'}")
    
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    
    print("ok: doctor skill is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="doctor", description="Diagnostic skill")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("help", help="Show help")
    subparsers.add_parser("validate", help="Verify runnable")
    subparsers.add_parser("status", help="Show session status")
    
    p_init = subparsers.add_parser("init", help="Start session")
    p_init.add_argument("--patient", help="Patient name")
    p_init.add_argument("--force", action="store_true", help="Overwrite existing")
    
    p_surface = subparsers.add_parser("surface", help="Scan for files")
    p_surface.add_argument("--patterns", nargs="*", help="Glob patterns")
    p_surface.add_argument("--path", help="Search path")
    
    p_grep = subparsers.add_parser("grep", help="Search for term")
    p_grep.add_argument("term", help="Search term")
    p_grep.add_argument("--path", help="Search path")
    p_grep.add_argument("--type", help="File extension")
    p_grep.add_argument("--save", action="store_true", help="Save evidence")
    
    p_symptom = subparsers.add_parser("symptom", help="Add symptom")
    p_symptom.add_argument("description", help="Symptom description")
    p_symptom.add_argument("--category", help="Category")
    p_symptom.add_argument("--evidence", help="Evidence string")

    p_intake = subparsers.add_parser("intake", help="Alias for symptom")
    p_intake.add_argument("description", help="Symptom description")
    p_intake.add_argument("--category", help="Category")
    p_intake.add_argument("--evidence", help="Evidence string")
    
    p_hypo = subparsers.add_parser("hypothesize", help="Add hypothesis")
    p_hypo.add_argument("description", help="Hypothesis")
    p_hypo.add_argument("--confidence", type=int, default=50, help="Confidence %")
    p_hypo.add_argument("--falsifiable", help="How to falsify")
    
    p_diag = subparsers.add_parser("diagnose", help="Set diagnosis")
    p_diag.add_argument("summary", help="Diagnosis summary")
    p_diag.add_argument("--confidence", type=int, default=80, help="Confidence %")
    p_diag.add_argument("--cause", help="Root cause")
    p_diag.add_argument("--factors", nargs="*", help="Contributing factors")
    
    p_treat = subparsers.add_parser("treat", help="Generate treatment")
    p_treat.add_argument("--option", action="append", help="Option (name:desc:risk); repeatable")
    p_treat.add_argument("--recommend", help="Recommended option name")
    
    p_clean = subparsers.add_parser("clean", help="Remove artifacts")
    p_clean.add_argument("--dry-run", action="store_true", help="Show what would be removed")
    
    args = parser.parse_args()
    
    commands = {
        "help": cmd_help,
        "validate": cmd_validate,
        "status": cmd_status,
        "init": cmd_init,
        "surface": cmd_surface,
        "grep": cmd_grep,
        "symptom": cmd_symptom,
        "intake": cmd_symptom,
        "hypothesize": cmd_hypothesize,
        "diagnose": cmd_diagnose,
        "treat": cmd_treat,
        "clean": cmd_clean,
    }
    
    cmd = args.command or "help"
    if cmd not in commands:
        print(f"error: unknown command '{cmd}'", file=sys.stderr)
        return 1
    
    return commands[cmd](args)


if __name__ == "__main__":
    sys.exit(main())
