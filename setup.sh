#!/bin/bash

# Setup script for Flask app
echo "🚀 Setting up Flask application environment..."

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv is not installed. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✅ uv installed successfully"
fi

echo "✅ uv found: $(uv --version)"

# Create virtual environment and install dependencies
echo "📦 Creating virtual environment and installing dependencies..."
uv sync

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "  1. Activate the virtual environment: source .venv/bin/activate"
echo "  2. Run the app: python app.py"
echo "  3. Access the app at: http://localhost:5000"
echo ""
echo "Alternative: Run directly with uv:"
echo "  uv run python app.py"
echo ""
echo "Available endpoints:"
echo "  - http://localhost:5000/"
echo "  - http://localhost:5000/hello"
echo "  - http://localhost:5000/version"
echo "  - http://localhost:5000/status"
