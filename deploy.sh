#!/bin/bash

# Deployment script for erlacher-advisory website
# This script follows the proper Git workflow for GitHub Pages deployment

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

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

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from the project root."
    exit 1
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
print_status "Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes. Please commit them first or stash them."
    echo "To commit changes:"
    echo "  git add ."
    echo "  git commit -m 'your commit message'"
    echo "To stash changes:"
    echo "  git stash"
    exit 1
fi

# Check if we're on main branch
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "You're not on the main branch. Switching to main..."
    git checkout main
fi

# Check if gh-pages branch exists
if ! git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
    print_error "gh-pages branch does not exist on remote. Please create it first."
    exit 1
fi

# Step 1: Push main branch
print_status "Step 1: Pushing main branch..."
git push origin main
print_success "Main branch pushed successfully"

# Step 2: Switch to gh-pages branch
print_status "Step 2: Switching to gh-pages branch..."
git checkout gh-pages
print_success "Switched to gh-pages branch"

# Step 3: Merge main into gh-pages
print_status "Step 3: Merging main into gh-pages..."
git merge main
print_success "Merged main into gh-pages"

# Step 4: Push gh-pages branch
print_status "Step 4: Pushing gh-pages branch..."
git push origin gh-pages
print_success "gh-pages branch pushed successfully"

# Step 5: Switch back to main branch
print_status "Step 5: Switching back to main branch..."
git checkout main
print_success "Switched back to main branch"

# Final status
print_success "🎉 Deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "  ✅ Main branch: Updated and pushed"
echo "  ✅ gh-pages branch: Merged and deployed"
echo "  ✅ GitHub Pages: Deployment triggered"
echo ""
echo "🌐 Your website should be live in a few minutes at:"
echo "   https://sepp-ai.github.io/erlacher-advisory/"
echo ""
echo "⏱️  Deployment typically takes 2-5 minutes to propagate." 