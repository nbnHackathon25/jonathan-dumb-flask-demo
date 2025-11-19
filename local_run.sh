#!/bin/bash

# Local run script for Flask app
echo "🚀 Starting Flask application..."

# Find an available port starting from 5000
DEFAULT_PORT=5000
PORT=$DEFAULT_PORT
MAX_PORT=5010

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
    echo "❌ Could not detect Flask application file"
    echo "Please ensure you have a Python file with Flask(__name__) in it"
    exit 1
fi

echo "✅ Detected Flask app: $FLASK_FILE with variable '$FLASK_APP_VAR'"

# Extract module name (filename without .py extension)
MODULE_NAME="${FLASK_FILE%.py}"

echo ""
echo "🌐 Starting Flask app on port $PORT..."
echo "📍 Access the app at: http://localhost:$PORT"
echo ""
echo "Available endpoints:"
echo "  - http://localhost:$PORT/"
echo "  - http://localhost:$PORT/hello"
echo "  - http://localhost:$PORT/version"
echo "  - http://localhost:$PORT/status"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Run the Flask app using uv
uv run python -c "from $MODULE_NAME import $FLASK_APP_VAR; $FLASK_APP_VAR.run(debug=True, host='0.0.0.0', port=$PORT)"
