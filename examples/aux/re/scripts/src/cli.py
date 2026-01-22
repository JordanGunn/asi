#!/usr/bin/env python3
"""aux/re CLI - Agent-assisted pattern matching (deterministic regex execution)

All execution is deterministic. The agent selects patterns; this script executes.
"""

import argparse
import hashlib
import json
import re
import signal
import sys
from pathlib import Path


class TimeoutError(Exception):
    pass


def _timeout_handler(signum, frame):
    raise TimeoutError("Pattern matching timed out")


def _compute_query_id(param_block: dict) -> str:
    """Compute stable query_id from normalized parameters."""
    keys_for_hash = ["pattern", "flags"]
    hashable = {k: param_block.get(k) for k in keys_for_hash if k in param_block}
    normalized = json.dumps(hashable, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    h = hashlib.sha256(normalized.encode("utf-8")).hexdigest()
    return f"sha256:{h}"


def _emit_jsonl(obj: dict) -> None:
    """Emit a single JSONL record."""
    print(json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False))


def _compile_pattern(pattern: str, ignore_case: bool, multiline: bool, dotall: bool) -> re.Pattern:
    """Compile regex pattern with flags."""
    flags = 0
    if ignore_case:
        flags |= re.IGNORECASE
    if multiline:
        flags |= re.MULTILINE
    if dotall:
        flags |= re.DOTALL

    return re.compile(pattern, flags)


def cmd_run(args: argparse.Namespace) -> int:
    """Execute the regex match."""
    pattern_str: str = args.pattern
    input_text: str | None = args.input
    input_file: str | None = args.file
    ignore_case: bool = args.ignore_case
    multiline: bool = args.multiline
    dotall: bool = args.dotall
    max_matches: int = args.max_matches
    timeout: int = args.timeout
    output_format: str = args.format

    if not pattern_str:
        print("error: --pattern is required", file=sys.stderr)
        return 1

    # Get input text
    if input_text:
        text = input_text
    elif input_file:
        p = Path(input_file)
        if not p.exists():
            print(f"error: input file not found: {input_file}", file=sys.stderr)
            return 1
        text = p.read_text(encoding="utf-8")
    else:
        # Read from stdin
        text = sys.stdin.read()

    if not text:
        print("error: no input text provided", file=sys.stderr)
        return 1

    # Compile pattern
    try:
        pattern = _compile_pattern(pattern_str, ignore_case, multiline, dotall)
    except re.error as e:
        print(f"error: invalid regex pattern: {e}", file=sys.stderr)
        return 1

    # Build param block for reproducibility
    param_block = {
        "pattern": pattern_str,
        "flags": {
            "ignore_case": ignore_case,
            "multiline": multiline,
            "dotall": dotall,
        },
        "max_matches": max_matches,
        "timeout": timeout,
        "format": output_format,
        "input_length": len(text),
    }
    param_block["query_id"] = _compute_query_id(param_block)

    # Detect output format
    is_tty = sys.stdout.isatty()
    effective_format = output_format if output_format != "auto" else ("human" if is_tty else "jsonl")

    # Emit param block
    if effective_format == "jsonl":
        _emit_jsonl({"kind": "pattern_block", "pattern_block": param_block})
    else:
        print(f"# query_id: {param_block['query_id']}")
        print(f"# pattern: {pattern_str}")
        print(f"# flags: ignore_case={ignore_case}, multiline={multiline}, dotall={dotall}")
        print(f"# input_length: {len(text)}")
        print()

    # Set up timeout (Unix only)
    if hasattr(signal, 'SIGALRM'):
        signal.signal(signal.SIGALRM, _timeout_handler)
        signal.alarm(timeout)

    # Find matches
    matches = []
    truncated = False
    try:
        for i, match in enumerate(pattern.finditer(text)):
            if i >= max_matches:
                truncated = True
                break

            match_data = {
                "value": match.group(0),
                "start": match.start(),
                "end": match.end(),
                "groups": {},
            }

            # Capture groups
            for j, group in enumerate(match.groups(), 1):
                if group is not None:
                    match_data["groups"][str(j)] = group

            # Named groups
            for name, value in match.groupdict().items():
                if value is not None:
                    match_data["groups"][name] = value

            matches.append(match_data)

    except TimeoutError:
        if effective_format == "jsonl":
            _emit_jsonl({"kind": "error", "error": "timeout", "message": f"Pattern matching timed out after {timeout}s"})
        else:
            print(f"error: pattern matching timed out after {timeout}s", file=sys.stderr)
        return 1
    finally:
        if hasattr(signal, 'SIGALRM'):
            signal.alarm(0)

    # Emit results
    total_matches = len(matches)

    if effective_format == "jsonl":
        _emit_jsonl({
            "kind": "summary",
            "matches": total_matches,
            "truncated": truncated,
        })
        for m in matches:
            _emit_jsonl({"kind": "match", **m})
    else:
        print(f"matches: {total_matches}")
        if truncated:
            print("(truncated)")
        print()
        for m in matches:
            if m["groups"]:
                groups_str = " | groups: " + ", ".join(f"{k}={v}" for k, v in m["groups"].items())
            else:
                groups_str = ""
            print(f"[{m['start']}:{m['end']}] {m['value']}{groups_str}")

    return 0


def cmd_validate(_: argparse.Namespace) -> int:
    """Verify the skill is runnable."""
    # Python's re module is always available
    print("ok: re CLI is runnable")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="aux/re - Agent-assisted pattern matching")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # validate
    subparsers.add_parser("validate", help="Verify the skill is runnable")

    # run
    run_parser = subparsers.add_parser("run", help="Execute a deterministic regex match")
    run_parser.add_argument("--pattern", required=True, help="Regex pattern")
    run_parser.add_argument("--input", help="Input text to match against")
    run_parser.add_argument("--file", help="Read input from file")
    run_parser.add_argument("--ignore-case", action="store_true")
    run_parser.add_argument("--multiline", action="store_true")
    run_parser.add_argument("--dotall", action="store_true")
    run_parser.add_argument("--max-matches", type=int, default=1000)
    run_parser.add_argument("--timeout", type=int, default=30)
    run_parser.add_argument("--format", choices=["auto", "human", "jsonl"], default="auto")
    run_parser.add_argument("--stdin", action="store_true", help="Read plan JSON from stdin")

    args = parser.parse_args()

    if args.command == "validate":
        return cmd_validate(args)
    elif args.command == "run":
        return cmd_run(args)

    return 1


if __name__ == "__main__":
    sys.exit(main())
