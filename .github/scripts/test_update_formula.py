import importlib.util
import pathlib
import unittest


SCRIPT_PATH = pathlib.Path(__file__).with_name("update-formula.py")
SPEC = importlib.util.spec_from_file_location("update_formula", SCRIPT_PATH)
UPDATE_FORMULA = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPDATE_FORMULA)


class UpdateBlendFormulaTests(unittest.TestCase):
    def setUp(self):
        self.formula = pathlib.Path("Formula/blend.rb").read_text()
        self.checksums = {
            "blend-aarch64-apple-darwin.tar.xz": "1" * 64,
            "blend-aarch64-unknown-linux-gnu.tar.xz": "2" * 64,
            "blend-x86_64-apple-darwin.tar.xz": "3" * 64,
            "blend-x86_64-unknown-linux-gnu.tar.xz": "4" * 64,
        }

    def test_adds_linux_arm64_and_updates_all_checksums(self):
        content, repo, tag = UPDATE_FORMULA.update_formula_content(
            "blend", "1.2.3", self.formula, self.checksums
        )

        self.assertEqual(repo, "frantic1048/blend")
        self.assertEqual(tag, "blend-v1.2.3")
        self.assertIn('version "1.2.3"', content)
        self.assertIn("if Hardware::CPU.arm?", content)
        self.assertIn("blend-aarch64-unknown-linux-gnu.tar.xz", content)
        for checksum in self.checksums.values():
            self.assertIn(f'sha256 "{checksum}"', content)

    def test_rejects_a_release_missing_a_required_artifact(self):
        del self.checksums["blend-aarch64-unknown-linux-gnu.tar.xz"]

        with self.assertRaisesRegex(ValueError, "aarch64-unknown-linux-gnu"):
            UPDATE_FORMULA.update_formula_content(
                "blend", "1.2.3", self.formula, self.checksums
            )


if __name__ == "__main__":
    unittest.main()
