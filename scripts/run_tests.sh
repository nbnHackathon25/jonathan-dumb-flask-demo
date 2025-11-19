#!/bin/bash

# Script to run unit tests for the Flask application with code coverage

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

# Ensure pytest, coverage, and diff-cover are available
echo "Ensuring pytest, coverage, and diff-cover are available..."
uv pip install pytest pytest-cov diff-cover --quiet

echo "Running tests with coverage..."
uv run pytest test_app.py -v --tb=short --cov=app --cov-report=term-missing --cov-report=html --cov-report=xml

# Capture test exit code
exit_code=$?

echo ""
echo "================================"
echo "Coverage Summary"
echo "================================"

if [ $exit_code -eq 0 ]; then
    echo "✓ All tests passed!"
else
    echo "✗ Some tests failed. Please review the output above."
fi

# Run diff-cover to show coverage for changed lines
echo ""
echo "================================"
echo "Diff Coverage (New/Changed Lines)"
echo "================================"

# Check if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Try to compare against origin/main, fall back to main, then to HEAD^
    if git rev-parse --verify origin/main > /dev/null 2>&1; then
        compare_branch="origin/main"
    elif git rev-parse --verify main > /dev/null 2>&1; then
        compare_branch="main"
    else
        compare_branch="HEAD^"
    fi
    
    echo "Comparing coverage against: $compare_branch"
    uv run diff-cover coverage.xml --compare-branch="$compare_branch" --fail-under=80
    diff_exit_code=$?
    
    echo ""
    echo "📊 Full coverage report: htmlcov/index.html"
    echo "   Open with: open htmlcov/index.html"
    
    # Exit with error if either tests or diff-cover failed
    if [ $exit_code -ne 0 ] || [ $diff_exit_code -ne 0 ]; then
        exit 1
    fi
else
    echo "⚠️  Not a git repository - skipping diff coverage"
    echo "📊 Full coverage report: htmlcov/index.html"
    echo "   Open with: open htmlcov/index.html"
fi

exit $exit_code
