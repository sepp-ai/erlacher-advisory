#!/bin/bash

# Pre-deployment validation script
# Checks for common issues before deployment

set -e

echo "🔍 Running pre-deployment checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Track issues
ISSUES=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        print_success "✓ $1 exists"
    else
        print_error "✗ $1 missing"
        ((ISSUES++))
    fi
}

# Function to check content files
check_content_files() {
    print_status "Checking content files..."
    
    check_file "content/de.json"
    check_file "content/en.json"
    check_file "content/config.json"
    
    # Check if content files are valid JSON
    if command -v jq >/dev/null 2>&1; then
        if jq empty content/de.json 2>/dev/null; then
            print_success "✓ content/de.json is valid JSON"
        else
            print_error "✗ content/de.json is not valid JSON"
            ((ISSUES++))
        fi
        
        if jq empty content/en.json 2>/dev/null; then
            print_success "✓ content/en.json is valid JSON"
        else
            print_error "✗ content/en.json is not valid JSON"
            ((ISSUES++))
        fi
    else
        print_warning "jq not installed, skipping JSON validation"
        ((WARNINGS++))
    fi
}

# Function to check for hardcoded domain references
check_domain_references() {
    print_status "Checking for hardcoded domain references..."
    
    # Check for yourdomain.com references (excluding script files and documentation)
    if grep -r "yourdomain\.com" . --exclude-dir=.git --exclude=*.md --exclude=*.sh 2>/dev/null; then
        print_error "✗ Found hardcoded 'yourdomain.com' references"
        ((ISSUES++))
    else
        print_success "✓ No hardcoded domain references found"
    fi
    
    # Check for proper domain references (excluding script files and documentation)
    if grep -r "erlacher-advisory\.com" . --exclude-dir=.git --exclude=*.md --exclude=*.sh 2>/dev/null; then
        print_success "✓ Proper domain references found"
    else
        print_warning "! No references to erlacher-advisory.com found"
        ((WARNINGS++))
    fi
}

# Function to check for TODO/FIXME comments
check_todos() {
    print_status "Checking for TODO/FIXME comments..."
    
    # Use find to exclude specific files and then grep
    if find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) ! -name "content-validator.js" ! -path "./.git/*" ! -name "*.md" ! -name "*.sh" -exec grep -l "TODO\|FIXME" {} \; 2>/dev/null | grep -q .; then
        print_warning "! Found TODO/FIXME comments in code"
        ((WARNINGS++))
    else
        print_success "✓ No TODO/FIXME comments found"
    fi
}

# Function to check git status
check_git_status() {
    print_status "Checking git status..."
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "✗ Not in a git repository"
        ((ISSUES++))
        return
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "! You have uncommitted changes"
        ((WARNINGS++))
    else
        print_success "✓ No uncommitted changes"
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "main" ]; then
        print_success "✓ On main branch"
    else
        print_warning "! Currently on $CURRENT_BRANCH branch (should be on main for deployment)"
        ((WARNINGS++))
    fi
    
    # Check if remote is configured
    if git remote get-url origin > /dev/null 2>&1; then
        print_success "✓ Remote origin configured"
    else
        print_error "✗ No remote origin configured"
        ((ISSUES++))
    fi
}

# Function to check file sizes
check_file_sizes() {
    print_status "Checking file sizes..."
    
    # Check CSS file size
    CSS_SIZE=$(stat -f%z styles.css 2>/dev/null || stat -c%s styles.css 2>/dev/null || echo 0)
    if [ "$CSS_SIZE" -gt 50000 ]; then
        print_warning "! styles.css is large ($CSS_SIZE bytes) - consider minification"
        ((WARNINGS++))
    else
        print_success "✓ styles.css size is reasonable ($CSS_SIZE bytes)"
    fi
    
    # Check JS file size
    JS_SIZE=$(stat -f%z script.js 2>/dev/null || stat -c%s script.js 2>/dev/null || echo 0)
    if [ "$JS_SIZE" -gt 30000 ]; then
        print_warning "! script.js is large ($JS_SIZE bytes) - consider minification"
        ((WARNINGS++))
    else
        print_success "✓ script.js size is reasonable ($JS_SIZE bytes)"
    fi
}

# Function to check for common issues
check_common_issues() {
    print_status "Checking for common issues..."
    
    # Check for console.log statements
    if grep -r "console\.log" . --exclude-dir=.git --exclude=*.md 2>/dev/null; then
        print_warning "! Found console.log statements (consider removing for production)"
        ((WARNINGS++))
    else
        print_success "✓ No console.log statements found"
    fi
    
    # Check for alert statements
    if grep -r "alert(" . --exclude-dir=.git --exclude=*.md 2>/dev/null; then
        print_warning "! Found alert() statements (consider removing for production)"
        ((WARNINGS++))
    else
        print_success "✓ No alert() statements found"
    fi
}

# Function to check accessibility basics
check_accessibility() {
    print_status "Checking basic accessibility..."
    
    # Check for alt attributes on images
    if grep -r "<img" . --exclude-dir=.git 2>/dev/null | grep -v "alt="; then
        print_warning "! Found images without alt attributes"
        ((WARNINGS++))
    else
        print_success "✓ All images have alt attributes (or no images found)"
    fi
    
    # Check for ARIA labels
    if grep -r "aria-label\|aria-labelledby" . --exclude-dir=.git 2>/dev/null; then
        print_success "✓ ARIA labels found"
    else
        print_warning "! No ARIA labels found (accessibility could be improved)"
        ((WARNINGS++))
    fi
}

# Function to show summary
show_summary() {
    echo ""
    echo "📋 Pre-deployment check summary:"
    echo "  Issues found: $ISSUES"
    echo "  Warnings: $WARNINGS"
    echo ""
    
    if [ "$ISSUES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        print_success "🎉 All checks passed! Ready for deployment."
        exit 0
    elif [ "$ISSUES" -eq 0 ]; then
        print_warning "⚠️  Some warnings found, but no critical issues. Deployment can proceed."
        exit 0
    else
        print_error "❌ Critical issues found. Please fix them before deployment."
        exit 1
    fi
}

# Main function
main() {
    echo "🔍 Starting pre-deployment validation..."
    echo ""
    
    check_content_files
    echo ""
    
    check_domain_references
    echo ""
    
    check_todos
    echo ""
    
    check_git_status
    echo ""
    
    check_file_sizes
    echo ""
    
    check_common_issues
    echo ""
    
    check_accessibility
    echo ""
    
    show_summary
}

# Run main function
main "$@" 