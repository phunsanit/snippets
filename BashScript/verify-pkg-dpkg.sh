#!/bin/bash

# ==============================================================================
# Script Name: verify-pkg-dpkg.sh
# Description: High-performance verification using native 'dpkg --verify'.
#			   Filters results by path and depth efficiently.
# Author	 : AI Assistant
# Date		 : 2026
# ==============================================================================
# MANUAL & DOCUMENTATION:
#
# OPTIONS:
#   -p <path>  : Base directory path to filter (Default: /)
#   -d <depth> : Maximum directory depth for filtering (Default: Unlimited)
#   -h		   : Display this help message
#
# EXAMPLES:
#   sudo ./verify-pkg-dpkg.sh
#   sudo ./verify-pkg-dpkg.sh -p /etc
#   sudo ./verify-pkg-dpkg.sh -p /usr/bin -d 1
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
OUTPUT_FILE="${SCRIPT_DIR}/verify-pkg-dpkg-${ISO_DATE}.txt"

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

# Ensure SEARCH_PATH ends with a slash for proper matching (except for / itself)
[[ "$SEARCH_PATH" != "/" ]] && SEARCH_PATH="${SEARCH_PATH%/}/"

echo "🔍 Starting high-performance system verification..."
echo "📍 Target Path : $SEARCH_PATH"
[[ -n "$MAX_DEPTH" ]] && echo "↕️ Max Depth : $MAX_DEPTH" || echo "↕️ Max Depth : Unlimited"
echo "📝 Report File : $OUTPUT_FILE"
echo "⚙️ Progress	 : Processing changed files in real-time..."
echo "---------------------------------------------------------"

# Clean/Create the output file
> "$OUTPUT_FILE"

# Open File Descriptor 3 for direct logging
exec 3>>"$OUTPUT_FILE"

# Function to calculate depth of a file path
get_depth() {
	local file_path="$1"
	local relative_path="${file_path#$SEARCH_PATH}"
	echo "${relative_path}" | tr -cd '/' | wc -c
}

# Counter for items found
MATCH_COUNT=0

# Run native dpkg --verify with unbuffered stream profiling
stdbuf -oL dpkg --verify 2>/dev/null | while read -r LINE; do
	FILE_PATH=$(echo "$LINE" | awk '{print $NF}')

	# Check if the file is within our target SEARCH_PATH
	if [[ "$FILE_PATH" == "$SEARCH_PATH"* || "$SEARCH_PATH" == "/" ]]; then

		# If MAX_DEPTH is set, verify the depth limit
		if [[ -n "$MAX_DEPTH" ]]; then
			CURRENT_DEPTH=$(get_depth "$FILE_PATH")
			if (( CURRENT_DEPTH >= MAX_DEPTH )); then
				continue
			fi
		fi

		# Print to screen instantly, log to file descriptor, and update counter
		echo "$LINE"
		echo "$LINE" >&3
		((MATCH_COUNT++))
	fi
done

exec 3>&-

echo "--------------------------------------------------"
echo "✅ Verification complete!"
echo "⚠️ Total modified files found matching criteria: $MATCH_COUNT"
echo "📂 Results saved to $OUTPUT_FILE"
