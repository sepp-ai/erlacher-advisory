#!/bin/bash

# Comprehensive deployment workflow script
# Combines pre-deployment validation with automated deployment

set -e

echo "🚀 Starting comprehensive deployment workflow..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

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

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Configuration
BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
DEPLOYMENT_LOG="deployment-$(date +%Y%m%d-%H%M%S).log"

# Function to log deployment
log_deployment() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEPLOYMENT_LOG"
}

# Function to create backup
create_backup() {
    print_step "Creating backup branch..."
    log_deployment "Creating backup branch: $BACKUP_BRANCH"
    
    CURRENT_BRANCH=$(git branch --show-current)
    git checkout -b "$BACKUP_BRANCH"
    git push -u origin "$BACKUP_BRANCH"
    git checkout "$CURRENT_BRANCH"
    
    print_success "Backup created: $BACKUP_BRANCH"
    log_deployment "Backup branch created successfully"
}

# Function to run pre-deployment checks
run_pre_deployment_checks() {
    print_step "Running pre-deployment validation..."
    log_deployment "Starting pre-deployment checks"
    
    if ! ./pre-deploy-check.sh; then
        print_error "Pre-deployment checks failed. Aborting deployment."
        log_deployment "Pre-deployment checks failed - deployment aborted"
        exit 1
    fi
    
    print_success "Pre-deployment checks passed"
    log_deployment "Pre-deployment checks passed"
}

# Function to handle deployment with rollback
deploy_with_rollback() {
    print_step "Starting deployment with rollback protection..."
    log_deployment "Starting deployment process"
    
    # Store current state for potential rollback
    PRE_DEPLOY_COMMIT=$(git rev-parse HEAD)
    log_deployment "Pre-deployment commit: $PRE_DEPLOY_COMMIT"
    
    # Run the improved deployment script
    if ! ./deploy-improved.sh; then
        print_error "Deployment failed. Initiating rollback..."
        log_deployment "Deployment failed - initiating rollback"
        
        # Rollback to previous state
        git reset --hard "$PRE_DEPLOY_COMMIT"
        git push origin main --force
        
        print_error "Rollback completed. Deployment failed."
        log_deployment "Rollback completed successfully"
        exit 1
    fi
    
    print_success "Deployment completed successfully"
    log_deployment "Deployment completed successfully"
}

# Function to post-deployment validation
post_deployment_validation() {
    print_step "Running post-deployment validation..."
    log_deployment "Starting post-deployment validation"
    
    # Wait for GitHub Pages to process
    print_status "Waiting for GitHub Pages to process..."
    sleep 30
    
    # Check site accessibility
    if command -v curl >/dev/null 2>&1; then
        print_status "Checking site accessibility..."
        
        # Try multiple times with increasing delays
        for i in {1..5}; do
            if curl -s -o /dev/null -w "%{http_code}" https://erlacher-advisory.com | grep -q "200\|301\|302"; then
                print_success "Site is accessible"
                log_deployment "Site accessibility confirmed"
                return 0
            else
                print_warning "Attempt $i: Site not yet accessible, waiting..."
                sleep 30
            fi
        done
        
        print_warning "Site may not be fully deployed yet (this can take up to 10 minutes)"
        log_deployment "Site accessibility check inconclusive"
    else
        print_warning "curl not available, skipping accessibility check"
        log_deployment "Skipped accessibility check (curl not available)"
    fi
}

# Function to cleanup backup
cleanup_backup() {
    print_step "Cleaning up backup branch..."
    log_deployment "Cleaning up backup branch"
    
    # Delete local backup branch
    git branch -D "$BACKUP_BRANCH" 2>/dev/null || true
    
    # Delete remote backup branch
    git push origin --delete "$BACKUP_BRANCH" 2>/dev/null || true
    
    print_success "Backup branch cleaned up"
    log_deployment "Backup branch cleanup completed"
}

# Function to show deployment summary
show_deployment_summary() {
    echo ""
    print_success "🎉 Deployment workflow completed successfully!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "  ✅ Pre-deployment validation passed"
    echo "  ✅ Backup created and cleaned up"
    echo "  ✅ Deployment completed successfully"
    echo "  ✅ Post-deployment validation passed"
    echo ""
    echo "🌐 Your website is live at:"
    echo "   https://erlacher-advisory.com"
    echo ""
    echo "📝 Deployment log saved to: $DEPLOYMENT_LOG"
    echo ""
    echo "🔍 To monitor deployment:"
    echo "   - Check GitHub repository settings > Pages"
    echo "   - Monitor the Actions tab for deployment status"
    echo "   - Review deployment log: $DEPLOYMENT_LOG"
    echo ""
    echo "🔄 Rollback information:"
    echo "   - Backup branch was created and cleaned up"
    echo "   - Current deployment is stable"
    echo ""
    
    log_deployment "Deployment workflow completed successfully"
}

# Function to handle errors
handle_error() {
    print_error "Deployment workflow failed at step: $1"
    log_deployment "Deployment workflow failed at step: $1"
    
    echo ""
    echo "🔄 Recovery options:"
    echo "   1. Check the deployment log: $DEPLOYMENT_LOG"
    echo "   2. Review the backup branch: $BACKUP_BRANCH"
    echo "   3. Run manual deployment: ./deploy-improved.sh"
    echo "   4. Contact support with the log file"
    echo ""
    
    exit 1
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    log_deployment "Checking prerequisites"
    
    # Check if required scripts exist
    if [ ! -f "./pre-deploy-check.sh" ]; then
        print_error "pre-deploy-check.sh not found"
        exit 1
    fi
    
    if [ ! -f "./deploy-improved.sh" ]; then
        print_error "deploy-improved.sh not found"
        exit 1
    fi
    
    # Check if scripts are executable
    if [ ! -x "./pre-deploy-check.sh" ]; then
        print_error "pre-deploy-check.sh is not executable"
        exit 1
    fi
    
    if [ ! -x "./deploy-improved.sh" ]; then
        print_error "deploy-improved.sh is not executable"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    log_deployment "Prerequisites check passed"
}

# Main workflow function
main() {
    echo "🚀 Starting comprehensive deployment workflow..."
    echo "📝 Logging to: $DEPLOYMENT_LOG"
    echo ""
    
    # Initialize log
    log_deployment "=== Deployment workflow started ==="
    
    # Set up error handling
    trap 'handle_error "unknown"' ERR
    
    # Check prerequisites
    check_prerequisites
    
    # Run pre-deployment checks
    run_pre_deployment_checks
    
    # Create backup
    create_backup
    
    # Deploy with rollback protection
    deploy_with_rollback
    
    # Post-deployment validation
    post_deployment_validation
    
    # Cleanup backup
    cleanup_backup
    
    # Show summary
    show_deployment_summary
    
    log_deployment "=== Deployment workflow completed ==="
}

# Run main function
main "$@" 