#!/bin/bash

# Clear screen
clear
echo "======================================================="
echo "	GIT TOKEN CHECKER & UPDATER"
echo "======================================================="
echo ""

# ---------------------------------------------------------
# 1. Auto-Detect Status
# ---------------------------------------------------------
DEFAULT_HOST=""
DEFAULT_USER=""
HAS_TOKEN=false

# Find the first repo to check status
FIRST_REPO=$(find . -maxdepth 2 -type d -name ".git" | head -n 1)

if [ -n "$FIRST_REPO" ]; then
	REPO_DIR=$(dirname "$FIRST_REPO")

	# Use 'git -C' to check URL safely
	CURRENT_URL=$(git -C "$REPO_DIR" remote get-url origin)

	# Check for '@' (If present, credentials are embedded)
	if [[ "$CURRENT_URL" == *"@"* ]]; then
		HAS_TOKEN=true
	fi

	# Extract Host & User for default values
	CLEAN_HOST=$(echo "$CURRENT_URL" | sed -E 's|https://||' | sed -E 's|http://||' | sed -E 's|git@||' | sed -E 's/.*@//' | sed -E 's|/.*||' | sed -E 's|:.*||')
	if [ -n "$CLEAN_HOST" ]; then DEFAULT_HOST=$CLEAN_HOST; fi

	if [[ "$CURRENT_URL" == *"https://"* && "$CURRENT_URL" == *"@"* ]]; then
			TEMP_USER=$(echo "$CURRENT_URL" | sed -E 's/https:\/\/([^:@]*).*/\1/')
			if [ -n "$TEMP_USER" ]; then DEFAULT_USER=$TEMP_USER; fi
	fi
else
	echo "❌ Error: No Git repository found in this folder."
	exit 1
fi

# ---------------------------------------------------------
# 2. Status Report & Decision
# ---------------------------------------------------------

if [ "$HAS_TOKEN" = false ]; then
	# Case: No Token found
	echo "⚠️  Current Status: No Access Token embedded (Clean URL)"
	echo "   (System might be using Keychain or SSH Key)"
	echo ""
	read -p "❓ Do you want to switch to 'Embedded Token' mode? (y/n): " DECISION

else
	# Case: Token found
	echo "ℹ️  Current Status: Token is already embedded."
	echo ""
	# NEW: Ask before updating
	read -p "❓ Do you want to UPDATE/REPLACE the existing token? (y/n): " DECISION
fi

# ---------------------------------------------------------
# 3. Process Decision
# ---------------------------------------------------------

# If answer is NOT 'y' or 'Y', exit
if [[ "$DECISION" != "y" && "$DECISION" != "Y" ]]; then
	echo ""
	echo "🛑 Operation cancelled. No changes made."
	exit 0
fi

echo ""
echo "✅ Proceeding to update..."
echo "-------------------------------------------------------"

# ---------------------------------------------------------
# 4. Get Input
# ---------------------------------------------------------

# Host
DISP_HOST=${DEFAULT_HOST:-none}
read -p "🌐 Git Host [default: $DISP_HOST]: " INPUT_HOST
GIT_HOST=${INPUT_HOST:-$DEFAULT_HOST}
if [ -z "$GIT_HOST" ]; then echo "❌ Error: Host cannot be empty!"; exit 1; fi

# Username
DISP_USER=${DEFAULT_USER:-none}
read -p "👤 Username [default: $DISP_USER]: " INPUT_USER
GIT_USER=${INPUT_USER:-$DEFAULT_USER}
if [ -z "$GIT_USER" ]; then echo "❌ Error: Username cannot be empty!"; exit 1; fi

# Token
echo ""
read -s -p "🔑 New Personal Access Token (glpat-...): " GIT_TOKEN
echo ""
if [ -z "$GIT_TOKEN" ]; then echo "❌ Error: Token cannot be empty!"; exit 1; fi

echo "-------------------------------------------------------"
echo "🔄 Updating URLs..."

# ---------------------------------------------------------
# 5. Execute Update
# ---------------------------------------------------------
for dir in */; do
	dirname=${dir%/}
	if [ -d "$dir/.git" ]; then
		(
			cd "$dir" || exit
			CURRENT_URL=$(git remote get-url origin)

			if [[ "$CURRENT_URL" == *"$GIT_HOST"* ]]; then

				# Critical: Strip host prefix and remove leading spaces
				RAW_PATH=$(echo "$CURRENT_URL" | sed -E "s|.*$GIT_HOST[:/](.*)|\1|")
				CLEAN_PATH=$(echo "$RAW_PATH" | sed -E 's/^[[:space:]]+//')

				# Construct new URL
				NEW_URL="https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST}/${CLEAN_PATH}"

				git remote set-url origin "$NEW_URL"
				echo "✅ [$dirname] Updated with Token."
			else
				echo "⚠️  [$dirname] Skipped (Host mismatch)"
			fi
		)
	fi
done

echo "-------------------------------------------------------"
echo "🎉 All Done!"