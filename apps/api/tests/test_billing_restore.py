"""
Tests for billing restore functionality.
These tests are skipped because they require full app context with PostGIS.
"""
import pytest

# Skip entire module - requires full app context with PostGIS database
pytest.skip("Requires full app context with PostGIS database", allow_module_level=True)
