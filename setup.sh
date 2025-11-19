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
uv sync --allow-insecure-host pypi.org

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

# Detect Flask application file and variable name
echo ""
echo "🔎 Detecting Flask application..."
FLASK_FILE=""
FLASK_APP_VAR=""

# Search for Flask app in common locations
for file in app.py main.py server.py application.py wsgi.py run.py; do
    if [ -f "$file" ]; then
        # Check if file contains Flask app instantiation
        if grep -q "Flask(__name__)" "$file" 2>/dev/null; then
            FLASK_FILE="$file"
            # Try to detect the app variable name (e.g., app = Flask(__name__))
            FLASK_APP_VAR=$(grep -oE '^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*Flask\(' "$file" | head -1 | sed -E 's/^\s*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
            break
        fi
    fi
done

# Fallback: search all Python files if not found
if [ -z "$FLASK_FILE" ]; then
    for file in *.py; do
        if [ -f "$file" ] && grep -q "Flask(__name__)" "$file" 2>/dev/null; then
            FLASK_FILE="$file"
            FLASK_APP_VAR=$(grep -oE '^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*Flask\(' "$file" | head -1 | sed -E 's/^\s*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
            break
        fi
    done
fi

# Default values if detection fails
if [ -z "$FLASK_FILE" ]; then
    FLASK_FILE="app.py"
    FLASK_APP_VAR="app"
    echo "⚠️  Could not detect Flask app, using defaults: $FLASK_FILE with variable '$FLASK_APP_VAR'"
else
    echo "✅ Detected Flask app: $FLASK_FILE with variable '$FLASK_APP_VAR'"
fi

# Extract module name (filename without .py extension)
MODULE_NAME="${FLASK_FILE%.py}"

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "  1. Activate the virtual environment: source .venv/bin/activate"
echo "  2. Run the app on port $PORT: python -c \"from $MODULE_NAME import $FLASK_APP_VAR; $FLASK_APP_VAR.run(debug=True, host='0.0.0.0', port=$PORT)\""
echo "  3. Access the app at: http://localhost:$PORT"
echo ""
echo "Alternative: Run directly with uv:"
echo "  uv run python -c \"from $MODULE_NAME import $FLASK_APP_VAR; $FLASK_APP_VAR.run(debug=True, host='0.0.0.0', port=$PORT)\""
echo ""
echo "Or use the run_local.sh script:"
echo "  ./run_local.sh"
echo ""
echo "Available endpoints:"
echo "  - http://localhost:$PORT/"
echo "  - http://localhost:$PORT/hello"
echo "  - http://localhost:$PORT/version"
echo "  - http://localhost:$PORT/status"
