#!/usr/bin/env python3
"""Changelog CLI - Deterministic changelog operations."""

import argparse
import shutil
import sys
from pathlib import Path

from changelog_parse import (
    CANONICAL_CATEGORIES,
    add_entry_to_changelog,
    get_commits_since_tag,
    get_latest_tag,
    get_remote_url,
    get_repo_root,
    has_duplicate_entry,
    locate_changelog,
    parse_changelog,
    release_changelog,
    today_iso,
)


def cmd_help(args: argparse.Namespace) -> int:
    """Show help."""
    print("""changelog - Changelog operations CLI

Commands:
  help                      Show this help message
  validate                  Verify the skill is runnable
  locate                    Find changelog path
  init [--force]            Create changelog from template
  verify [path]             Check changelog format
  add <category> <entry>    Add entry to [Unreleased]
  release <version>         Cut a release from [Unreleased]
  suggest                   Show commits since last tag
  clean                     (no-op, changelog not generated)

Categories:
  Added, Changed, Deprecated, Removed, Fixed, Security

Usage:
  changelog locate
  changelog init
  changelog verify
  changelog add Fixed "Resolved issue with login (#123)"
  changelog release 1.2.0
  changelog suggest

Key Pattern:
  All operations are deterministic text surgery.
  Agent handles entry wording; CLI handles structure.
""")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Validate CLI is runnable."""
    errors = []
    
    if shutil.which("git") is None:
        errors.append("missing command: git")
    
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    
    print("ok: changelog CLI is runnable")
    return 0


def cmd_locate(args: argparse.Namespace) -> int:
    """Find changelog path."""
    path = locate_changelog()
    if path:
        print(f"found: {path}")
        return 0
    else:
        print("not found")
        print("run 'changelog init' to create one")
        return 1


def cmd_init(args: argparse.Namespace) -> int:
    """Create changelog from template."""
    root = get_repo_root()
    if root is None:
        root = Path.cwd()
    
    target = root / "CHANGELOG.md"
    
    if target.exists() and not args.force:
        print(f"error: {target} already exists", file=sys.stderr)
        print("use --force to overwrite", file=sys.stderr)
        return 1
    
    # Find template
    script_dir = Path(__file__).parent.parent.parent
    template = script_dir / "assets" / "templates" / "CHANGELOG.template.md"
    
    if not template.exists():
        print(f"error: template not found at {template}", file=sys.stderr)
        return 1
    
    content = template.read_text(encoding="utf-8")
    
    # Substitute remote URL if available
    remote_url = get_remote_url()
    if remote_url:
        content = content.replace(
            "https://github.com/OWNER/REPO",
            remote_url
        )
    
    target.write_text(content, encoding="utf-8")
    print(f"created: {target}")
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    """Check changelog format."""
    if args.path:
        path = Path(args.path)
    else:
        path = locate_changelog()
    
    if path is None or not path.exists():
        print("error: changelog not found", file=sys.stderr)
        return 1
    
    data = parse_changelog(path)
    issues = []
    
    if not data["has_header"]:
        issues.append("missing '# Changelog' header")
    
    if not data["has_kac_reference"]:
        issues.append("missing Keep a Changelog reference")
    
    if not data["has_unreleased"]:
        issues.append("missing [Unreleased] section")
    
    if not data["versions_descending"]:
        issues.append("versions not in descending order")
    
    # Check for issues from parse
    issues.extend(data.get("issues", []))
    
    if issues:
        print(f"found {len(issues)} issues:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    
    print(f"ok: {path}")
    print(f"  versions: {len(data['versions'])}")
    print(f"  unreleased entries: {sum(len(v) for v in data['unreleased_entries'].values())}")
    return 0


def cmd_add(args: argparse.Namespace) -> int:
    """Add entry to [Unreleased]."""
    category = args.category.capitalize()
    if category not in CANONICAL_CATEGORIES:
        print(f"error: invalid category '{category}'", file=sys.stderr)
        print(f"valid categories: {', '.join(CANONICAL_CATEGORIES)}", file=sys.stderr)
        return 1
    
    path = locate_changelog()
    if path is None:
        print("error: changelog not found", file=sys.stderr)
        print("run 'changelog init' first", file=sys.stderr)
        return 1
    
    entry = args.entry
    
    # Check for duplicates
    data = parse_changelog(path)
    if has_duplicate_entry(data, entry, category):
        print(f"warning: duplicate entry detected, skipping", file=sys.stderr)
        return 0
    
    if add_entry_to_changelog(path, category, entry):
        print(f"added to [{category}]: {entry}")
        return 0
    else:
        print(f"error: could not add entry (missing {category} section?)", file=sys.stderr)
        return 1


def cmd_release(args: argparse.Namespace) -> int:
    """Cut a release from [Unreleased]."""
    version = args.version
    date = args.date or today_iso()
    
    path = locate_changelog()
    if path is None:
        print("error: changelog not found", file=sys.stderr)
        return 1
    
    # Verify first
    data = parse_changelog(path)
    if not data["has_unreleased"]:
        print("error: no [Unreleased] section found", file=sys.stderr)
        return 1
    
    unreleased_count = sum(len(v) for v in data["unreleased_entries"].values())
    if unreleased_count == 0 and not args.force:
        print("warning: [Unreleased] section is empty", file=sys.stderr)
        print("use --force to release anyway", file=sys.stderr)
        return 1
    
    if release_changelog(path, version, date):
        print(f"released: [{version}] - {date}")
        print(f"  entries: {unreleased_count}")
        return 0
    else:
        print("error: release failed", file=sys.stderr)
        return 1


def cmd_suggest(args: argparse.Namespace) -> int:
    """Show commits since last tag."""
    tag = get_latest_tag()
    commits = get_commits_since_tag(tag)
    
    if tag:
        print(f"commits since {tag}:")
    else:
        print("recent commits (no tags found):")
    
    if not commits:
        print("  (none)")
        return 0
    
    for commit in commits[:20]:
        print(f"  - {commit}")
    
    if len(commits) > 20:
        print(f"  ... and {len(commits) - 20} more")
    
    print("\nUse 'changelog add <category> \"<entry>\"' to add entries.")
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    """Clean generated files (no-op for changelog)."""
    print("changelog does not generate artifacts to clean")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="changelog", description="Changelog operations")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("help", help="Show help")
    subparsers.add_parser("validate", help="Verify runnable")
    subparsers.add_parser("locate", help="Find changelog")
    
    p_init = subparsers.add_parser("init", help="Create changelog")
    p_init.add_argument("--force", action="store_true", help="Overwrite existing")
    
    p_verify = subparsers.add_parser("verify", help="Check format")
    p_verify.add_argument("path", nargs="?", help="Changelog path")
    
    p_add = subparsers.add_parser("add", help="Add entry")
    p_add.add_argument("category", help="Category (Added, Changed, etc.)")
    p_add.add_argument("entry", help="Entry text")
    
    p_release = subparsers.add_parser("release", help="Cut release")
    p_release.add_argument("version", help="Version number (e.g., 1.2.0)")
    p_release.add_argument("--date", help="Release date (default: today)")
    p_release.add_argument("--force", action="store_true", help="Release even if empty")
    
    subparsers.add_parser("suggest", help="Show commits since tag")
    subparsers.add_parser("clean", help="Clean generated files")
    
    args = parser.parse_args()
    
    commands = {
        "help": cmd_help,
        "validate": cmd_validate,
        "locate": cmd_locate,
        "init": cmd_init,
        "verify": cmd_verify,
        "add": cmd_add,
        "release": cmd_release,
        "suggest": cmd_suggest,
        "clean": cmd_clean,
    }
    
    cmd = args.command or "help"
    if cmd not in commands:
        print(f"error: unknown command '{cmd}'", file=sys.stderr)
        return 1
    
    return commands[cmd](args)


if __name__ == "__main__":
    sys.exit(main())
