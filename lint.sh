#!/bin/bash

# Script to lint the Flask application codebase

echo "================================"
echo "Linting Flask Application"
echo "================================"
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed. Please install uv first."
    echo "Visit: https://github.com/astral-sh/uv"
    exit 1
fi

# Ensure Ruff is available
echo "Installing Ruff..."
uv pip install ruff --quiet

echo ""
echo "================================"
echo "Running Ruff Linter"
echo "================================"
echo ""
uv run ruff check --fix .
ruff_check_exit=$?

echo ""
echo "================================"
echo "Running Ruff Formatter"
echo "================================"
echo ""
uv run ruff format .
ruff_format_exit=$?

echo ""
echo "================================"
echo "Linting Summary"
echo "================================"

failed=0

if [ $ruff_check_exit -eq 0 ]; then
    echo "✓ Ruff Linter: No issues found"
else
    echo "✗ Ruff Linter: Issues found (fix with: uv run ruff check --fix .)"
    failed=1
fi

if [ $ruff_format_exit -eq 0 ]; then
    echo "✓ Ruff Formatter: Code formatting looks good"
else
    echo "✗ Ruff Formatter: Code needs formatting (fix with: uv run ruff format .)"
    failed=1
fi

echo ""

if [ $failed -eq 0 ]; then
    echo "✅ All linting checks passed!"
    exit 0
else
    echo "❌ Some linting checks failed. Please fix the issues above."
    exit 1
fi
