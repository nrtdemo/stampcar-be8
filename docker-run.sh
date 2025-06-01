#!/bin/bash

# Build and run Robot Framework Web Runner in Docker

set -e

echo "🐳 Building Robot Framework Web Runner Docker image..."

# Build the Docker image
docker build -t robot-web-runner:latest .

echo "✅ Docker image built successfully!"

echo "🚀 Starting Robot Framework Web Runner..."

# Stop any existing container
docker stop robot-web-runner 2>/dev/null || true
docker rm robot-web-runner 2>/dev/null || true

# Run the container
docker run -d \
  --name robot-web-runner \
  -p 8080:8080 \
  -v "$(pwd)/Logs:/app/Logs" \
  --restart unless-stopped \
  robot-web-runner:latest

echo "✅ Robot Framework Web Runner is now running!"
echo "🌐 Access the web interface at: http://localhost:8080"
echo ""
echo "📋 Useful commands:"
echo "  View logs:    docker logs robot-web-runner -f"
echo "  Stop service: docker stop robot-web-runner"
echo "  Restart:      docker restart robot-web-runner"
echo "  Remove:       docker rm -f robot-web-runner"
