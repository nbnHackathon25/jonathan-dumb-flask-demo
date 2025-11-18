#!/bin/bash

# Setup script for Flask app
echo "🚀 Setting up Flask application environment..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📥 Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "  1. Activate the virtual environment: source venv/bin/activate"
echo "  2. Run the app: python app.py"
echo "  3. Access the app at: http://localhost:5000"
echo ""
echo "Available endpoints:"
echo "  - http://localhost:5000/"
echo "  - http://localhost:5000/hello"
echo "  - http://localhost:5000/version"
echo "  - http://localhost:5000/status"
