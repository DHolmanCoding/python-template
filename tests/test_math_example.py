import pytest

from python_template.math_example import add_one


@pytest.mark.unit
def test_add_one() -> None:
    assert add_one(3) == 4
