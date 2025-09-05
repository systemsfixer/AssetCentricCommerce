#!/bin/bash

# Quick Commit Script for AssetCentricCommerce
# Usage: ./scripts/quick-commit.sh "Your commit message"
# Or run without message for interactive prompt

set -e  # Exit on any error

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
    print_error "Not in a git repository!"
    exit 1
fi

# Check if we're in the correct repository
REPO_NAME=$(basename `git rev-parse --show-toplevel`)
if [ "$REPO_NAME" != "AssetCentricCommerce2" ] && [ "$REPO_NAME" != "AssetCentricCommerce" ]; then
    print_warning "Repository name is '$REPO_NAME', expected 'AssetCentricCommerce' or 'AssetCentricCommerce2'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "Currently on branch '$CURRENT_BRANCH', not 'main'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
fi

# Check for uncommitted changes (both tracked and untracked)
if git diff-index --quiet HEAD -- && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    print_warning "No changes detected to commit"
    exit 0
fi

# Show current status
print_status "Current git status:"
git status --short

echo

# Get commit message
COMMIT_MESSAGE=""
if [ $# -eq 0 ]; then
    echo "Enter commit message (or press Ctrl+C to cancel):"
    read -r COMMIT_MESSAGE
    if [ -z "$COMMIT_MESSAGE" ]; then
        print_error "Commit message cannot be empty"
        exit 1
    fi
else
    COMMIT_MESSAGE="$*"
fi

print_status "Commit message: '$COMMIT_MESSAGE'"
echo

# Confirm before proceeding
read -p "Proceed with staging, committing, and pushing? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_error "Aborted by user"
    exit 1
fi

# Stage all changes
print_status "Staging all changes..."
git add .

# Show what will be committed
print_status "Files to be committed:"
git diff --cached --name-status

echo

# Commit changes
print_status "Committing changes..."
git commit -m "$COMMIT_MESSAGE"

# Push to remote
print_status "Pushing to remote repository..."
git push origin "$CURRENT_BRANCH"

print_success "Successfully committed and pushed changes!"
print_success "Commit: $(git log -1 --format='%h - %s')"

# Show remote repository URL
REMOTE_URL=$(git remote get-url origin)
print_status "Remote repository: $REMOTE_URL"
