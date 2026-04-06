# 📱 Panduan Build: TECNO LJ6 (POVA 7 4G) - Google Cloud Shell

Panduan ini untuk build LineageOS device tree di Google Cloud Shell secara gratis.

---

## 🆕 Langkah 1: Setup Awal

### Buka Google Cloud Shell
Buka https://shell.cloud.google.com

### Clone Device Tree
```bash
cd ~

# Clone repo
git clone https://github.com/bradarshome/android_device_tecno_lj6.git

# Clone kernel (jika diperlukan)
git clone https://github.com/bradarshome/android_device_tecno_lj6-kernel.git device/tecno/LJ6-kernel 2>/dev/null || echo "Kernel repo belum ada"
```

### Clone Vendor Files
```bash
# Clone vendor TECNO (jika ada)
git clone https://github.com/bradarshome/vendor_tecno.git vendor/tecno 2>/dev/null || echo "Vendor repo belum ada"
```

---

## 📦 Langkah 2: Setup Firmware

### Upload Firmware ke Cloud Shell

Karena firmware ~9GB, upload bertahap:

```bash
# Cara 1: Upload dari local
# Buka Cloud Shell → klik icon "Upload" → pilih folder lj6-firmware/

# Cara 2: Download langsung dari HuggingFace
mkdir -p ~/lj6-firmware
cd ~/lj6-firmware

# Download file yang dibutuhkan (satu per satu)
# boot.img
wget -O boot.img "https://huggingface.co/datasets/fab1x/tecno-lj6-dump/resolve/main/TECNO-LJ6-DUMP/boot.img"

# dtbo.img  
wget -O dtbo.img "https://huggingface.co/datasets/fab1x/tecno-lj6-dump/resolve/main/TECNO-LJ6-DUMP/dtbo.img"

# super.img (opsional, kalau butuh full blobs)
wget -O super.img "https://huggingface.co/datasets/fab1x/tecno-lj6-dump/resolve/main/TECNO-LJ6-DUMP/super.img"
```

---

## 🔧 Langkah 3: Extract Blobs

### Extract super.img (jika ada)
```bash
cd ~/lj6-firmware

# Install tools
sudo apt update && sudo apt install -y android-sdk-libsparse-utils erofs-fuse

# Convert & extract super.img
simg2img super.img super_raw.img
lpunpack super_raw.img

# Mount vendor partition
mkdir -p vendor_mount
erofsfuse vendor.img vendor_mount
```

### Extract Blobs ke vendor/
```bash
mkdir -p ~/android_device_tecno_lj6/proprietary

# Copy dari mounted vendor
cp -r ~/lj6-firmware/vendor_mount/bin ~/android_device_tecno_lj6/proprietary/
cp -r ~/lj6-firmware/vendor_mount/etc ~/android_device_tecno_lj6/proprietary/
cp -r ~/lj6-firmware/vendor_mount/lib ~/android_device_tecno_lj6/proprietary/
cp -r ~/lj6-firmware/vendor_mount/lib64 ~/android_device_tecno_lj6/proprietary/
```

---

## ⚙️ Langkah 4: Generate Vendor Makefiles

```bash
cd ~/android_device_tecno_lj6

# Jalankan extract-files.py (ambil blobs dari device)
python3 extract-files.py

# Generate vendor makefiles
python3 setup-makefiles.py
```

---

## 🏗️ Langkah 5: Build

```bash
# Initialize AOSP
cd ~

# Setup repo (jika belum ada)
mkdir aosp && cd aosp
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0
repo sync -c -j8 --force-sync

# Copy device tree
cp -r ~/android_device_tecno_lj6 device/tecno/LJ6

# Setup vendor (jika ada)
cp -r ~/vendor_tecno vendor/tecno

# Lunch
source build/envsetup.sh
lunch lineage_LJ6-userdebug

# Build
mka bacon -j8
```

---

## 🔍 Troubleshooting

### Error: "device/tecno/LJ6 not found"
```bash
# Pastikan path benar
export DEVICE_PATH=device/tecno/LJ6
```

### Error: Missing blobs
```bash
# Jalankan ulang extract-files.py
python3 extract-files.py --force
```

### Error: proprietary-files.txt tidak valid
```bash
# Generate ulang dari firmware
find ~/lj6-firmware/vendor_mount -type f | sed 's|.*/||' > proprietary-files.txt
```

---

## ✅ Setelah Build Berhasil

Output ada di:
```
~/aosp/out/target/product/LJ6/lineage-*.zip
```

---

## 📞 Butuh Bantuan?

Jika ada error, catat pesan error-nya dan share di:
- GitHub Issues: https://github.com/bradarshome/android_device_tecno_lj6/issues
- Telegram: @bradarshome
