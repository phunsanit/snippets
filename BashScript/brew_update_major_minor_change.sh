#!/bin/bash

# Clear screen
clear
echo "======================================================="
echo "   GIT URL REWRITER: User + Host + Token"
echo "======================================================="
echo ""

# ---------------------------------------------------------
# 1. Set Default values as empty (no hardcoded values)
# ---------------------------------------------------------
DEFAULT_HOST=""
DEFAULT_USER=""  # <--- Leave empty, only attempt to extract from actual repo

# Try to find repo in this folder to extract existing values
FIRST_REPO=$(find . -maxdepth 2 -type d -name ".git" | head -n 1)
if [ -n "$FIRST_REPO" ]; then
    REPO_DIR=$(dirname "$FIRST_REPO")
    (
        cd "$REPO_DIR" || exit
        CURRENT_URL=$(git remote get-url origin)

        # Extract Host
        TEMP_HOST=$(echo "$CURRENT_URL" | sed -E 's/.*@([^:/]*).*/\1/' | sed -E 's/.*:\/\/([^/]*)\/.*/\1/')
        if [ -n "$TEMP_HOST" ]; then DEFAULT_HOST=$TEMP_HOST; fi

        # Extract Username (only for HTTPS with embedded username)
        if [[ "$CURRENT_URL" == *"https://"* && "$CURRENT_URL" == *"@"* ]]; then
             # Extract word between https:// and : (or @)
             TEMP_USER=$(echo "$CURRENT_URL" | sed -E 's/https:\/\/([^:@]*).*/\1/')
             if [ -n "$TEMP_USER" ]; then DEFAULT_USER=$TEMP_USER; fi
        fi
    )
fi

# ---------------------------------------------------------
# 2. Get input from user
# ---------------------------------------------------------

# 2.1 Host
read -p "🌐 Git Host [default: $DEFAULT_HOST]: " INPUT_HOST
GIT_HOST=${INPUT_HOST:-$DEFAULT_HOST}

# 2.2 Username
read -p "👤 Username [default: $DEFAULT_USER]: " INPUT_USER
GIT_USER=${INPUT_USER:-$DEFAULT_USER}

if [ -z "$GIT_USER" ]; then
    echo "❌ Error: Username cannot be empty!"
    exit 1
fi

# 2.3 Token
echo ""
read -s -p "🔑 New Personal Access Token (glpat-...): " GIT_TOKEN
echo ""

if [ -z "$GIT_TOKEN" ]; then
    echo "❌ Error: Token cannot be empty!"
    exit 1
fi

echo "-------------------------------------------------------"
echo "✅ New Configuration:"
echo "   Host:  $GIT_HOST"
echo "   User:  $GIT_USER"
echo "   Token: [HIDDEN]"
echo "-------------------------------------------------------"
echo "🔄 Rewriting URLs..."

# ---------------------------------------------------------
# 3. Update URLs
# ---------------------------------------------------------
for dir in */; do
    dirname=${dir%/}
    if [ -d "$dir/.git" ]; then
        (
            cd "$dir" || exit
            CURRENT_URL=$(git remote get-url origin)

            if [[ "$CURRENT_URL" == *"$GIT_HOST"* ]]; then
                # Remove prefix, keep only path (fixed extra space bug at \1)
                REPO_PATH=$(echo "$CURRENT_URL" | sed -E "s|.*$GIT_HOST[:/](.*)| \1|")

                # Create new URL
                NEW_URL="https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST}/${REPO_PATH}"

                git remote set-url origin "$NEW_URL"
                echo "✅ [$dirname] Updated."
            else
                echo "⚠️  [$dirname] Skipped (Host mismatch)"
            fi
        )
    fi
done

echo "-------------------------------------------------------"
echo "🎉 All Done!"
