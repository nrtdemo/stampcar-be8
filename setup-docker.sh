#!/bin/bash

# Setup script for StampCar Docker environment with Robot Framework and Selenium

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐋 Setting up StampCar Docker environment for Robot Framework + Selenium...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available. Please install Docker Compose.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed and ready!${NC}"

# Make scripts executable
chmod +x docker-run.sh
chmod +x docker-entrypoint.sh

echo -e "${GREEN}✅ Scripts made executable${NC}"

# Create logs directory if it doesn't exist
mkdir -p Logs/Capture

echo -e "${GREEN}✅ Logs directory created${NC}"

# Verify requirements.txt exists
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}❌ requirements.txt not found${NC}"
    exit 1
fi

# Verify Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}❌ Dockerfile not found${NC}"
    exit 1
fi

# Build the Docker image
echo -e "${BLUE}🏗️  Building Docker image with Chrome and ChromeDriver...${NC}"
docker build -t stampcar-robot-tests .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker setup completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}🚀 You can now run Robot Framework tests in Docker:${NC}"
    echo ""
    echo -e "${BLUE}License plate test:${NC}"
    echo "  ./docker-run.sh test license ABC123"
    echo ""
    echo -e "${BLUE}Serial number test:${NC}"
    echo "  ./docker-run.sh test serial SER456"
    echo ""
    echo -e "${BLUE}Run with Docker Compose:${NC}"
    echo "  ./docker-run.sh run"
    echo ""
    echo -e "${BLUE}Web interface:${NC}"
    echo "  docker-compose up --build"
    echo "  # Then open http://localhost:8080"
    echo ""
    echo -e "${BLUE}Debug shell:${NC}"
    echo "  ./docker-run.sh shell"
    echo ""
    echo -e "${BLUE}For help:${NC}"
    echo "  ./docker-run.sh help"
    echo ""
    echo -e "${YELLOW}📁 Test results will be saved to ./Logs directory${NC}"
    echo -e "${YELLOW}📸 Screenshots will be saved to ./Logs/Capture directory${NC}"
else
    echo -e "${RED}❌ Docker build failed. Please check the error messages above.${NC}"
    exit 1
fi
