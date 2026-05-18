#!/bin/bash
# Apply JVector patches to upstream code for rebranding.
# This script applies all patch files in order

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PATCHES_DIR="$REPO_ROOT/.automation/patches"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Function to apply a single patch
apply_patch() {
    local patch_file="$1"
    local patch_name=$(basename "$patch_file")
    
    log_step "Applying $patch_name..."
    
    # First, check if patch will apply cleanly
    if git apply --check "$patch_file" 2>/dev/null; then
        # Apply patch
        git apply "$patch_file"
        log_info "$patch_name applied successfully"
        return 0
    else
        log_warn "$patch_name cannot be applied cleanly, trying 3-way merge..."
        
        # Try 3-way merge
        if git apply --3way "$patch_file" 2>/dev/null; then
            log_info "$patch_name applied with 3-way merge"
            return 0
        else
            log_error "❌ Failed to apply $patch_name"
            log_error "   Manual intervention required"
            return 1
        fi
    fi
}

# Main function
main() {
    log_info "Starting patch application..."
    log_info "Repository: $REPO_ROOT"
    log_info "Patches directory: $PATCHES_DIR"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "$REPO_ROOT/build.gradle" ]; then
        log_error "Not in neural-search-jvector repository"
        exit 1
    fi
    
    # Check if patches directory exists
    if [ ! -d "$PATCHES_DIR" ]; then
        log_error "Patches directory not found: $PATCHES_DIR"
        exit 1
    fi
    
    # Count patches
    local patch_count=$(ls -1 "$PATCHES_DIR"/*.patch 2>/dev/null | wc -l)
    if [ "$patch_count" -eq 0 ]; then
        log_error "No patch files found in $PATCHES_DIR"
        exit 1
    fi
    
    log_info "Found $patch_count patch file(s)"
    echo ""
    
    # Apply patches in order
    local failed_patches=()
    local success_count=0
    
    for patch_file in "$PATCHES_DIR"/*.patch; do
        if [ -f "$patch_file" ]; then
            if apply_patch "$patch_file"; then
                ((success_count++))
            else
                failed_patches+=("$(basename "$patch_file")")
            fi
            echo ""
        fi
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Patch Application Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Total patches: $patch_count"
    log_info "Successfully applied: $success_count"
    
    if [ ${#failed_patches[@]} -gt 0 ]; then
        log_error "Failed patches: ${#failed_patches[@]}"
        for patch in "${failed_patches[@]}"; do
            log_error "  - $patch"
        done
        echo ""
        log_error "Some patches failed to apply. Please resolve conflicts manually."
        exit 1
    else
        log_info "All patches applied successfully!"
        echo ""
        log_info "Next steps:"
        log_info "  1. Review changes: git diff"
        log_info "  2. Run tests: ./gradlew check integTest"
        log_info "  3. Commit changes: git add . && git commit -m 'Apply jvector changes'"
    fi
}

main "$@"
