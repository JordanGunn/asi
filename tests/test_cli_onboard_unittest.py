import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PYTHON = sys.executable
ENV_BASE = os.environ.copy()
ENV_BASE["PYTHONPATH"] = str(ROOT / "skills" / "cli" / "src")


def run_cli(args, *, cwd: Path, stdin: str | None = None):
    result = subprocess.run(
        [PYTHON, "-m", "asi.cli", *args],
        cwd=str(cwd),
        env=ENV_BASE,
        input=stdin,
        text=True,
        capture_output=True,
    )
    return result.returncode, result.stdout, result.stderr


class TestAsiOnboardCli(unittest.TestCase):
    def test_onboard_schema(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code, out, err = run_cli(["onboard", "--schema"], cwd=cwd)
            self.assertEqual(code, 0, err)
            data = json.loads(out)
            self.assertIn("properties", data)
            self.assertIn("topic", data["properties"])
            self.assertEqual(data.get("type"), "object")
            self.assertEqual(data.get("additionalProperties"), False)

    def test_onboard_schema_is_stable(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code1, out1, err1 = run_cli(["onboard", "--schema"], cwd=cwd)
            self.assertEqual(code1, 0, err1)
            code2, out2, err2 = run_cli(["onboard", "--schema"], cwd=cwd)
            self.assertEqual(code2, 0, err2)
            self.assertEqual(json.loads(out1), json.loads(out2))

    def test_onboard_run_accepts_plan(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(
                ["onboard", "run", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"topic": "Read entrypoints", "entrypoints": ["llms.txt"]}),
            )
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            self.assertEqual(payload["status"], "ready")
            self.assertEqual(payload["plan"]["topic"], "Read entrypoints")

    def test_onboard_run_rejects_invalid_plan(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(
                ["onboard", "run", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"topic": ""}),
            )
            self.assertNotEqual(code, 0, out + err)
            payload = json.loads(out)
            self.assertIn("error", payload)


if __name__ == "__main__":
    unittest.main()
