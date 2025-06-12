#!/bin/bash

# Render build script for installing Chrome and dependencies
echo "Installing Chrome and dependencies for Selenium..."

# Update package lists
apt-get update

# Install Chrome dependencies
apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \
    xvfb

# Add Google Chrome repository
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Install Google Chrome
apt-get update
apt-get install -y google-chrome-stable

# Verify Chrome installation
google-chrome --version

# Clean up
rm -rf /var/lib/apt/lists/*

echo "✅ Chrome and dependencies installed successfully!"
echo "🔧 Setting up Python environment..."

# Create necessary directories
mkdir -p /opt/render/project/src/Logs
mkdir -p /opt/render/project/src/Logs/Capture

echo "✅ Build completed successfully!"
