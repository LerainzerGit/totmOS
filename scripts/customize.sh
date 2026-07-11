#!/bin/bash
set -e

echo ">>> totmOS customization starting"

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# --- OS identity -----------------------------------------------------------
cat > /etc/os-release <<'EOF'
NAME="totmOS"
VERSION="1.0"
ID=totmos
ID_LIKE=ubuntu
PRETTY_NAME="totmOS 1.0"
VERSION_ID="1.0"
HOME_URL="https://totmu.example"
SUPPORT_URL="https://totmu.example"
EOF

echo "totmos" > /etc/hostname
sed -i 's/xubuntu/totmos/g' /etc/hosts || true

if [ -f /etc/lsb-release ]; then
  cat > /etc/lsb-release <<'EOF'
DISTRIB_ID=totmOS
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=welcomehome
DISTRIB_DESCRIPTION="totmOS 1.0"
EOF
fi

# --- Packages (extend as needed) -------------------------------------------
apt-get update
apt-get install -y --no-install-recommends \
  plymouth plymouth-themes lightdm-gtk-greeter \
  xfce4-whiskermenu-plugin \
  arc-theme papirus-icon-theme fonts-noto

# --- Plymouth boot splash ----------------------------------------------------
mkdir -p /usr/share/plymouth/themes/totmos
cp /tmp/branding/plymouth/* /usr/share/plymouth/themes/totmos/ 2>/dev/null || true
if [ -f /usr/share/plymouth/themes/totmos/totmos.plymouth ]; then
  update-alternatives --install /usr/share/plymouth/themes/default.plymouth \
    default.plymouth /usr/share/plymouth/themes/totmos/totmos.plymouth 100
  update-alternatives --set default.plymouth /usr/share/plymouth/themes/totmos/totmos.plymouth
  update-initramfs -u || true
fi

# --- LightDM greeter branding ------------------------------------------------
mkdir -p /usr/share/backgrounds/totmos
cp /tmp/branding/wallpaper.png /usr/share/backgrounds/totmos/wallpaper.png 2>/dev/null || true
mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
cat > /etc/lightdm/lightdm-gtk-greeter.conf.d/60-totmos.conf <<'EOF'
[greeter]
background=/usr/share/backgrounds/totmos/wallpaper.png
theme-name=Arc-Dark
icon-theme-name=Papirus-Dark
font-name=Noto Sans 10
EOF

# --- XFCE desktop defaults (macOS/Windows-hybrid layout) --------------------
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
cp /tmp/branding/xfce/*.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null || true

mkdir -p /etc/skel/Pictures
cp /tmp/branding/lightdm/wallpaper.png /etc/skel/Pictures/totmos-wallpaper.png 2>/dev/null || true

# --- Branding: About dialog / distro logo ------------------------------------
mkdir -p /usr/share/pixmaps
cp /tmp/branding/xfce/totmos-logo.png /usr/share/pixmaps/totmos-logo.png 2>/dev/null || true

echo ">>> totmOS customization complete"
