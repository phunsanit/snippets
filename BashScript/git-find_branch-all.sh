#!/bin/bash

# รับค่า Keyword จาก Argument
SEARCH_TERM=$1

if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 <branch_keyword>"
    exit 1
fi

echo "Searching for branches containing: '$SEARCH_TERM'"

for dir in */; do
    # ตรวจสอบว่าเป็น Git Repo หรือไม่
    if [ -d "$dir/.git" ]; then
        echo "------------------------------------------"
        echo "Folder: $dir"

        (
            cd "$dir" || exit

            # อัปเดตข้อมูลจาก remote
            git fetch --all --prune > /dev/null 2>&1

            # ค้นหาทั้ง Local และ Remote (-a) และไม่สนตัวพิมพ์เล็กใหญ่ (grep -i)
            MATCHES=$(git branch -a | grep -i "$SEARCH_TERM" | sed 's/^[[:space:]]*//')

            if [ -z "$MATCHES" ]; then
                echo "Result: Not found."
            else
                echo "Found:"
                # แสดงผลแบบสีเขียวเพื่อให้สังเกตง่าย
                echo -e "\033[0;32m$MATCHES\033[0m"
            fi
        )
    fi
done

echo "------------------------------------------"
echo "Search complete."