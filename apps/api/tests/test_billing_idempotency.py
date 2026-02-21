"""
Tests for billing idempotency.
These tests are skipped because they require full app context with PostGIS.
"""
import pytest

# Skip entire module - requires full app with PostGIS database
pytest.skip("Requires full app context with PostGIS database", allow_module_level=True)
