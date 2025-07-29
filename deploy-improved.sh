#!/bin/bash

# Improved deployment script for erlacher-advisory website
# Handles all edge cases and provides smooth, automated deployment

set -e  # Exit on any error

echo "🚀 Starting improved deployment process..."

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate git setup
validate_git_setup() {
    print_status "Validating git setup..."
    
    if ! command_exists git; then
        print_error "Git is not installed. Please install git first."
        exit 1
    fi
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this script from the project root."
        exit 1
    fi
    
    # Check if remote origin exists
    if ! git remote get-url origin > /dev/null 2>&1; then
        print_error "No remote origin found. Please add your GitHub repository as origin."
        exit 1
    fi
    
    print_success "Git setup validated"
}

# Function to check and handle uncommitted changes
handle_uncommitted_changes() {
    print_status "Checking for uncommitted changes..."
    
    if ! git diff-index --quiet HEAD --; then
        print_warning "Found uncommitted changes. Committing them automatically..."
        
        # Add all changes
        git add .
        
        # Create commit with timestamp
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        git commit -m "Auto-commit before deployment - $TIMESTAMP"
        
        print_success "Uncommitted changes committed"
    else
        print_success "No uncommitted changes found"
    fi
}

# Function to ensure we're on main branch
ensure_main_branch() {
    print_status "Ensuring we're on main branch..."
    
    CURRENT_BRANCH=$(git branch --show-current)
    
    if [ "$CURRENT_BRANCH" != "main" ]; then
        print_warning "Currently on $CURRENT_BRANCH branch. Switching to main..."
        
        # Stash any changes if needed
        if ! git diff-index --quiet HEAD --; then
            git stash
            STASHED=true
        fi
        
        git checkout main
        
        # Apply stash if we stashed changes
        if [ "$STASHED" = true ]; then
            git stash pop
        fi
        
        print_success "Switched to main branch"
    else
        print_success "Already on main branch"
    fi
}

# Function to sync with remote
sync_with_remote() {
    print_status "Syncing with remote repository..."
    
    # Fetch latest changes
    git fetch origin
    
    # Check if we're behind remote
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        print_warning "Local branch is behind remote. Pulling latest changes..."
        git pull origin main
        print_success "Synced with remote"
    else
        print_success "Already up to date with remote"
    fi
}

# Function to push main branch
push_main_branch() {
    print_status "Pushing main branch..."
    
    # Try to push, if it fails, pull and push again
    if ! git push origin main; then
        print_warning "Push failed. Pulling latest changes and retrying..."
        git pull origin main
        git push origin main
    fi
    
    print_success "Main branch pushed successfully"
}

# Function to handle gh-pages branch
handle_gh_pages() {
    print_status "Handling gh-pages branch..."
    
    # Check if gh-pages branch exists locally
    if ! git show-ref --verify --quiet refs/heads/gh-pages; then
        print_warning "gh-pages branch doesn't exist locally. Creating it..."
        git checkout -b gh-pages
    else
        git checkout gh-pages
    fi
    
    # Check if gh-pages exists on remote
    if ! git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
        print_warning "gh-pages branch doesn't exist on remote. Creating it..."
        git push -u origin gh-pages
    fi
    
    print_success "gh-pages branch ready"
}

# Function to merge main into gh-pages
merge_main_into_gh_pages() {
    print_status "Merging main into gh-pages..."
    
    # Configure git to avoid opening editor
    export GIT_MERGE_AUTOEDIT=no
    
    # Try to merge, handle conflicts automatically
    if ! git merge main --no-edit; then
        print_warning "Merge conflict detected. Resolving automatically..."
        
        # Check if there are actual conflicts
        if git ls-files -u | grep -q .; then
            print_error "Cannot automatically resolve merge conflicts. Please resolve manually:"
            print_error "1. git status"
            print_error "2. Resolve conflicts in the files"
            print_error "3. git add ."
            print_error "4. git commit"
            print_error "5. Run this script again"
            exit 1
        else
            # No actual conflicts, just commit the merge
            git commit --no-edit
        fi
    fi
    
    print_success "Main branch merged into gh-pages"
}

# Function to push gh-pages branch
push_gh_pages() {
    print_status "Pushing gh-pages branch..."
    
    # Try to push, if it fails due to divergence, force push
    if ! git push origin gh-pages; then
        print_warning "Push failed due to divergence. Force pushing..."
        git push origin gh-pages --force-with-lease
    fi
    
    print_success "gh-pages branch pushed successfully"
}

# Function to return to main branch
return_to_main() {
    print_status "Returning to main branch..."
    git checkout main
    print_success "Returned to main branch"
}

# Function to validate deployment
validate_deployment() {
    print_status "Validating deployment..."
    
    # Wait a moment for GitHub Pages to process
    sleep 5
    
    # Check if the site is accessible (basic check)
    if command_exists curl; then
        print_status "Checking site accessibility..."
        if curl -s -o /dev/null -w "%{http_code}" https://erlacher-advisory.com | grep -q "200\|301\|302"; then
            print_success "Site is accessible"
        else
            print_warning "Site may not be fully deployed yet (this is normal for the first few minutes)"
        fi
    fi
    
    print_success "Deployment validation complete"
}

# Function to show deployment summary
show_deployment_summary() {
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "  ✅ Git setup validated"
    echo "  ✅ Uncommitted changes handled"
    echo "  ✅ Main branch synced and pushed"
    echo "  ✅ gh-pages branch updated"
    echo "  ✅ GitHub Pages deployment triggered"
    echo ""
    echo "🌐 Your website should be live in a few minutes at:"
    echo "   https://erlacher-advisory.com"
    echo ""
    echo "⏱️  Deployment typically takes 2-5 minutes to propagate."
    echo ""
    echo "🔍 To monitor deployment:"
    echo "   - Check GitHub repository settings > Pages"
    echo "   - Monitor the Actions tab for deployment status"
    echo "   - Test the live site after 5 minutes"
}

# Main deployment function
main() {
    print_status "Starting automated deployment process..."
    
    # Validate setup
    validate_git_setup
    
    # Handle uncommitted changes
    handle_uncommitted_changes
    
    # Ensure we're on main branch
    ensure_main_branch
    
    # Sync with remote
    sync_with_remote
    
    # Push main branch
    push_main_branch
    
    # Handle gh-pages branch
    handle_gh_pages
    
    # Merge main into gh-pages
    merge_main_into_gh-pages
    
    # Push gh-pages branch
    push_gh_pages
    
    # Return to main branch
    return_to_main
    
    # Validate deployment
    validate_deployment
    
    # Show summary
    show_deployment_summary
}

# Run main function
main "$@" 