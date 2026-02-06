from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from asi import __version__
from asi.commands import creator, doctor, onboard, skill


def _print_json_error(message: str, schema_cmd: str | None = None) -> None:
    payload = {"error": message}
    if schema_cmd:
        payload["schema_cmd"] = schema_cmd
    print(json.dumps(payload, indent=2))


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="asi",
        description="ASI - Agent Skill Interface CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--version",
        action="version",
        version=f"asi {__version__}",
    )

    subparsers = parser.add_subparsers(dest="command", metavar="<command>")

    # doctor
    doctor_parser = subparsers.add_parser("doctor", help="Verify dependencies")
    doctor_parser.set_defaults(func=cmd_doctor)

    # skill init
    skill_parser = subparsers.add_parser("skill", help="Skill utilities")
    skill_sub = skill_parser.add_subparsers(dest="skill_cmd", metavar="<subcommand>")
    init_parser = skill_sub.add_parser("init", help="Emit concatenated references")
    init_parser.add_argument("--skill-dir", required=True)
    init_parser.set_defaults(func=cmd_skill_init)

    # onboard
    onboard_parser = subparsers.add_parser("onboard", help="Onboard skill")
    onboard_parser.add_argument("--schema", action="store_true")
    onboard_sub = onboard_parser.add_subparsers(dest="onboard_cmd", metavar="<subcommand>")
    onboard_run = onboard_sub.add_parser("run", help="Run onboard via plan")
    onboard_run.add_argument("--stdin", action="store_true")
    onboard_run.set_defaults(func=cmd_onboard)
    onboard_parser.set_defaults(func=cmd_onboard)

    # creator
    creator_parser = subparsers.add_parser("creator", help="Creator skill")
    creator_parser.add_argument("--schema", action="store_true")
    creator_sub = creator_parser.add_subparsers(dest="creator_cmd", metavar="<subcommand>")
    creator_run = creator_sub.add_parser("run", help="Run creator via session goal")
    creator_run.add_argument("--stdin", action="store_true")
    creator_run.set_defaults(func=cmd_creator_run)
    creator_next = creator_sub.add_parser("next", help="Emit next questions")
    creator_next.set_defaults(func=cmd_creator_next)
    creator_suggest = creator_sub.add_parser("suggest", help="Validate suggestions")
    creator_suggest.add_argument("--schema", action="store_true")
    creator_suggest.add_argument("--stdin", action="store_true")
    creator_suggest.set_defaults(func=cmd_creator_suggest)
    creator_apply = creator_sub.add_parser("apply", help="Apply answers")
    creator_apply.add_argument("--schema", action="store_true")
    creator_apply.add_argument("--stdin", action="store_true")
    creator_apply.set_defaults(func=cmd_creator_apply)
    creator_migrate = creator_sub.add_parser("migrate", help="Migrate legacy artifacts")
    creator_migrate.add_argument("--from", dest="source", choices=["legacy"], required=True)
    creator_migrate.add_argument("--force", action="store_true")
    creator_migrate.set_defaults(func=cmd_creator_migrate)
    creator_parser.set_defaults(func=cmd_creator_root)

    return parser


def cmd_doctor(_args: argparse.Namespace) -> int:
    return doctor.cmd_doctor()


def cmd_skill_init(args: argparse.Namespace) -> int:
    skill_dir = Path(args.skill_dir).resolve()
    skill.emit_references(skill_dir)
    return 0


def cmd_onboard(args: argparse.Namespace) -> int:
    if args.schema:
        print(json.dumps(onboard.emit_schema(), indent=2))
        return 0
    if args.onboard_cmd != "run" or not args.stdin:
        print("error: onboard requires `run --stdin` for plan input", file=sys.stderr)
        return 1
    raw = sys.stdin.read()
    try:
        result = onboard.cmd_run(raw)
    except ValueError as exc:
        print(json.dumps({"error": str(exc)}, indent=2))
        return 1
    print(json.dumps(result, indent=2))
    return 0


def cmd_creator_root(args: argparse.Namespace) -> int:
    if args.schema:
        print(json.dumps(creator.emit_schema(), indent=2))
        return 0
    print("error: creator requires a subcommand (run|next|suggest|apply|migrate)", file=sys.stderr)
    return 1


def cmd_creator_run(args: argparse.Namespace) -> int:
    if not args.stdin:
        print("error: creator run requires --stdin", file=sys.stderr)
        return 1
    raw = sys.stdin.read()
    try:
        result = creator.cmd_run(raw)
    except ValueError as exc:
        print(json.dumps({"error": str(exc)}, indent=2))
        return 1
    print(json.dumps(result, indent=2))
    return 0


def cmd_creator_next(_args: argparse.Namespace) -> int:
    result = creator.cmd_next_json()
    print(json.dumps(result, indent=2))
    return 0


def cmd_creator_suggest(args: argparse.Namespace) -> int:
    if args.schema:
        print(json.dumps(creator.emit_suggest_schema(), indent=2))
        return 0
    if not args.stdin:
        print("error: creator suggest requires --stdin", file=sys.stderr)
        return 1
    raw = sys.stdin.read()
    try:
        result = creator.cmd_suggest_json(raw)
    except ValueError as exc:
        _print_json_error(str(exc), "asi creator suggest --schema")
        return 1
    print(json.dumps(result, indent=2))
    return 0


def cmd_creator_apply(args: argparse.Namespace) -> int:
    if args.schema:
        print(json.dumps(creator.emit_apply_schema(), indent=2))
        return 0
    if not args.stdin:
        print("error: creator apply requires --stdin", file=sys.stderr)
        return 1
    raw = sys.stdin.read()
    try:
        result = creator.cmd_apply_json(raw)
    except ValueError as exc:
        _print_json_error(str(exc), "asi creator apply --schema")
        return 1
    print(json.dumps(result, indent=2))
    return 0


def cmd_creator_migrate(args: argparse.Namespace) -> int:
    if args.source != "legacy":
        print("error: only legacy migration supported", file=sys.stderr)
        return 1
    from asi.creator.migrate import migrate_legacy
    result = migrate_legacy(force=args.force)
    print(json.dumps(result, indent=2))
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = create_parser()
    args = parser.parse_args(argv)

    if args.command is None:
        parser.print_help()
        return 0

    if hasattr(args, "func"):
        return args.func(args)

    return 0


if __name__ == "__main__":
    sys.exit(main())
