#!/bin/bash

# High-Security Banking Application Setup Script
# Phase 1: Foundation & Core Infrastructure

set -e

echo "🚀 Starting Banking Application Setup..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    # Check .NET SDK
    if ! command -v dotnet &> /dev/null; then
        missing_tools+=("dotnet")
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Setup AWS credentials
setup_aws() {
    print_status "Setting up AWS credentials..."
    
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        print_warning "AWS credentials not found in environment variables"
        echo "Please set the following environment variables:"
        echo "  export AWS_ACCESS_KEY_ID=your_access_key"
        echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
        echo "  export AWS_DEFAULT_REGION=us-east-1"
        exit 1
    fi
    
    print_success "AWS credentials configured"
}

# Initialize Terraform
setup_terraform() {
    print_status "Setting up Terraform infrastructure..."
    
    cd infrastructure
    
    # Copy example variables file if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_warning "Please edit terraform.tfvars with your specific values"
        echo "  - Set db_password to a secure password"
        echo "  - Update certificate_arn if you have an SSL certificate"
        echo "  - Review other settings as needed"
        read -p "Press Enter after editing terraform.tfvars..."
    fi
    
    # Initialize Terraform
    terraform init
    
    # Plan the infrastructure
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    # Ask for confirmation
    read -p "Do you want to apply the Terraform plan? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Applying Terraform configuration..."
        terraform apply tfplan
        print_success "Infrastructure deployed successfully"
    else
        print_warning "Terraform plan not applied. Run 'terraform apply' manually when ready."
    fi
    
    cd ..
}

# Setup Kubernetes
setup_kubernetes() {
    print_status "Setting up Kubernetes cluster..."
    
    # Get cluster name from Terraform output
    cd infrastructure
    CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "banking-app-cluster-development")
    cd ..
    
    # Update kubeconfig
    aws eks update-kubeconfig --region us-east-1 --name "$CLUSTER_NAME"
    
    # Apply Kubernetes manifests
    print_status "Applying Kubernetes manifests..."
    kubectl apply -f infrastructure/k8s/
    
    # Wait for namespace to be ready
    kubectl wait --for=condition=Ready namespace/banking-app --timeout=60s
    
    print_success "Kubernetes setup completed"
}

# Build and deploy applications
build_applications() {
    print_status "Building application containers..."
    
    # Build backend
    print_status "Building backend application..."
    cd backend
    docker build -t banking-app-backend:latest .
    cd ..
    
    # Build frontend
    print_status "Building frontend application..."
    cd frontend
    docker build -t banking-app-frontend:latest .
    cd ..
    
    print_success "Application containers built successfully"
}

# Setup monitoring and logging
setup_monitoring() {
    print_status "Setting up monitoring and logging..."
    
    # Create logs directory
    mkdir -p logs
    
    # Setup basic monitoring (can be expanded later)
    print_status "Monitoring setup completed"
}

# Security checks
security_checks() {
    print_status "Running security checks..."
    
    # Check for secrets in code
    if grep -r "password\|secret\|key" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bin --exclude-dir=obj --exclude-dir=logs; then
        print_warning "Potential secrets found in code. Please review."
    fi
    
    # Check for hardcoded URLs
    if grep -r "http://" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bin --exclude-dir=obj --exclude-dir=logs; then
        print_warning "HTTP URLs found in code. Consider using HTTPS."
    fi
    
    print_success "Security checks completed"
}

# Main setup function
main() {
    echo "Starting setup process..."
    
    check_prerequisites
    setup_aws
    setup_terraform
    setup_kubernetes
    build_applications
    setup_monitoring
    security_checks
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "1. Complete the backend application development"
    echo "2. Complete the frontend application development"
    echo "3. Configure SSL certificates for production"
    echo "4. Set up monitoring and alerting"
    echo "5. Conduct security testing"
    echo ""
    echo "For more information, see:"
    echo "- README.md for project overview"
    echo "- PROJECT_STRUCTURE.md for architecture details"
    echo "- plan.txt for development phases"
    echo ""
    echo "To access the application:"
    echo "- Backend API: https://api.banking-app.example.com"
    echo "- Frontend: https://www.banking-app.example.com"
    echo "- Kubernetes Dashboard: kubectl proxy"
    echo ""
}

# Run main function
main "$@" 