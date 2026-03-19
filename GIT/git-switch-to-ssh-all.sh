#!/bin/bash

# Clear screen
clear
echo "======================================================="
echo "  GIT REMOTE TO SSH UPDATER"
echo "======================================================="
echo ""

# ---------------------------------------------------------
# 1. Auto-Detect Status
# ---------------------------------------------------------
DEFAULT_HOST=""

FIRST_REPO=$(find . -maxdepth 2 -type d -name ".git" | head -n 1)

if [ -n "$FIRST_REPO" ]; then
    REPO_DIR=$(dirname "$FIRST_REPO")
    CURRENT_URL=$(git -C "$REPO_DIR" remote get-url origin)

    # Extract Host
    CLEAN_HOST=$(echo "$CURRENT_URL" | sed -E 's|https://||' | sed -E 's|http://||' | sed -E 's|git@||' | sed -E 's/.*@//' | sed -E 's|/.*||' | sed -E 's|:.*||')
    if [ -n "$CLEAN_HOST" ]; then DEFAULT_HOST=$CLEAN_HOST; fi
else
    echo "❌ Error: No Git repository found in this folder."
    exit 1
fi

# ---------------------------------------------------------
# 2. Decision
# ---------------------------------------------------------
echo "ℹ️  This script will convert all repositories to SSH mode (git@...)"
echo "⚠️  Ensure you have added your SSH Key to $DEFAULT_HOST"
echo ""
read -p "❓ Do you want to proceed? (y/n): " DECISION

if [[ "$DECISION" != "y" && "$DECISION" != "Y" ]]; then
    echo "🛑 Operation cancelled."
    exit 0
fi

# ---------------------------------------------------------
# 3. Get Host Input
# ---------------------------------------------------------
DISP_HOST=${DEFAULT_HOST:-none}
read -p "🌐 Git Host [default: $DISP_HOST]: " INPUT_HOST
GIT_HOST=${INPUT_HOST:-$DEFAULT_HOST}
if [ -z "$GIT_HOST" ]; then echo "❌ Error: Host cannot be empty!"; exit 1; fi

echo "-------------------------------------------------------"
echo "🔄 Converting URLs to SSH..."

# ---------------------------------------------------------
# 4. Execute Update
# ---------------------------------------------------------
for dir in */; do
    dirname=${dir%/}
    if [ -d "$dir/.git" ]; then
        (
            cd "$dir" || exit
            CURRENT_URL=$(git remote get-url origin)

            if [[ "$CURRENT_URL" == *"$GIT_HOST"* ]]; then
                # ดึงเฉพาะ Path ของโปรเจกต์ออกมา
                RAW_PATH=$(echo "$CURRENT_URL" | sed -E "s|.*$GIT_HOST[:/](.*)|\1|")
                CLEAN_PATH=$(echo "$RAW_PATH" | sed -E 's/^[[:space:]]+//')

                # สร้าง URL แบบ SSH (ใช้ user 'git' เสมอ)
                NEW_URL="git@${GIT_HOST}:${CLEAN_PATH}"

                git remote set-url origin "$NEW_URL"
                echo "✅ [$dirname] -> SSH mode"
            else
                echo "⚠️  [$dirname] Skipped (Host mismatch)"
            fi
        )
    fi
done

echo "-------------------------------------------------------"
echo "🎉 All Done! Now you can push/pull without tokens."