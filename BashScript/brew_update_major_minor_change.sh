#!/bin/bash

# Clear screen
clear
echo "======================================================="
echo "   GIT URL REWRITER: User + Host + Token"
echo "======================================================="
echo ""

# ---------------------------------------------------------
# 1. Auto-Detect Defaults
# ---------------------------------------------------------
DEFAULT_HOST=""
DEFAULT_USER=""

# Find the first git repository in this folder to use as a reference
FIRST_REPO=$(find . -maxdepth 2 -type d -name ".git" | head -n 1)

if [ -n "$FIRST_REPO" ]; then
    REPO_DIR=$(dirname "$FIRST_REPO")

    # Use 'git -C' to run command safely
    CURRENT_URL=$(git -C "$REPO_DIR" remote get-url origin)

    # --- Logic: Extract Host cleanly ---
    # 1. Remove protocol (https://, http://, git@)
    CLEAN_HOST=$(echo "$CURRENT_URL" | sed -E 's|https://||' | sed -E 's|http://||' | sed -E 's|git@||')

    # 2. Remove credentials (anything before @)
    CLEAN_HOST=$(echo "$CLEAN_HOST" | sed -E 's/.*@//')

    # 3. Remove path (anything after / or :)
    CLEAN_HOST=$(echo "$CLEAN_HOST" | sed -E 's|/.*||' | sed -E 's|:.*||')

    if [ -n "$CLEAN_HOST" ]; then DEFAULT_HOST=$CLEAN_HOST; fi


    # --- Logic: Extract Username ---
    # Only if URL is HTTPS and has a username embedded (e.g., https://user@host...)
    if [[ "$CURRENT_URL" == *"https://"* && "$CURRENT_URL" == *"@"* ]]; then
            TEMP_USER=$(echo "$CURRENT_URL" | sed -E 's/https:\/\/([^:@]*).*/\1/')
            if [ -n "$TEMP_USER" ]; then DEFAULT_USER=$TEMP_USER; fi
    fi
fi

# ---------------------------------------------------------
# 2. Get input from user
# ---------------------------------------------------------

# 2.1 Host
DISP_HOST=${DEFAULT_HOST:-none}
read -p "🌐 Git Host [default: $DISP_HOST]: " INPUT_HOST
GIT_HOST=${INPUT_HOST:-$DEFAULT_HOST}

if [ -z "$GIT_HOST" ]; then
    echo "❌ Error: Host cannot be empty!"
    exit 1
fi

# 2.2 Username
DISP_USER=${DEFAULT_USER:-none}
read -p "👤 Username [default: $DISP_USER]: " INPUT_USER
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

            # Only update if the repo matches the target host
            if [[ "$CURRENT_URL" == *"$GIT_HOST"* ]]; then

                # 1. Strip everything before the host to get the raw path
                RAW_PATH=$(echo "$CURRENT_URL" | sed -E "s|.*$GIT_HOST[:/](.*)|\1|")

                # 2. CRITICAL: Remove leading spaces (Fixes 'Malformed input' error)
                CLEAN_PATH=$(echo "$RAW_PATH" | sed -E 's/^[[:space:]]+//')

                # 3. Construct the new URL
                NEW_URL="https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST}/${CLEAN_PATH}"

                # 4. Apply changes
                git remote set-url origin "$NEW_URL"

                echo "✅ [$dirname] Fixed & Updated."
            else
                echo "⚠️  [$dirname] Skipped (Host mismatch)"
            fi
        )
    fi
done

echo "-------------------------------------------------------"
echo "🎉 All Done!"
