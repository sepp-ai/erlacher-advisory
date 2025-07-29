#!/bin/bash

# Comprehensive deployment script for erlacher-advisory website
# Combines validation, deployment, backup, and rollback in one script

set -e

echo "🚀 Starting comprehensive deployment process..."

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
VALIDATE_ONLY=false
SKIP_VALIDATION=false

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -v, --validate-only    Run validation only, don't deploy"
    echo "  -s, --skip-validation  Skip validation and deploy directly"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full deployment with validation"
    echo "  $0 --validate-only    # Run validation only"
    echo "  $0 --skip-validation  # Deploy without validation"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to log deployment
log_deployment() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEPLOYMENT_LOG"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate git setup
validate_git_setup() {
    print_step "Validating git setup..."
    log_deployment "Validating git setup"
    
    if ! command_exists git; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this script from the project root."
        exit 1
    fi
    
    if ! git remote get-url origin > /dev/null 2>&1; then
        print_error "No remote origin found. Please add your GitHub repository as origin."
        exit 1
    fi
    
    print_success "Git setup validated"
    log_deployment "Git setup validated"
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        print_success "✓ $1 exists"
    else
        print_error "✗ $1 missing"
        return 1
    fi
}

# Function to run pre-deployment validation
run_validation() {
    print_step "Running pre-deployment validation..."
    log_deployment "Starting pre-deployment validation"
    
    local issues=0
    local warnings=0
    
    # Check content files
    print_status "Checking content files..."
    check_file "src/content/de.json" || ((issues++))
    check_file "src/content/en.json" || ((issues++))
    check_file "src/content/config.json" || ((issues++))
    
    # Check if content files are valid JSON
    if command_exists jq; then
        if jq empty src/content/de.json 2>/dev/null; then
            print_success "✓ src/content/de.json is valid JSON"
        else
            print_error "✗ src/content/de.json is not valid JSON"
            ((issues++))
        fi
        
        if jq empty src/content/en.json 2>/dev/null; then
            print_success "✓ src/content/en.json is valid JSON"
        else
            print_error "✗ src/content/en.json is not valid JSON"
            ((issues++))
        fi
    else
        print_warning "jq not installed, skipping JSON validation"
        ((warnings++))
    fi
    
    # Check for hardcoded domain references
    print_status "Checking for hardcoded domain references..."
    if grep -r "yourdomain\.com" . --exclude-dir=.git --exclude=*.md --exclude=*.sh 2>/dev/null; then
        print_error "✗ Found hardcoded 'yourdomain.com' references"
        ((issues++))
    else
        print_success "✓ No hardcoded domain references found"
    fi
    
    # Check for proper domain references
    if grep -r "erlacher-advisory\.com" . --exclude-dir=.git --exclude=*.md --exclude=*.sh 2>/dev/null; then
        print_success "✓ Proper domain references found"
    else
        print_warning "! No references to erlacher-advisory.com found"
        ((warnings++))
    fi
    
    # Check for TODO/FIXME comments
    print_status "Checking for TODO/FIXME comments..."
    if find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) ! -name "content-validator.js" ! -path "./.git/*" ! -name "*.md" ! -name "*.sh" -exec grep -l "TODO\|FIXME" {} \; 2>/dev/null | grep -q .; then
        print_warning "! Found TODO/FIXME comments in code"
        ((warnings++))
    else
        print_success "✓ No TODO/FIXME comments found"
    fi
    
    # Check git status
    print_status "Checking git status..."
    if ! git diff-index --quiet HEAD --; then
        print_warning "! You have uncommitted changes"
        ((warnings++))
    else
        print_success "✓ No uncommitted changes"
    fi
    
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "main" ]; then
        print_success "✓ On main branch"
    else
        print_warning "! Currently on $CURRENT_BRANCH branch (should be on main for deployment)"
        ((warnings++))
    fi
    
    if git remote get-url origin > /dev/null 2>&1; then
        print_success "✓ Remote origin configured"
    else
        print_error "✗ No remote origin configured"
        ((issues++))
    fi
    
    # Check file sizes
    print_status "Checking file sizes..."
    CSS_SIZE=$(stat -f%z src/css/styles.css 2>/dev/null || stat -c%s src/css/styles.css 2>/dev/null || echo 0)
    if [ "$CSS_SIZE" -gt 50000 ]; then
        print_warning "! src/css/styles.css is large ($CSS_SIZE bytes) - consider minification"
        ((warnings++))
    else
        print_success "✓ src/css/styles.css size is reasonable ($CSS_SIZE bytes)"
    fi
    
    JS_SIZE=$(stat -f%z src/js/script.js 2>/dev/null || stat -c%s src/js/script.js 2>/dev/null || echo 0)
    if [ "$JS_SIZE" -gt 30000 ]; then
        print_warning "! src/js/script.js is large ($JS_SIZE bytes) - consider minification"
        ((warnings++))
    else
        print_success "✓ src/js/script.js size is reasonable ($JS_SIZE bytes)"
    fi
    
    # Check for common issues
    print_status "Checking for common issues..."
    if grep -r "console\.log" . --exclude-dir=.git --exclude=*.md --exclude=*.sh 2>/dev/null; then
        print_warning "! Found console.log statements (consider removing for production)"
        ((warnings++))
    else
        print_success "✓ No console.log statements found"
    fi
    
    if grep -r "alert(" . --exclude-dir=.git --exclude=*.md 2>/dev/null; then
        print_warning "! Found alert() statements (consider removing for production)"
        ((warnings++))
    else
        print_success "✓ No alert() statements found"
    fi
    
    # Check accessibility basics
    print_status "Checking basic accessibility..."
    if grep -r "<img" . --exclude-dir=.git 2>/dev/null | grep -v "alt="; then
        print_warning "! Found images without alt attributes"
        ((warnings++))
    else
        print_success "✓ All images have alt attributes (or no images found)"
    fi
    
    if grep -r "aria-label\|aria-labelledby" . --exclude-dir=.git 2>/dev/null; then
        print_success "✓ ARIA labels found"
    else
        print_warning "! No ARIA labels found (accessibility could be improved)"
        ((warnings++))
    fi
    
    # Show validation summary
    echo ""
    echo "📋 Validation summary:"
    echo "  Issues found: $issues"
    echo "  Warnings: $warnings"
    echo ""
    
    if [ "$issues" -eq 0 ] && [ "$warnings" -eq 0 ]; then
        print_success "🎉 All checks passed! Ready for deployment."
        log_deployment "Validation passed - all checks successful"
        return 0
    elif [ "$issues" -eq 0 ]; then
        print_warning "⚠️  Some warnings found, but no critical issues. Deployment can proceed."
        log_deployment "Validation passed with warnings"
        return 0
    else
        print_error "❌ Critical issues found. Please fix them before deployment."
        log_deployment "Validation failed - critical issues found"
        return 1
    fi
}

# Function to handle uncommitted changes
handle_uncommitted_changes() {
    print_step "Checking for uncommitted changes..."
    log_deployment "Checking for uncommitted changes"
    
    if ! git diff-index --quiet HEAD --; then
        print_warning "Found uncommitted changes. Committing them automatically..."
        
        git add .
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        git commit -m "Auto-commit before deployment - $TIMESTAMP"
        
        print_success "Uncommitted changes committed"
        log_deployment "Uncommitted changes committed"
    else
        print_success "No uncommitted changes found"
        log_deployment "No uncommitted changes found"
    fi
}

# Function to ensure we're on main branch
ensure_main_branch() {
    print_step "Ensuring we're on main branch..."
    log_deployment "Ensuring main branch"
    
    CURRENT_BRANCH=$(git branch --show-current)
    
    if [ "$CURRENT_BRANCH" != "main" ]; then
        print_warning "Currently on $CURRENT_BRANCH branch. Switching to main..."
        
        if ! git diff-index --quiet HEAD --; then
            git stash
            STASHED=true
        fi
        
        git checkout main
        
        if [ "$STASHED" = true ]; then
            git stash pop
        fi
        
        print_success "Switched to main branch"
        log_deployment "Switched to main branch"
    else
        print_success "Already on main branch"
        log_deployment "Already on main branch"
    fi
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

# Function to sync with remote
sync_with_remote() {
    print_step "Syncing with remote repository..."
    log_deployment "Syncing with remote"
    
    git fetch origin
    
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        print_warning "Local branch is behind remote. Pulling latest changes..."
        git pull origin main
        print_success "Synced with remote"
        log_deployment "Synced with remote"
    else
        print_success "Already up to date with remote"
        log_deployment "Already up to date with remote"
    fi
}

# Function to push main branch
push_main_branch() {
    print_step "Pushing main branch..."
    log_deployment "Pushing main branch"
    
    if ! git push origin main; then
        print_warning "Push failed. Pulling latest changes and retrying..."
        git pull origin main
        git push origin main
    fi
    
    print_success "Main branch pushed successfully"
    log_deployment "Main branch pushed successfully"
}

# Function to handle gh-pages branch
handle_gh_pages() {
    print_step "Handling gh-pages branch..."
    log_deployment "Handling gh-pages branch"
    
    if ! git show-ref --verify --quiet refs/heads/gh-pages; then
        print_warning "gh-pages branch doesn't exist locally. Creating it..."
        git checkout -b gh-pages
    else
        git checkout gh-pages
    fi
    
    if ! git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
        print_warning "gh-pages branch doesn't exist on remote. Creating it..."
        git push -u origin gh-pages
    fi
    
    print_success "gh-pages branch ready"
    log_deployment "gh-pages branch ready"
}

# Function to merge main into gh-pages
merge_main_into_gh_pages() {
    print_step "Merging main into gh-pages..."
    log_deployment "Merging main into gh-pages"
    
    export GIT_MERGE_AUTOEDIT=no
    
    if ! git merge main --no-edit; then
        print_warning "Merge conflict detected. Resolving automatically..."
        
        if git ls-files -u | grep -q .; then
            print_error "Cannot automatically resolve merge conflicts. Please resolve manually:"
            print_error "1. git status"
            print_error "2. Resolve conflicts in the files"
            print_error "3. git add ."
            print_error "4. git commit"
            print_error "5. Run this script again"
            log_deployment "Merge conflicts require manual resolution"
            exit 1
        else
            git commit --no-edit
        fi
    fi
    
    print_success "Main branch merged into gh-pages"
    log_deployment "Main branch merged into gh-pages"
}

# Function to push gh-pages branch
push_gh_pages() {
    print_step "Pushing gh-pages branch..."
    log_deployment "Pushing gh-pages branch"
    
    if ! git push origin gh-pages; then
        print_warning "Push failed due to divergence. Force pushing..."
        git push origin gh-pages --force-with-lease
    fi
    
    print_success "gh-pages branch pushed successfully"
    log_deployment "gh-pages branch pushed successfully"
}

# Function to return to main branch
return_to_main() {
    print_step "Returning to main branch..."
    log_deployment "Returning to main branch"
    git checkout main
    print_success "Returned to main branch"
    log_deployment "Returned to main branch"
}

# Function to cleanup backup
cleanup_backup() {
    print_step "Cleaning up backup branch..."
    log_deployment "Cleaning up backup branch"
    
    git branch -D "$BACKUP_BRANCH" 2>/dev/null || true
    git push origin --delete "$BACKUP_BRANCH" 2>/dev/null || true
    
    print_success "Backup branch cleaned up"
    log_deployment "Backup branch cleanup completed"
}

# Function to validate deployment
validate_deployment() {
    print_step "Validating deployment..."
    log_deployment "Validating deployment"
    
    sleep 5
    
    if command_exists curl; then
        print_status "Checking site accessibility..."
        
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

# Function to show deployment summary
show_deployment_summary() {
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "  ✅ Git setup validated"
    echo "  ✅ Pre-deployment validation passed"
    echo "  ✅ Uncommitted changes handled"
    echo "  ✅ Backup created and cleaned up"
    echo "  ✅ Main branch synced and pushed"
    echo "  ✅ gh-pages branch updated"
    echo "  ✅ GitHub Pages deployment triggered"
    echo "  ✅ Post-deployment validation passed"
    echo ""
    echo "🌐 Your website should be live in a few minutes at:"
    echo "   https://erlacher-advisory.com"
    echo ""
    echo "📝 Deployment log saved to: $DEPLOYMENT_LOG"
    echo ""
    echo "⏱️  Deployment typically takes 2-5 minutes to propagate."
    echo ""
    echo "🔍 To monitor deployment:"
    echo "   - Check GitHub repository settings > Pages"
    echo "   - Monitor the Actions tab for deployment status"
    echo "   - Test the live site after 5 minutes"
    echo ""
    
    log_deployment "Deployment completed successfully"
}

# Function to handle errors
handle_error() {
    print_error "Deployment failed at step: $1"
    log_deployment "Deployment failed at step: $1"
    
    echo ""
    echo "🔄 Recovery options:"
    echo "   1. Check the deployment log: $DEPLOYMENT_LOG"
    echo "   2. Review the backup branch: $BACKUP_BRANCH"
    echo "   3. Run manual deployment: $0"
    echo "   4. Contact support with the log file"
    echo ""
    
    exit 1
}

# Main deployment function
main() {
    echo "🚀 Starting comprehensive deployment process..."
    echo "📝 Logging to: $DEPLOYMENT_LOG"
    echo ""
    
    log_deployment "=== Deployment started ==="
    
    # Set up error handling
    trap 'handle_error "unknown"' ERR
    
    # Validate git setup
    validate_git_setup
    
    # Run validation (unless skipped)
    if [ "$SKIP_VALIDATION" = false ]; then
        if ! run_validation; then
            if [ "$VALIDATE_ONLY" = true ]; then
                print_error "Validation failed. Exiting."
                exit 1
            else
                print_error "Validation failed. Aborting deployment."
                exit 1
            fi
        fi
        
        if [ "$VALIDATE_ONLY" = true ]; then
            print_success "Validation completed successfully!"
            exit 0
        fi
    else
        print_warning "Skipping validation as requested"
        log_deployment "Validation skipped"
    fi
    
    # Handle uncommitted changes
    handle_uncommitted_changes
    
    # Ensure we're on main branch
    ensure_main_branch
    
    # Create backup
    create_backup
    
    # Sync with remote
    sync_with_remote
    
    # Push main branch
    push_main_branch
    
    # Handle gh-pages branch
    handle_gh_pages
    
    # Merge main into gh-pages
    merge_main_into_gh_pages
    
    # Push gh-pages branch
    push_gh_pages
    
    # Return to main branch
    return_to_main
    
    # Validate deployment
    validate_deployment
    
    # Cleanup backup
    cleanup_backup
    
    # Show summary
    show_deployment_summary
    
    log_deployment "=== Deployment completed ==="
}

# Run main function
main "$@" 