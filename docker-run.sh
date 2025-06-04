#!/bin/bash

# Build and run script for StampCar Robot Framework tests in Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="stampcar-robot-tests"
CONTAINER_NAME="stampcar-robot-container"

# Help function
show_help() {
    echo -e "${BLUE}StampCar Robot Framework Docker Runner${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build                Build the Docker image"
    echo "  run                  Run tests using Docker Compose"
    echo "  test [license|serial] [value]  Run specific test"
    echo "  shell               Open shell in container"
    echo "  logs                Show container logs"
    echo "  clean               Remove containers and images"
    echo "  help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run"
    echo "  $0 test license ABC123"
    echo "  $0 test serial SER456"
    echo "  $0 shell"
    echo ""
}

# Build Docker image
build_image() {
    echo -e "${BLUE}Building Docker image...${NC}"
    docker build -t $IMAGE_NAME .
    echo -e "${GREEN}Docker image built successfully!${NC}"
}

# Run tests using Docker Compose
run_compose() {
    echo -e "${BLUE}Running tests with Docker Compose...${NC}"
    docker-compose up --build
}

# Run specific test
run_test() {
    local test_type=$1
    local test_value=$2
    
    if [[ -z "$test_type" || -z "$test_value" ]]; then
        echo -e "${RED}Error: Test type and value are required${NC}"
        echo "Usage: $0 test [license|serial] [value]"
        exit 1
    fi
    
    if [[ "$test_type" != "license" && "$test_type" != "serial" ]]; then
        echo -e "${RED}Error: Test type must be 'license' or 'serial'${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Running $test_type test with value: $test_value${NC}"
    
    # Remove existing container if it exists
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    
    # Run the container with specific test parameters
    docker run \
        --name $CONTAINER_NAME \
        --rm \
        -v "$(pwd)/Logs:/app/Logs" \
        -e DISPLAY=:99 \
        --shm-size=2g \
        --security-opt seccomp:unconfined \
        $IMAGE_NAME \
        python3 run_robot.py --$test_type "$test_value"
        
    echo -e "${GREEN}Test completed!${NC}"
    echo -e "${YELLOW}Check ./Logs directory for results${NC}"
}

# Open shell in container
open_shell() {
    echo -e "${BLUE}Opening shell in container...${NC}"
    
    # Remove existing container if it exists
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    
    docker run \
        --name $CONTAINER_NAME \
        --rm \
        -it \
        -v "$(pwd)/Logs:/app/Logs" \
        -v "$(pwd)/robots:/app/robots" \
        -e DISPLAY=:99 \
        --shm-size=2g \
        --security-opt seccomp:unconfined \
        $IMAGE_NAME \
        /bin/bash
}

# Show logs
show_logs() {
    echo -e "${BLUE}Showing container logs...${NC}"
    docker logs $CONTAINER_NAME
}

# Clean up
clean_up() {
    echo -e "${BLUE}Cleaning up Docker resources...${NC}"
    
    # Stop and remove containers
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    docker-compose down 2>/dev/null || true
    
    # Remove image
    docker rmi $IMAGE_NAME 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup completed!${NC}"
}

# Main script logic
case "$1" in
    build)
        build_image
        ;;
    run)
        run_compose
        ;;
    test)
        run_test "$2" "$3"
        ;;
    shell)
        open_shell
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_up
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
