#!/bin/bash
# ============================================================
# rename_device.sh
# Script untuk mengganti semua referensi LH7n/rozen ke LJ6/h897
# ============================================================

set -e

DEVICE_DIR="/workspaces/android_device_tecno_lj6"

echo "============================================"
echo "  RENAME DEVICE: LH7n -> LJ6"
echo "============================================"
echo ""
echo "Target directory: $DEVICE_DIR"
echo ""

# Daftar replacement (pattern lama -> pattern baru)
declare -A REPLACEMENTS=(
    ["LH7n"]="LJ6"
    ["lh7n"]="lj6"
    ["rozen"]="h897"
    ["Rozen"]="H897"
    ["ROZEN"]="H897"
    ["TECNO-LH7n"]="TECNO-LJ6"
    ["TECNO LH7n"]="TECNO LJ6"
    ["LH7n-GL"]="LJ6-OP"
    ["lineage_LH7n"]="lineage_LJ6"
    ["FrameworkResOverlayRozen"]="FrameworkResOverlayH897"
    ["SettingsResOverlayRozen"]="SettingsResOverlayH897"
    ["SettingsProviderOverlayRozen"]="SettingsProviderOverlayH897"
    ["SystemUIResOverlayRozen"]="SystemUIResOverlayH897"
)

# File yang akan diproses
FILES=(
    "$DEVICE_DIR/BoardConfig.mk"
    "$DEVICE_DIR/device.mk"
    "$DEVICE_DIR/AndroidProducts.mk"
    "$DEVICE_DIR/lineage_LH7n.mk"
    "$DEVICE_DIR/proprietary-files.txt"
    "$DEVICE_DIR/proprietary-firmware.txt"
    "$DEVICE_DIR/extract-files.py"
    "$DEVICE_DIR/setup-makefiles.py"
    "$DEVICE_DIR/vendor_logtag.mk"
    "$DEVICE_DIR/vendorsetup.sh"
)

# Counter
TOTAL_REPLACEMENTS=0
TOTAL_FILES=0

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "[SKIP] File tidak ditemukan: $file"
        continue
    fi

    FILE_CHANGED=false

    for old in "${!REPLACEMENTS[@]}"; do
        new="${REPLACEMENTS[$old]}"
        if grep -q "$old" "$file" 2>/dev/null; then
            sed -i "s/$old/$new/g" "$file"
            FILE_CHANGED=true
            echo "  [REPLACE] '$old' -> '$new' in $(basename $file)"
        fi
    done

    if [ "$FILE_CHANGED" = true ]; then
        TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
done

echo ""
echo "============================================"
echo "  SELESAI: $TOTAL_FILES file diubah"
echo "============================================"

# Rename file lineage_LH7n.mk -> lineage_LJ6.mk
if [ -f "$DEVICE_DIR/lineage_LH7n.mk" ]; then
    mv "$DEVICE_DIR/lineage_LH7n.mk" "$DEVICE_DIR/lineage_LJ6.mk"
    echo "[RENAME] lineage_LH7n.mk -> lineage_LJ6.mk"
fi

# Rename overlay directories
for old_dir in FrameworkResOverlayRozen SettingsResOverlayRozen; do
    if [ -d "$DEVICE_DIR/overlay/$old_dir" ]; then
        case "$old_dir" in
            FrameworkResOverlayRozen)
                new_dir="FrameworkResOverlayH897"
                ;;
            SettingsResOverlayRozen)
                new_dir="SettingsResOverlayH897"
                ;;
        esac
        mv "$DEVICE_DIR/overlay/$old_dir" "$DEVICE_DIR/overlay/$new_dir"
        echo "[RENAME] overlay/$old_dir -> overlay/$new_dir"
    fi
done

echo ""
echo "Done!"
