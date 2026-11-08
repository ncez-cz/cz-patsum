# Test for REA-003: removal of empty package-lock.json
# Validates that the vestigial empty package-lock.json no longer exists in the repository root.

import os
import unittest


class TestPackageLockRemoved(unittest.TestCase):
    REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
    PACKAGE_LOCK_PATH = os.path.join(REPO_ROOT, "package-lock.json")

    def test_empty_package_lock_removed(self):
        """The empty package-lock.json must not be present in the repository root."""
        self.assertFalse(
            os.path.exists(self.PACKAGE_LOCK_PATH),
            "package-lock.json still exists in repository root (REA-003 not applied)",
        )


if __name__ == "__main__":
    unittest.main()
