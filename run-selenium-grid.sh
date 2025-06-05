#!/bin/bash

# Docker Selenium Grid + Flask App Runner
# This script starts the complete environment with Selenium Grid and Flask application

set -e

echo "🚀 Starting Selenium Grid + Flask Application Environment"
echo "========================================================"

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop and try again."
        exit 1
    fi
    echo "✅ Docker is running"
}

# Function to cleanup existing containers
cleanup() {
    echo "🧹 Cleaning up existing containers..."
    docker-compose -f docker-compose.yml down --remove-orphans || true
}

# Function to build and start services
start_services() {
    echo "🏗️  Building and starting services..."
    docker-compose -f docker-compose.yml up --build -d
    
    echo "⏳ Waiting for services to be ready..."
    sleep 10
    
    # Check if services are running
    echo "📊 Service Status:"
    docker-compose -f docker-compose.yml ps
}

# Function to show access information
show_access_info() {
    echo ""
    echo "🎉 Environment is ready!"
    echo "======================="
    echo "🌐 Flask Application:     http://localhost:8080"
    echo "🕸️  Selenium Grid Hub:     http://localhost:4444"
    echo "🖥️  Chrome VNC (Debug):    http://localhost:7900 (password: secret)"
    echo "🦊 Firefox VNC (Debug):   http://localhost:7901 (password: secret)"
    echo ""
    echo "📝 To view logs:"
    echo "   docker-compose -f docker-compose.yml logs -f [service-name]"
    echo ""
    echo "🛑 To stop all services:"
    echo "   docker-compose -f docker-compose.yml down"
    echo ""
}

# Function to wait for Flask app
wait_for_flask() {
    echo "⏳ Waiting for Flask application to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            echo "✅ Flask application is ready!"
            return 0
        fi
        echo "   Attempt $i/30 - waiting..."
        sleep 2
    done
    echo "⚠️  Flask application may not be ready yet. Check logs if needed."
}

# Function to wait for Selenium Grid
wait_for_selenium() {
    echo "⏳ Waiting for Selenium Grid to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:4444/status > /dev/null 2>&1; then
            echo "✅ Selenium Grid is ready!"
            return 0
        fi
        echo "   Attempt $i/30 - waiting..."
        sleep 2
    done
    echo "⚠️  Selenium Grid may not be ready yet. Check logs if needed."
}

# Main execution
main() {
    case "${1:-start}" in
        "start")
            check_docker
            cleanup
            start_services
            wait_for_selenium
            wait_for_flask
            show_access_info
            ;;
        "stop")
            echo "🛑 Stopping all services..."
            docker-compose -f docker-compose.yml down
            echo "✅ All services stopped"
            ;;
        "restart")
            echo "🔄 Restarting services..."
            $0 stop
            sleep 2
            $0 start
            ;;
        "logs")
            docker-compose -f docker-compose.yml logs -f
            ;;
        "status")
            docker-compose -f docker-compose.yml ps
            ;;
        "build")
            echo "🏗️  Building images..."
            docker-compose -f docker-compose.yml build
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|logs|status|build}"
            echo ""
            echo "Commands:"
            echo "  start   - Start all services (default)"
            echo "  stop    - Stop all services"
            echo "  restart - Restart all services"
            echo "  logs    - Show logs from all services"
            echo "  status  - Show status of all services"
            echo "  build   - Build Docker images"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
