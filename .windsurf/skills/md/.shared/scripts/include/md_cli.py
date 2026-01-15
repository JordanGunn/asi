#!/usr/bin/env python3
"""MD CLI - Markdown operations with deterministic tooling."""

import argparse
import json
import subprocess
import sys
import shutil
from pathlib import Path


def find_script(name: str) -> Path | None:
    """Find a script in the md-split/scripts directory."""
    base = Path(__file__).parent.parent.parent.parent
    split_scripts = base / "md-split" / "scripts"

    exts = [".sh", ".ps1"]
    if sys.platform.startswith("win"):
        exts = [".ps1", ".sh"]

    for ext in exts:
        script = split_scripts / f"{name}{ext}"
        if script.exists():
            return script
    return None


def run_script(script: Path, args_sh: list[str], args_ps1: list[str]) -> int:
    suffix = script.suffix.lower()

    if suffix == ".sh":
        bash = shutil.which("bash")
        if bash is None:
            print("error: bash not found", file=sys.stderr)
            return 1
        result = subprocess.run([bash, str(script), *args_sh])
        return result.returncode

    if suffix == ".ps1":
        pwsh = shutil.which("pwsh") or shutil.which("powershell")
        if pwsh is None:
            print("error: pwsh/powershell not found", file=sys.stderr)
            return 1

        result = subprocess.run(
            [
                pwsh,
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                str(script),
                *args_ps1,
            ]
        )
        return result.returncode

    print(f"error: unsupported script type '{script.suffix}'", file=sys.stderr)
    return 1


def cmd_help(args: argparse.Namespace) -> int:
    """Show help."""
    print("""md - Markdown operations CLI

Commands:
  help                     Show this help message
  validate                 Verify the skill is runnable
  split <file> [options]   Split markdown by H2 headings
  merge <dir> [options]    Merge chunks back together
  lint <file|dir>          Check markdown for issues
  index <dir>              Generate index file
  clean <dir>              Remove generated files

Split Options:
  --out <dir>              Output directory
  --force                  Overwrite existing files
  --dry-run                Show what would be done

Merge Options:
  --out <file>             Output file path
  --force                  Overwrite existing file

Lint Options:
  --fix                    Auto-fix issues where possible

Usage:
  md split large.md --out chunks/
  md lint chunks/
  md merge chunks/ --out merged.md
  md clean chunks/

Key Pattern:
  Split/merge/lint are deterministic operations.
  Use md-review skill for subjective quality assessment.
""")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Validate CLI is runnable."""
    errors = []
    
    # Check for split script
    split_script = find_script("split")
    if split_script is None:
        errors.append("missing script: md-split/scripts/split.sh")
    
    # Check for index script
    index_script = find_script("index")
    if index_script is None:
        errors.append("missing script: md-split/scripts/index.sh")

    if split_script is not None:
        if split_script.suffix == ".sh" and shutil.which("bash") is None:
            errors.append("missing command: bash")
        if split_script.suffix == ".ps1" and (shutil.which("pwsh") is None and shutil.which("powershell") is None):
            errors.append("missing command: pwsh/powershell")

    if index_script is not None:
        if index_script.suffix == ".sh" and shutil.which("bash") is None:
            errors.append("missing command: bash")
        if index_script.suffix == ".ps1" and (shutil.which("pwsh") is None and shutil.which("powershell") is None):
            errors.append("missing command: pwsh/powershell")
    
    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1
    
    print("ok: md CLI is runnable")
    return 0


def cmd_split(args: argparse.Namespace) -> int:
    """Split markdown by H2 headings."""
    script = find_script("split")
    if script is None:
        print("error: split script not found", file=sys.stderr)
        return 1

    args_sh: list[str] = ["--in", args.file]
    args_ps1: list[str] = ["-in", args.file]

    if args.out:
        args_sh.extend(["--out", args.out])
        args_ps1.extend(["-out", args.out])
    if args.force:
        args_sh.append("--force")
        args_ps1.append("-force")
    if args.dry_run:
        args_sh.append("--dry-run")
        args_ps1.append("-dryRun")

    return run_script(script, args_sh=args_sh, args_ps1=args_ps1)


def cmd_merge(args: argparse.Namespace) -> int:
    """Merge chunks back together."""
    chunk_dir = Path(args.dir)
    if not chunk_dir.exists():
        print(f"error: directory '{args.dir}' not found", file=sys.stderr)
        return 1
    
    # Find manifest
    manifest_path = chunk_dir / ".SPLIT.json"
    if not manifest_path.exists():
        print("warning: no .SPLIT.json manifest found, using file order", file=sys.stderr)
        chunks = sorted(chunk_dir.glob("[0-9][0-9]_*.md"))
    else:
        with open(manifest_path) as f:
            manifest = json.load(f)
        chunks = [chunk_dir / entry["filename"] for entry in manifest.get("files", [])]
    
    if not chunks:
        print("error: no chunks found to merge", file=sys.stderr)
        return 1
    
    # Determine output
    out_file = args.out or (chunk_dir.parent / f"{chunk_dir.name}_merged.md")
    out_path = Path(out_file)
    
    if out_path.exists() and not args.force:
        print(f"error: '{out_path}' already exists. Use --force to overwrite.", file=sys.stderr)
        return 1
    
    if args.dry_run:
        print(f"would merge {len(chunks)} chunks to {out_path}")
        for c in chunks:
            print(f"  - {c.name}")
        return 0
    
    # Merge
    content = []
    for chunk in chunks:
        if not chunk.exists():
            print(f"warning: chunk '{chunk}' not found, skipping", file=sys.stderr)
            continue
        text = chunk.read_text(encoding="utf-8")
        # Convert H1 back to H2 (reverse of split promotion)
        lines = text.split("\n")
        converted = []
        for line in lines:
            if line.startswith("# ") and not line.startswith("## "):
                converted.append("## " + line[2:])
            else:
                converted.append(line)
        content.append("\n".join(converted))
    
    merged = "\n\n".join(content)
    out_path.write_text(merged, encoding="utf-8")
    
    print(f"merged {len(chunks)} chunks to {out_path}")
    return 0


def cmd_lint(args: argparse.Namespace) -> int:
    """Check markdown for issues."""
    target = Path(args.target)
    if not target.exists():
        print(f"error: '{args.target}' not found", file=sys.stderr)
        return 1
    
    # Find markdown files
    if target.is_dir():
        files = list(target.glob("*.md"))
    else:
        files = [target]
    
    if not files:
        print("no markdown files found")
        return 0
    
    issues: list[tuple[Path, int, str]] = []

    def fix_content(text: str) -> str:
        # Deterministic, safe fixes only.
        lines = text.split("\n")

        # 1) Strip trailing whitespace.
        lines = [ln.rstrip() for ln in lines]

        # 2) Collapse runs of 3+ blank lines to 2 blank lines.
        fixed: list[str] = []
        blank_run = 0
        for ln in lines:
            if ln.strip() == "":
                blank_run += 1
                if blank_run <= 2:
                    fixed.append(ln)
                continue
            blank_run = 0
            fixed.append(ln)

        return "\n".join(fixed)
    for f in files:
        content = f.read_text(encoding="utf-8")
        if args.fix:
            fixed = fix_content(content)
            if fixed != content:
                f.write_text(fixed, encoding="utf-8")
                content = fixed

        lines = content.split("\n")
        
        # Simple lint checks
        for i, line in enumerate(lines, 1):
            # Trailing whitespace
            if line.rstrip() != line:
                issues.append((f, i, "trailing whitespace"))
            
            # Multiple consecutive blank lines
            if i > 1 and lines[i-1].strip() == "" and line.strip() == "":
                if i > 2 and lines[i-2].strip() == "":
                    issues.append((f, i, "multiple consecutive blank lines"))
            
            # Heading without space after # (lint only; no auto-fix)
            if line.startswith("#") and not line.startswith("# ") and line != "#":
                if not line.startswith("## ") and not line.startswith("### "):
                    issues.append((f, i, "heading missing space after #"))
    
    if issues:
        print(f"found {len(issues)} issues:")
        for filepath, line, msg in issues[:20]:
            print(f"  {filepath.name}:{line} — {msg}")
        if len(issues) > 20:
            print(f"  ... and {len(issues) - 20} more")
        return 1
    
    print(f"lint passed: {len(files)} files checked")
    return 0


def cmd_index(args: argparse.Namespace) -> int:
    """Generate index file."""
    script = find_script("index")
    if script is None:
        print("error: index script not found", file=sys.stderr)
        return 1

    # index.sh expects flags; index.ps1 expects -dir.
    args_sh: list[str] = ["--dir", args.dir]
    args_ps1: list[str] = ["-dir", args.dir]
    return run_script(script, args_sh=args_sh, args_ps1=args_ps1)


def cmd_clean(args: argparse.Namespace) -> int:
    """Remove generated files."""
    target = Path(args.dir)
    if not target.exists():
        print(f"error: '{args.dir}' not found", file=sys.stderr)
        return 1
    
    # Files to clean
    patterns = ["[0-9][0-9]_*.md", ".SPLIT.json", ".INDEX.md"]
    removed = []
    
    if args.dry_run:
        for pattern in patterns:
            for f in target.glob(pattern):
                print(f"would remove: {f}")
                removed.append(f)
        print(f"would remove {len(removed)} files")
        return 0
    
    for pattern in patterns:
        for f in target.glob(pattern):
            f.unlink()
            removed.append(f)
    
    print(f"removed {len(removed)} files")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="md", description="Markdown operations")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("help", help="Show help")
    subparsers.add_parser("validate", help="Verify runnable")
    
    p_split = subparsers.add_parser("split", help="Split by H2")
    p_split.add_argument("file", help="Markdown file to split")
    p_split.add_argument("--out", help="Output directory")
    p_split.add_argument("--force", action="store_true", help="Overwrite existing")
    p_split.add_argument("--dry-run", action="store_true", help="Show what would be done")
    
    p_merge = subparsers.add_parser("merge", help="Merge chunks")
    p_merge.add_argument("dir", help="Directory with chunks")
    p_merge.add_argument("--out", help="Output file")
    p_merge.add_argument("--force", action="store_true", help="Overwrite existing")
    p_merge.add_argument("--dry-run", action="store_true", help="Show what would be done")
    
    p_lint = subparsers.add_parser("lint", help="Check markdown")
    p_lint.add_argument("target", help="File or directory to lint")
    p_lint.add_argument("--fix", action="store_true", help="Auto-fix issues")
    
    p_index = subparsers.add_parser("index", help="Generate index")
    p_index.add_argument("dir", help="Directory to index")
    
    p_clean = subparsers.add_parser("clean", help="Remove generated files")
    p_clean.add_argument("dir", help="Directory to clean")
    p_clean.add_argument("--dry-run", action="store_true", help="Show what would be removed")
    
    args = parser.parse_args()
    
    commands = {
        "help": cmd_help,
        "validate": cmd_validate,
        "split": cmd_split,
        "merge": cmd_merge,
        "lint": cmd_lint,
        "index": cmd_index,
        "clean": cmd_clean,
    }
    
    cmd = args.command or "help"
    if cmd not in commands:
        print(f"error: unknown command '{cmd}'", file=sys.stderr)
        return 1
    
    return commands[cmd](args)


if __name__ == "__main__":
    sys.exit(main())
