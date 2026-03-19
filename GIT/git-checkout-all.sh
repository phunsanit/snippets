#!/bin/bash

# รับค่าจาก Argument
TARGET_BRANCH=${1:-"develop"}
# เช็คว่า Argument ที่สองเป็น -f หรือ force หรือไม่
if [[ "$2" == "-f" || "$2" == "force" ]]; then
    FORCE_MODE=true
else
    FORCE_MODE=false
fi

echo -e "Targeting branch: \033[1;34m$TARGET_BRANCH\033[0m"
if [ "$FORCE_MODE" = true ]; then
    echo -e "\033[0;31m⚠️  FORCE MODE ENABLED (-f)\033[0m"
fi

for dir in */; do
    if [ -d "$dir/.git" ]; then
        echo "------------------------------------------"
        echo "Checking: $dir"

        (
            cd "$dir" || exit

            # Fetch ล่าสุด
            git fetch --all --prune > /dev/null 2>&1

            # ตรวจสอบ Branch
            if git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH" || \
               git show-ref --verify --quiet "refs/remotes/origin/$TARGET_BRANCH"; then

                if [ "$FORCE_MODE" = true ]; then
                    echo "Result: Found. Force switching..."
                    # ใช้ -f ในคำสั่ง git checkout ตรงๆ
                    git checkout -f "$TARGET_BRANCH"
                else
                    echo "Result: Found. Switching..."
                    git checkout "$TARGET_BRANCH"
                fi

                # ถ้า Checkout สำเร็จ ให้ Pull ต่อ
                if [ $? -eq 0 ]; then
                    git pull origin "$TARGET_BRANCH"
                fi
            else
                echo -e "\033[0;33mResult: Branch '$TARGET_BRANCH' not found. Skipping.\033[0m"
            fi
        )
    fi
done

echo "------------------------------------------"
echo "Done!"