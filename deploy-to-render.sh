#!/bin/bash

# Render.com Deployment Script for StampCar Robot Framework
# This script prepares and guides you through deploying to Render.com

set -e

echo "🚀 Render.com Deployment for StampCar Robot Framework"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Check if we're in a Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_warning "Not in a Git repository. Initializing..."
        git init
        git add .
        git commit -m "Initial commit for Render deployment"
    fi
    
    # Check if Docker is available (for local testing)
    if command -v docker &> /dev/null; then
        print_status "Docker is available for local testing"
    else
        print_warning "Docker not found. You can still deploy to Render, but local testing won't be available."
    fi
    
    print_status "Prerequisites check completed"
}

# Function to validate required files
validate_files() {
    print_info "Validating required deployment files..."
    
    required_files=(
        "Dockerfile"
        "render.yaml"
        "requirements.txt"
        "main.py"
        "robots/"
        "templates/"
        "static/"
    )
    
    for file in "${required_files[@]}"; do
        if [ -e "$file" ]; then
            print_status "Found: $file"
        else
            print_error "Missing required file: $file"
            exit 1
        fi
    done
    
    print_status "All required files are present"
}

# Function to test Docker build locally
test_docker_build() {
    if command -v docker &> /dev/null; then
        echo ""
        read -p "🔨 Do you want to test the Docker build locally? (y/N): " test_build
        
        if [[ $test_build == "y" || $test_build == "Y" ]]; then
            print_info "Building Docker image locally..."
            
            if docker build -t stampcar-robot-framework .; then
                print_status "Docker build successful!"
                
                echo ""
                read -p "🚀 Do you want to test run the container? (y/N): " test_run
                
                if [[ $test_run == "y" || $test_run == "Y" ]]; then
                    print_info "Starting container on port 8080..."
                    echo "Press Ctrl+C to stop the container"
                    docker run -p 8080:10000 -e PORT=10000 stampcar-robot-framework
                fi
            else
                print_error "Docker build failed! Please fix the issues before deploying."
                exit 1
            fi
        fi
    fi
}

# Function to prepare Git repository
prepare_git() {
    print_info "Preparing Git repository..."
    
    # Add all files
    git add .
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        print_status "No changes to commit"
    else
        echo ""
        read -p "📝 Enter commit message (or press Enter for default): " commit_message
        
        if [ -z "$commit_message" ]; then
            commit_message="Update for Render.com deployment $(date +%Y-%m-%d)"
        fi
        
        git commit -m "$commit_message"
        print_status "Changes committed"
    fi
    
    # Check if remote origin exists
    if ! git remote get-url origin > /dev/null 2>&1; then
        print_warning "No Git remote 'origin' found."
        echo ""
        read -p "📡 Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): " repo_url
        
        if [ ! -z "$repo_url" ]; then
            git remote add origin "$repo_url"
            print_status "Remote origin added"
        fi
    fi
    
    # Push to remote
    echo ""
    read -p "🚀 Push to GitHub? (Y/n): " push_confirm
    
    if [[ $push_confirm != "n" && $push_confirm != "N" ]]; then
        current_branch=$(git branch --show-current)
        git push -u origin "$current_branch"
        print_status "Code pushed to GitHub"
    fi
}

# Function to show deployment instructions
show_deployment_instructions() {
    echo ""
    echo "🎉 Ready for Render.com Deployment!"
    echo "=================================="
    echo ""
    print_info "Next steps:"
    echo ""
    echo "1. 🌐 Go to https://render.com and sign in"
    echo "2. 🔗 Connect your GitHub account if you haven't already"
    echo "3. ➕ Click 'New' → 'Web Service'"
    echo "4. 📂 Select your repository: $(git remote get-url origin 2>/dev/null || echo 'your-repo')"
    echo "5. ⚙️  Configure the service:"
    echo "   - Name: stampcar-robot-framework"
    echo "   - Environment: Docker"
    echo "   - Dockerfile Path: ./Dockerfile"
    echo "   - Instance Type: Starter (or higher)"
    echo ""
    print_info "Render will automatically:"
    echo "   - Read the render.yaml configuration"
    echo "   - Build your Docker image"
    echo "   - Deploy your application"
    echo "   - Provide a public URL"
    echo ""
    print_warning "Important notes:"
    echo "   - First deployment may take 5-10 minutes"
    echo "   - Starter plan includes 750 hours/month free"
    echo "   - Your app will sleep after 15 minutes of inactivity (Starter plan)"
    echo "   - Consider upgrading to a paid plan for production use"
    echo ""
    print_status "Deployment preparation complete!"
}

# Main execution
main() {
    case "${1:-deploy}" in
        "check")
            check_prerequisites
            validate_files
            ;;
        "build")
            check_prerequisites
            validate_files
            test_docker_build
            ;;
        "deploy"|"")
            check_prerequisites
            validate_files
            test_docker_build
            prepare_git
            show_deployment_instructions
            ;;
        "help")
            echo "Usage: $0 {check|build|deploy|help}"
            echo ""
            echo "Commands:"
            echo "  check   - Check prerequisites and validate files"
            echo "  build   - Test Docker build locally"
            echo "  deploy  - Full deployment preparation (default)"
            echo "  help    - Show this help message"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
