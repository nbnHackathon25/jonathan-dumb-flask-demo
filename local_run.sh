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
uv run python -c "from app import app; app.run(debug=True, host='0.0.0.0', port=$PORT)"
