#!/bin/bash

# Setup script for Robot Framework Web Runner Docker deployment

echo "🤖 Robot Framework Web Runner - Docker Setup"
echo "============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed."
    echo "Please install Docker from: https://www.docker.com/get-started"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running."
    echo "Please start Docker Desktop or Docker service."
    exit 1
fi

echo "✅ Docker is available"

# Build the image
echo "🏗️  Building Docker image..."
docker build -t robot-web-runner:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
    
    # Stop existing container if running
    echo "🔄 Stopping existing container..."
    docker stop robot-web-runner 2>/dev/null || true
    docker rm robot-web-runner 2>/dev/null || true
    
    # Run the container
    echo "🚀 Starting Robot Framework Web Runner..."
    docker run -d \
      --name robot-web-runner \
      -p 8080:8080 \
      -v "$(pwd)/Logs:/app/Logs" \
      --restart unless-stopped \
      robot-web-runner:latest
    
    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully!"
        echo ""
        echo "🌐 Web Interface: http://localhost:8080"
        echo "📊 Container Status: docker ps"
        echo "📋 View Logs: docker logs robot-web-runner -f"
        echo ""
        echo "🎯 Test the service:"
        echo "   curl http://localhost:8080"
    else
        echo "❌ Failed to start container"
        exit 1
    fi
else
    echo "❌ Failed to build Docker image"
    exit 1
fi
