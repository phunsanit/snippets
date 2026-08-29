#!/bin/bash

# ==============================================================================
# Script Name: verify-custom-files.sh
# Description: Finds ALL custom/added files across the entire system (/)
#			   with 100% real-time unbuffered screen output.
#			   Outputs 4-digit octal permissions directly from system stat.
# Author:	   AI Assistant
# Date:		   2026
# ==============================================================================
# MANUAL & DOCUMENTATION:
#
# OPTIONS:
#   -p <path>  : Base directory path to scan (Default: /)
#   -d <depth> : Maximum directory depth for scanning (Default: Unlimited)
#   -h		   : Display this help message
#
# EXAMPLES:
#   1. Scan entire system (Skips virtual, temp & kernel directories automatically)
#	  sudo ./verify-custom-files.sh
#
#   2. Scan only /etc directory with unlimited depth
#	  sudo ./verify-custom-files.sh -p /etc
#
# LIMITATIONS:
#   - Performance: Scanning the entire root (/) without a depth limit
#	 takes less than a few minutes since kernel directories are now ignored.
#   - Scope: Only identifies files NOT tracked by the dpkg package manager.
# ==============================================================================

# Ensure script is running with root/sudo privileges
if [ "$EUID" -ne 0 ]; then
	echo "❌ Error: Please run this script with root privileges (sudo)."
	exit 1
fi

# Enable lastpipe so variables modified inside the while loop persist outside
shopt -s lastpipe

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Default values
SEARCH_PATH="/"
MAX_DEPTH=""
ISO_DATE=$(date +%Y-%m-%d_%H%M%S)
OUTPUT_FILE="${SCRIPT_DIR}/verify-custom-files-full-${ISO_DATE}.txt"

# Usage help function
usage() {
	echo "Usage: $0 [-p <path>] [-d <depth>]"
	echo " -p : Specify starting directory path (Default: /)"
	echo " -d : Specify maximum search depth (integer)"
	exit 1
}

# Parse command-line arguments
while getopts "p:d:h" opt; do
	case ${opt} in
		p ) SEARCH_PATH=$OPTARG ;;
		d ) MAX_DEPTH=$OPTARG ;;
		h | ? ) usage ;;
	esac
done

echo "🔍 Starting Full System Scan for custom/added files..."
echo "📍 Target Path : $SEARCH_PATH"
[[ -n "$MAX_DEPTH" ]] && echo "↕️ Max Depth : $MAX_DEPTH" || echo "↕️ Max Depth : Unlimited"
echo "📝 Report File : $OUTPUT_FILE"
echo "----------------------------------------------------------------------"

# Clean/Create the output file
> "$OUTPUT_FILE"

# Open File Descriptor 3 for high-performance direct logging
exec 3>>"$OUTPUT_FILE"

# Collect Distro Architecture, OS Version, and Total Package Info for Analysis
DISTRO_NAME=$(lsb_release -is 2>/dev/null || cat /etc/os-release | grep -E '^NAME=' | cut -d= -f2 | tr -d '"')
DISTRO_VER=$(lsb_release -rs 2>/dev/null || cat /etc/os-release | grep -E '^VERSION_ID=' | cut -d= -f2 | tr -d '"')
TOTAL_PKGS=$(dpkg-query -f '${binary:Package}\n' -W 2>/dev/null | wc -l)

# Write metadata header to report file
{
	echo "======================================================================"
	echo " SYSTEM VERIFICATION BASELINE REPORT"
	echo "======================================================================"
	echo "Scan Date	   : $(date '+%Y-%m-%d %H:%M:%S')"
	echo "Distro Name  : $DISTRO_NAME"
	echo "Version	   : $DISTRO_VER"
	echo "Total Packages Installed : $TOTAL_PKGS"
	echo "Target Path  : $SEARCH_PATH"
	echo "======================================================================"
	echo ""
	echo "ID NO. │ PERM (4-DIGIT) │ OWNER:GROUP │ FILE PATH"
	echo "----------------------------------------------------------------------"
} >&3

# Dump official distro files to a temporary reference file
REF_FILE="/tmp/distro_files.tmp"
echo "📦 Loading official package database..."
cat /var/lib/dpkg/info/*.list 2>/dev/null | sort -u > "$REF_FILE"
echo "⚡ Database loaded. Scanning disk now (Real-time output enabled)..."
echo "----------------------------------------------------------------------"
echo "ID NO. │ PERM (4-DIGIT) │ OWNER:GROUP │ FILE PATH"
echo "----------------------------------------------------------------------"

# Configure Prune Expression to skip dynamic, virtual, and kernel directories
PRUNE_EXPR=""
if [[ "$SEARCH_PATH" == "/" ]]; then
	PRUNE_EXPR="\( \
		-path /proc -o \
		-path /sys -o \
		-path /dev -o \
		-path /run -o \
		-path /tmp -o \
		-path /var/tmp -o \
		-path /var/cache -o \
		-path /var/lib/apt -o \
		-path /var/log -o \
		-path /mnt -o \
		-path /media -o \
		-path /snap -o \
		-path /var/lib/snapd -o \
		-path /usr/lib/modules -o \
		-path /usr/lib/firmware \
	\) -prune -o"
fi

DEPTH_EXPR=""
if [[ -n "$MAX_DEPTH" ]]; then
	DEPTH_EXPR="-maxdepth $MAX_DEPTH"
fi

MATCH_COUNT=0

# Core loop: Scan filesystem, check against baseline, output unbuffered metadata
eval stdbuf -oL find \"$SEARCH_PATH\" $DEPTH_EXPR $PRUNE_EXPR -type f 2>/dev/null | while read -r FILE; do
	if ! grep -Fxq "$FILE" "$REF_FILE"; then
		((MATCH_COUNT++))

		# Extract 4-digit octal permissions natively from the system stat
		PERM=$(stat -c "%04a" "$FILE" 2>/dev/null)
		OWNER=$(stat -c "%U:%G" "$FILE" 2>/dev/null)

		RESULT_LINE=$(printf "%-6d │ %-14s │ %-11s │ %s" "$MATCH_COUNT" "$PERM" "$OWNER" "$FILE")

		# Display to screen and write to file immediately
		echo "$RESULT_LINE"
		echo "$RESULT_LINE" >&3
	fi
done

# Clean up and append summary to file
echo "----------------------------------------------------------------------" >&3
echo "✅ Full Scan complete! Total custom files found: $MATCH_COUNT" >&3

exec 3>&-
rm -f "$REF_FILE"

echo "----------------------------------------------------------------------"
echo "✅ Full Scan complete!"
echo "⚠️  Total custom files found across the system: $MATCH_COUNT"
echo "📂 List saved to: $OUTPUT_FILE"
