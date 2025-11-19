#!/bin/bash

# Script to build Docker image for Flask application

echo "================================"
echo "Building Flask Application Docker Image"
echo "================================"
echo ""

# Docker availability is checked by setup.sh
# Verify Docker is accessible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please run setup.sh first."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "⚠️  Docker daemon is not running. Attempting to start..."
    
    # Detect OS and try to start Docker
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - start Docker Desktop
        echo "Starting Docker Desktop on macOS..."
        open -a Docker
        echo "Waiting for Docker to start..."
        
        # Wait up to 60 seconds for Docker to start
        timeout=60
        elapsed=0
        while ! docker info &> /dev/null; do
            if [ $elapsed -ge $timeout ]; then
                echo "❌ Docker failed to start within ${timeout} seconds"
                echo "Please start Docker Desktop manually and try again"
                exit 1
            fi
            sleep 2
            elapsed=$((elapsed + 2))
            echo -n "."
        done
        echo ""
        echo "✅ Docker started successfully"
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - start Docker daemon
        echo "Starting Docker daemon on Linux..."
        sudo systemctl start docker
        
        # Wait a few seconds for Docker to start
        sleep 3
        
        if ! docker info &> /dev/null; then
            echo "❌ Docker daemon failed to start"
            echo "Try: sudo systemctl status docker"
            exit 1
        fi
        echo "✅ Docker started successfully"
        
    else
        echo "❌ Unsupported OS. Please start Docker manually"
        exit 1
    fi
fi

# Set image name and tag
IMAGE_NAME="jonathan-flask-demo"
IMAGE_TAG="latest"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

echo "🐳 Building Docker image: ${FULL_IMAGE}"
echo ""

# Build the Docker image
docker build -t "${FULL_IMAGE}" .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed"
    exit 1
fi

echo ""
echo "================================"
echo "Build Summary"
echo "================================"
echo "✅ Docker image built successfully: ${FULL_IMAGE}"
echo ""
echo "Next steps:"
echo "  - Run the container: docker run -p 5000:5000 ${FULL_IMAGE}"
echo "  - Run in background: docker run -d -p 5000:5000 --name flask-app ${FULL_IMAGE}"
echo "  - View logs: docker logs flask-app"
echo "  - Stop container: docker stop flask-app"
echo "  - Remove container: docker rm flask-app"
echo ""
echo "🌐 Access the app at: http://localhost:5000"
