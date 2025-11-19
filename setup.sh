#!/bin/bash

# Setup script for Flask app
echo "🚀 Setting up Flask application environment..."

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv is not installed. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✅ uv installed successfully"
    # Add uv to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "✅ uv found: $(uv --version)"

# Create virtual environment and install dependencies
echo "📦 Creating virtual environment and installing dependencies..."
uv sync

# Find an available port starting from 5000
DEFAULT_PORT=5000
PORT=$DEFAULT_PORT
MAX_PORT=5010

echo ""
echo "🔍 Checking for available port..."
while lsof -i :$PORT &> /dev/null; do
    echo "⚠️  Port $PORT is in use, trying next port..."
    PORT=$((PORT + 1))
    if [ $PORT -gt $MAX_PORT ]; then
        echo "❌ No available ports found between $DEFAULT_PORT and $MAX_PORT"
        exit 1
    fi
done

echo "✅ Port $PORT is available"

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "  1. Activate the virtual environment: source .venv/bin/activate"
echo "  2. Run the app on port $PORT: python -c \"from app import app; app.run(debug=True, host='0.0.0.0', port=$PORT)\""
echo "  3. Access the app at: http://localhost:$PORT"
echo ""
echo "Alternative: Run directly with uv:"
echo "  uv run python -c \"from app import app; app.run(debug=True, host='0.0.0.0', port=$PORT)\""
echo ""
echo "Available endpoints:"
echo "  - http://localhost:$PORT/"
echo "  - http://localhost:$PORT/hello"
echo "  - http://localhost:$PORT/version"
echo "  - http://localhost:$PORT/status"
