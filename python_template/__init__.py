from pathlib import Path

PACKAGE_ROOT: Path = Path(__file__).parent
REPO_ROOT: Path = PACKAGE_ROOT.parent
TESTS: Path = REPO_ROOT / "tests"
