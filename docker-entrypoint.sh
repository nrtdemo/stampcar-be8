#!/bin/bash

# Set Robot Framework Docker environment variable
export ROBOT_FRAMEWORK_DOCKER=true

# Start Xvfb (virtual display) for headless Chrome
echo "Starting Xvfb virtual display..."
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# Wait a moment for Xvfb to start
sleep 2

# Verify ChromeDriver is available
echo "Verifying ChromeDriver installation..."
chromedriver --version

# Verify Chrome/Chromium is available (architecture-dependent)
echo "Verifying browser installation..."
if command -v google-chrome &> /dev/null; then
    google-chrome --version
elif command -v chromium &> /dev/null; then
    chromium --version
else
    echo "Warning: Neither Chrome nor Chromium found, but proceeding..."
fi

# Execute the command passed to the container
echo "Starting Robot Framework tests..."
exec "$@"
