#!/bin/bash
# ============================================================
# extract_blobs.sh
# Script untuk extract dan generate proprietary files list dari LJ6
# ============================================================

set -e

VENDOR_MOUNT="/home/codespace/lj6-firmware/mount/vendor"
DEVICE_DIR="/workspaces/android_device_tecno_lj6"
PROP_FILE="$DEVICE_DIR/proprietary-files.txt"

echo "============================================"
echo "  EXTRACT BLOBS: LJ6"
echo "============================================"
echo ""
echo "Source: $VENDOR_MOUNT"
echo "Output: $PROP_FILE"
echo ""

# Generate list of blobs from vendor partition
echo "# Blobs from LJ6-H8915AhAiAjAkAlAmAnAo-V-BASE-251016V1597DevT" > "$PROP_FILE"
echo "" >> "$PROP_FILE"

# Function to process files
process_dir() {
    local prefix="$1"
    local source_dir="$2"
    
    if [ ! -d "$source_dir" ]; then
        return
    fi
    
    find "$source_dir" -type f 2>/dev/null | sed "s|$VENDOR_MOUNT/||" | sort
}

# Process vendor directories
echo "=== vendor/bin ===" 
process_dir "vendor/bin" "$VENDOR_MOUNT/bin"

echo ""
echo "=== vendor/etc ===" 
process_dir "vendor/etc" "$VENDOR_MOUNT/etc"

echo ""
echo "=== vendor/lib ===" 
process_dir "vendor/lib" "$VENDOR_MOUNT/lib"

echo ""
echo "=== vendor/lib64 ===" 
process_dir "vendor/lib64" "$VENDOR_MOUNT/lib64"

echo ""
echo "============================================"
echo "  DONE"
echo "============================================"
