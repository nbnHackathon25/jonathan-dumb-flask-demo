#!/bin/bash

# Script to build Docker image for Flask application

echo "================================"
echo "Building Flask Application Docker Image"
echo "================================"
echo ""

# Docker availability is checked by scripts/setup.sh
# Verify Docker is accessible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please run scripts/setup.sh first."
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

# Set image names and tags
FLASK_IMAGE_NAME="jonathan-flask-demo"
NGINX_IMAGE_NAME="jonathan-flask-nginx"
IMAGE_TAG="latest"
FLASK_FULL_IMAGE="${FLASK_IMAGE_NAME}:${IMAGE_TAG}"
NGINX_FULL_IMAGE="${NGINX_IMAGE_NAME}:${IMAGE_TAG}"

echo "🐳 Building Docker images..."
echo ""

# Build the Flask Docker image
echo "📦 Building Flask image: ${FLASK_FULL_IMAGE}"
docker build -t "${FLASK_FULL_IMAGE}" .

if [ $? -ne 0 ]; then
    echo "❌ Flask Docker build failed"
    exit 1
fi

echo "✅ Flask image built successfully"
echo ""

# Build the Nginx Docker image
echo "📦 Building Nginx proxy image: ${NGINX_FULL_IMAGE}"
docker build -f Dockerfile.nginx -t "${NGINX_FULL_IMAGE}" .

if [ $? -ne 0 ]; then
    echo "❌ Nginx Docker build failed"
    exit 1
fi

echo "✅ Nginx image built successfully"

echo ""
echo "================================"
echo "Build Summary"
echo "================================"
echo "✅ Flask image built: ${FLASK_FULL_IMAGE}"
echo "✅ Nginx image built: ${NGINX_FULL_IMAGE}"
echo ""
echo "Next steps:"
echo ""
echo "Run Flask app directly:"
echo "  - docker run -p 5000:5000 ${FLASK_FULL_IMAGE}"
echo ""
echo "Run with Nginx proxy (recommended):"
echo "  - Start Flask: docker run -d --name flask-app ${FLASK_FULL_IMAGE}"
echo "  - Start Nginx: docker run -d -p 8080:80 --link flask-app:flask-app --name nginx-proxy ${NGINX_FULL_IMAGE}"
echo "  - Access at: http://localhost:8080"
echo ""
echo "Manage containers:"
echo "  - View logs: docker logs flask-app (or nginx-proxy)"
echo "  - Stop: docker stop flask-app nginx-proxy"
echo "  - Remove: docker rm flask-app nginx-proxy"
