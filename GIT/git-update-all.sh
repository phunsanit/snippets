#!/bin/bash

# วนลูปหาทุก sub-directory
for dir in */; do
    # เช็คว่าโฟลเดอร์นั้นเป็น Git Repo หรือไม่ (มี .git folder ไหม)
    if [ -d "$dir/.git" ]; then
        echo "=========================================="
        echo "Checking: $dir"

        # ใช้ subshell (...) เพื่อ cd เข้าไป pull แล้วกลับออกมาที่เดิมอัตโนมัติ
        (cd "$dir" && git pull)
    else
        echo "Skipping: $dir (Not a git repo)"
    fi
done
