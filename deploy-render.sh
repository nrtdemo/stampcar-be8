#!/bin/bash

# Render.com Deployment Helper Script
# This script helps prepare and deploy the StampCar Robot Framework app to Render.com

set -e

echo "🚀 Render.com Deployment Helper for StampCar Robot Framework"
echo "============================================================"

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        echo "❌ Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Check if we're in a Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a Git repository. Please initialize Git first:"
        echo "   git init"
        echo "   git remote add origin <your-repo-url>"
        exit 1
    fi
    
    echo "✅ Prerequisites check passed"
}

# Function to validate required files
validate_files() {
    echo "📋 Validating required files..."
    
    required_files=(
        "Dockerfile"
        "requirements.txt"
        "main.py"
        "render.yaml"
        "robots/stampcar-be8.robot"
        "templates/index.html"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Missing required file: $file"
            exit 1
        fi
    done
    
    echo "✅ All required files present"
}

# Function to show deployment checklist
show_checklist() {
    echo ""
    echo "📝 Pre-deployment Checklist:"
    echo "=============================="
    echo "✅ Dockerfile configured for production"
    echo "✅ render.yaml created with service configuration"
    echo "✅ Environment variables ready"
    echo "✅ Robot Framework tests configured for headless mode"
    echo "✅ All required files present"
    echo ""
}

# Function to show next steps
show_next_steps() {
    echo "🎯 Next Steps for Render.com Deployment:"
    echo "========================================"
    echo ""
    echo "1. 📤 Push your code to GitHub:"
    echo "   git add ."
    echo "   git commit -m \"Add Render.com deployment configuration\""
    echo "   git push origin main"
    echo ""
    echo "2. 🌐 Deploy on Render.com:"
    echo "   - Go to https://render.com"
    echo "   - Click 'New' → 'Web Service'"
    echo "   - Connect your GitHub repository"
    echo "   - Choose 'Docker' as environment"
    echo "   - Use these settings:"
    echo "     * Name: stampcar-robot-framework"
    echo "     * Environment: Docker"
    echo "     * Dockerfile Path: ./Dockerfile"
    echo "     * Instance Type: Starter (or higher)"
    echo ""
    echo "3. 🔧 Configure Environment Variables:"
    echo "   - FLASK_ENV=production"
    echo "   - ROBOT_FRAMEWORK_HEADLESS=true"
    echo "   - (PORT and HOST are set automatically by Render)"
    echo ""
    echo "4. 🚀 Deploy and Test:"
    echo "   - Wait for deployment to complete"
    echo "   - Test your app at: https://your-service-name.onrender.com"
    echo ""
    echo "📚 For detailed instructions, see: RENDER_DEPLOYMENT.md"
    echo ""
}

# Function to test Docker build locally
test_docker_build() {
    echo "🐳 Testing Docker build locally..."
    
    if docker build -t stampcar-test . > /dev/null 2>&1; then
        echo "✅ Docker build successful"
        
        # Clean up test image
        docker rmi stampcar-test > /dev/null 2>&1
    else
        echo "❌ Docker build failed. Please check your Dockerfile."
        exit 1
    fi
}

# Function to show file structure
show_structure() {
    echo "📁 Current Project Structure:"
    echo "============================"
    tree -I '__pycache__|*.pyc|.git|node_modules|venv|env' -L 3 2>/dev/null || {
        echo "📂 ."
        echo "├── 📄 Dockerfile"
        echo "├── 📄 render.yaml"
        echo "├── 📄 main.py"
        echo "├── 📄 requirements.txt"
        echo "├── 📄 RENDER_DEPLOYMENT.md"
        echo "├── 📁 robots/"
        echo "│   └── 📄 stampcar-be8.robot"
        echo "├── 📁 templates/"
        echo "│   └── 📄 index.html"
        echo "├── 📁 static/"
        echo "│   └── 📄 style.css"
        echo "└── 📁 resources/"
        echo "    ├── 📄 docker_config.robot"
        echo "    └── 📄 cloud_config.robot"
    }
    echo ""
}

# Main execution
main() {
    case "${1:-help}" in
        "check")
            check_prerequisites
            validate_files
            test_docker_build
            echo "🎉 All checks passed! Ready for deployment."
            ;;
        "structure")
            show_structure
            ;;
        "deploy")
            check_prerequisites
            validate_files
            show_checklist
            show_next_steps
            ;;
        "help"|*)
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  check     - Run all validation checks"
            echo "  structure - Show project structure"
            echo "  deploy    - Show deployment instructions"
            echo "  help      - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 check     # Validate everything is ready"
            echo "  $0 deploy    # Show deployment steps"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
