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


class TestAsiCreatorCli(unittest.TestCase):
    def test_creator_schema(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code, out, err = run_cli(["creator", "--schema"], cwd=cwd)
            self.assertEqual(code, 0, err)
            data = json.loads(out)
            self.assertIn("properties", data)
            self.assertIn("goal", data["properties"])
            self.assertIn("phase", data["properties"])
            self.assertEqual(data.get("type"), "object")
            self.assertEqual(data.get("additionalProperties"), False)

    def test_creator_schema_is_stable(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code1, out1, err1 = run_cli(["creator", "--schema"], cwd=cwd)
            self.assertEqual(code1, 0, err1)
            code2, out2, err2 = run_cli(["creator", "--schema"], cwd=cwd)
            self.assertEqual(code2, 0, err2)
            self.assertEqual(json.loads(out1), json.loads(out2))

    def test_creator_suggest_schema(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code, out, err = run_cli(["creator", "suggest", "--schema"], cwd=cwd)
            self.assertEqual(code, 0, err)
            data = json.loads(out)
            self.assertEqual(data.get("type"), "object")
            self.assertIn("suggestions", data.get("properties", {}))
            suggestions = data["properties"]["suggestions"]
            item = suggestions["items"]
            self.assertIn("recommended", item["properties"])
            options_item = item["properties"]["options"]["items"]
            self.assertEqual(
                options_item.get("required"),
                ["label", "value", "description", "impact"],
            )

    def test_creator_apply_schema(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code, out, err = run_cli(["creator", "apply", "--schema"], cwd=cwd)
            self.assertEqual(code, 0, err)
            data = json.loads(out)
            self.assertEqual(data.get("type"), "object")
            self.assertIn("ask_set_id", data.get("properties", {}))
            self.assertIn("answers", data.get("properties", {}))
            answer_item = data["properties"]["answers"]["items"]
            self.assertEqual(answer_item.get("required"), ["question_id", "selection"])

    def test_creator_next_option_constraints_are_complete(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()
            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            self.assertEqual(payload["status"], "need_suggestions")
            question = payload["questions"][0]
            oc = question["option_constraints"]
            self.assertEqual(
                oc["required_fields"], ["label", "value", "description", "impact"]
            )
            self.assertEqual(oc["max_label_chars"], 80)
            self.assertEqual(oc["max_value_chars"], 200)
            self.assertEqual(oc["max_description_chars"], 180)
            self.assertEqual(oc["max_impact_chars"], 180)
            self.assertTrue(oc["required_impact_field"])
            self.assertNotIn("required_tradeoff_field", oc)

    def test_creator_loop_happy_path(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            self.assertEqual(payload["status"], "need_suggestions")
            questions = payload["questions"]
            self.assertGreaterEqual(len(questions), 1)
            self.assertLessEqual(len(questions), 3)
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 1,
                        "rationale": {"evidence": [], "reasoning": "Based on defaults"},
                    }
                )

            code, out, err = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            self.assertEqual(code, 0, err)
            ask_payload = json.loads(out)
            self.assertEqual(ask_payload["status"], "need_answers")
            self.assertIn("ask_set_id", ask_payload)
            for q in ask_payload["questions"]:
                self.assertEqual(len(q["options"]), 4)
                # Option 4 is always the fixed alternative label
                self.assertEqual(q["options"][3]["label"], "Respond with an alternative")

            answers = [
                {"question_id": q["id"], "selection": 1, "user_confirmation": True}
                for q in ask_payload["questions"]
            ]

            code, out, err = run_cli(
                ["creator", "apply", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"ask_set_id": ask_payload["ask_set_id"], "answers": answers}),
            )
            self.assertEqual(code, 0, err)
            final_payload = json.loads(out)
            self.assertIn(final_payload["status"], ("ready", "need_suggestions"))
            self.assertIn("reflection", final_payload)

    def test_creator_suggest_allows_recommended_1_to_3(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            questions = payload["questions"]
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 3,
                        "rationale": {},
                    }
                )

            code, out, err = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            self.assertEqual(code, 0, err)
            ask_payload = json.loads(out)
            self.assertEqual(ask_payload["status"], "need_answers")
            for q in ask_payload["questions"]:
                self.assertEqual(q["recommended"], 3)

    def test_creator_loop_allows_alternative_value(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            questions = payload["questions"]
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 1,
                        "rationale": {},
                    }
                )

            code, out, err = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            self.assertEqual(code, 0, err)
            ask_payload = json.loads(out)
            self.assertEqual(ask_payload["status"], "need_answers")

            # Select option 4 for the first question and provide alternative_text.
            alt_value = "my-alternative-value"
            answers = []
            for idx, q in enumerate(ask_payload["questions"]):
                if idx == 0:
                    answers.append(
                        {
                            "question_id": q["id"],
                            "selection": 4,
                            "alternative_text": alt_value,
                            "user_confirmation": True,
                        }
                    )
                else:
                    answers.append(
                        {"question_id": q["id"], "selection": 1, "user_confirmation": True}
                    )

            code, out, err = run_cli(
                ["creator", "apply", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"ask_set_id": ask_payload["ask_set_id"], "answers": answers}),
            )
            self.assertEqual(code, 0, err)

            # Verify state recorded the alternative decision deterministically.
            state_path = cwd / ".asi" / "creator" / "state.json"
            self.assertTrue(state_path.exists())
            state = json.loads(state_path.read_text())
            first_decision_key = ask_payload["questions"][0]["decision_key"]
            self.assertEqual(state["decisions"][first_decision_key]["source"], "alternative")
            self.assertEqual(state["decisions"][first_decision_key]["value"], alt_value)

    def test_creator_apply_requires_confirmation(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            _, out, _ = run_cli(["creator", "next"], cwd=cwd)
            payload = json.loads(out)
            questions = payload["questions"]
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 1,
                        "rationale": {},
                    }
                )

            _, out, _ = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            ask_payload = json.loads(out)

            answers = [
                {"question_id": q["id"], "selection": 1, "user_confirmation": False}
                for q in ask_payload["questions"]
            ]

            code, out, err = run_cli(
                ["creator", "apply", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"ask_set_id": ask_payload["ask_set_id"], "answers": answers}),
            )
            self.assertEqual(code, 0, err)
            result = json.loads(out)
            self.assertEqual(result["status"], "need_answers")
            self.assertIn("User confirmation required", result.get("message", ""))

    def test_creator_suggest_rejects_iteration_mismatch(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            questions = payload["questions"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 1,
                        "rationale": {},
                    }
                )

            code, out, err = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": "not-the-current-iteration", "suggestions": suggestions}),
            )
            self.assertNotEqual(code, 0, out + err)
            payload = json.loads(out)
            self.assertIn("error", payload)

    def test_creator_suggest_rejects_recommended_out_of_range(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            code, out, err = run_cli(["creator", "next"], cwd=cwd)
            self.assertEqual(code, 0, err)
            payload = json.loads(out)
            questions = payload["questions"]
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 4,
                        "rationale": {},
                    }
                )

            code, out, err = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            self.assertNotEqual(code, 0, out + err)
            payload = json.loads(out)
            self.assertIn("error", payload)

    def test_creator_apply_rejects_missing_alternative_text(self):
        with tempfile.TemporaryDirectory() as td:
            cwd = Path(td)
            (cwd / ".git").mkdir()

            _, out, _ = run_cli(["creator", "next"], cwd=cwd)
            payload = json.loads(out)
            questions = payload["questions"]
            iteration_id = payload["iteration_id"]

            suggestions = []
            for idx, q in enumerate(questions, start=1):
                suggestions.append(
                    {
                        "question_id": q["id"],
                        "options": [
                            {
                                "label": f"Option {idx}.1",
                                "value": f"value-{idx}-1",
                                "description": "Recommended approach",
                                "impact": "Lowest risk",
                            },
                            {
                                "label": f"Option {idx}.2",
                                "value": f"value-{idx}-2",
                                "description": "Alternative approach",
                                "impact": "Medium risk",
                            },
                            {
                                "label": f"Option {idx}.3",
                                "value": f"value-{idx}-3",
                                "description": "Aggressive approach",
                                "impact": "Higher risk",
                            },
                        ],
                        "recommended": 1,
                        "rationale": {},
                    }
                )

            _, out, _ = run_cli(
                ["creator", "suggest", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"iteration_id": iteration_id, "suggestions": suggestions}),
            )
            ask_payload = json.loads(out)

            answers = [
                {"question_id": q["id"], "selection": 4, "user_confirmation": True}
                for q in ask_payload["questions"]
            ]

            code, out, err = run_cli(
                ["creator", "apply", "--stdin"],
                cwd=cwd,
                stdin=json.dumps({"ask_set_id": ask_payload["ask_set_id"], "answers": answers}),
            )
            self.assertNotEqual(code, 0, out + err)
            payload = json.loads(out)
            self.assertIn("error", payload)


if __name__ == "__main__":
    unittest.main()
