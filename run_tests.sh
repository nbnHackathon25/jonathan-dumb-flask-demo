#!/bin/bash

# Script to run unit tests for the Flask application

echo "================================"
echo "Running Flask Application Tests"
echo "================================"
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed. Please install uv first."
    echo "Visit: https://github.com/astral-sh/uv"
    exit 1
fi

# Ensure pytest is in the dependencies
echo "Ensuring pytest is available..."
uv pip install pytest --quiet

echo "Running tests..."
uv run pytest test_app.py -v --tb=short

# Capture exit code
exit_code=$?

echo ""
if [ $exit_code -eq 0 ]; then
    echo "✓ All tests passed!"
else
    echo "✗ Some tests failed. Please review the output above."
fi

exit $exit_code
