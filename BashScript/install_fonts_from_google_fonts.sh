#!/bin/bash

# ====================================================
# SYNOPSIS
#    Download and Install Google Fonts for macOS/Linux
#    - Auto-checks for Root (Sudo)
#    - Options: Cache to Local, Fixed Path, or No Cache
#    Author: pitt phunsanit (pitt.plusmagi.com)
# ====================================================

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# --- 0. ROOT CHECK ---
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (use sudo).${NC}"
  echo "Usage: sudo ./install_fonts_from_google_fonts.sh"
  exit
fi

# --- 1. DETECT OS & SET INSTALL PATH ---
OS_TYPE=""
INSTALL_DIR=""

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
    INSTALL_DIR="/Library/Fonts"
else
    OS_TYPE="Linux"
    # Create a specific directory for these fonts to keep it clean
    INSTALL_DIR="/usr/share/fonts/google-thai-fonts"
fi

# --- 2. SETUP PATHS & MENU ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USB_FONTS_PATH="$SCRIPT_DIR/Fonts"
FIXED_FONTS_PATH="/opt/portables/Fonts" # Linux/Mac equivalent convention
CACHE_DIR=""
SHOULD_CLEANUP=false

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}       GOOGLE FONTS INSTALLER UTILITY ($OS_TYPE)${NC}"
echo -e "${CYAN}       Author: pitt phunsanit (pitt.plusmagi.com)${NC}"
echo -e "${CYAN}====================================================${NC}"

echo -e "Select Download/Cache Destination:"
echo -e "[1] Current Location : ${YELLOW}$USB_FONTS_PATH${NC}"
echo -e "[2] Fixed Path       : ${GRAY}$FIXED_FONTS_PATH${NC}"
echo -e "[3] No Cache         : ${RED}(Temp & Delete)${NC}"

read -p "Select [1], [2] or [3] (Default is 1): " choice

# Logic to set directory
if [ "$choice" == "2" ]; then
    CACHE_DIR="$FIXED_FONTS_PATH"
elif [ "$choice" == "3" ]; then
    CACHE_DIR=$(mktemp -d)
    SHOULD_CLEANUP=true
else
    CACHE_DIR="$USB_FONTS_PATH"
fi

# --- 3. CONFIGURATION ---
FONTS=(
    "Bai+Jamjuree"
    "Chakra+Petch"
    "Charm"
    "Charmonman"
    "Fah+Kwang"
    "K2D"
    "Kodchasan"
    "KoHo"
    "Krub"
    "Maitree"
    "Mali"
    "Niramit"
    "Sarabun"
    "Srisakdi"
    "Taviraj"
    "Thasadith"
)

# --- 4. START PROCESS ---

# Create Directory
if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
    echo -e "${CYAN}Created working folder at: $CACHE_DIR${NC}"
else
    echo -e "${CYAN}Using working folder at: $CACHE_DIR${NC}"
fi

# Check for unzip tool
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}Error: 'unzip' is not installed. Please install it first.${NC}"
    exit 1
fi

echo ""
# Download & Extract Loop
for font in "${FONTS[@]}"; do
    url="https://fonts.google.com/download?family=$font"
    zip_path="$CACHE_DIR/$font.zip"

    # Check Cache
    if [ -f "$zip_path" ]; then
        echo -e "${GRAY}[$font] Found in cache. Skipping download.${NC}"
    else
        echo -e "${YELLOW}[$font] Downloading...${NC}"
        # curl -L (follow redirects) -o (output file) -s (silent) -w (write status)
        if curl -L -o "$zip_path" "$url" --fail --silent; then
            echo -e "${GREEN}[$font] Download completed.${NC}"
        else
            echo -e "${RED}[$font] Error downloading.${NC}"
            continue
        fi
    fi

    # Extract
    # -o (overwrite) -d (destination) -j (junk paths/flatten folders if any)
    unzip -o -j -q "$zip_path" -d "$CACHE_DIR" "*.ttf" "*.otf" 2>/dev/null
done

# --- 5. INSTALLATION ---
echo -e "\n${CYAN}Starting Installation to: $INSTALL_DIR${NC}"

# Create install dir if needed (mainly for Linux custom folder)
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Copy Fonts
count=0
# Find .ttf and .otf files in Cache Dir
for file in "$CACHE_DIR"/*.{ttf,otf}; do
    [ -e "$file" ] || continue # Handle case if no fonts found

    filename=$(basename "$file")

    # Check if exists in System
    if [ -f "$INSTALL_DIR/$filename" ]; then
        echo -e "${GRAY}Skipping $filename (Already installed)${NC}"
    else
        echo -e "${YELLOW}Installing $filename ...${NC}"
        cp "$file" "$INSTALL_DIR/"
        chmod 644 "$INSTALL_DIR/$filename" # Ensure readable
        ((count++))
    fi
done

# --- 6. OS SPECIFIC CACHE UPDATE ---
if [ "$OS_TYPE" == "Linux" ]; then
    if [ $count -gt 0 ]; then
        echo -e "${YELLOW}Updating Linux font cache...${NC}"
        fc-cache -f -v "$INSTALL_DIR" > /dev/null
    fi
fi

# --- FINISH ---
echo -e "\n${GREEN}------------------------------------------------${NC}"

if [ "$SHOULD_CLEANUP" = true ]; then
    echo -e "${RED} Cleaning up temporary files...${NC}"
    rm -rf "$CACHE_DIR"
    echo -e "${GREEN} Temp folder deleted.${NC}"
else
    echo -e "${CYAN} Fonts stored at: $CACHE_DIR${NC}"
fi

echo -e "${GREEN} Process Completed!${NC}"
echo -e "${GREEN}------------------------------------------------${NC}"

sleep 2
