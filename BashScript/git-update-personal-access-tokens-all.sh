#!/bin/bash

# ================= CONFIGURATION =================
# Username ของคุณ
GIT_USER="pitt.p"
GIT_HOST="git.g-able.com"
# =================================================

# เคลียร์หน้าจอ
clear
echo "======================================================="
echo "   Auto Update Git Remote URL with New Token"
echo "   Host Target: $GIT_HOST"
echo "   User: $GIT_USER"
echo "======================================================="
echo ""

# รับค่า Token แบบซ่อนตัวอักษร
read -s -p "🔑 Please paste your new Personal Access Token (glpat-...): " GIT_TOKEN
echo ""

# เช็คว่ามีการกรอกข้อมูลมาไหม
if [ -z "$GIT_TOKEN" ]; then
    echo "❌ Error: Token cannot be empty!"
    exit 1
fi

echo ""
echo "🔄 Starting update process..."
echo "-------------------------------------------------------"

# วนลูปหาทุก sub-directory
for dir in */; do
    # ตัดเครื่องหมาย / ออกจากชื่อโฟลเดอร์
    dirname=${dir%/}

    # เช็คว่าเป็น Git Repo ไหม
    if [ -d "$dir/.git" ]; then

        # ใช้ subshell (...) เข้าไปทำงานแล้วออกมา
        (
            cd "$dir" || exit

            # ดึง URL ปัจจุบัน
            CURRENT_URL=$(git remote get-url origin)

            # เช็คว่าเป็น Repo ของ G-Able ไหม
            if [[ "$CURRENT_URL" == *"$GIT_HOST"* ]]; then

                # Logic: ดึง path ข้างหลังมา (ตัด git.g-able.com/ ออก)
                REPO_PATH=$(echo "$CURRENT_URL" | sed -E "s|.*$GIT_HOST[:/](.*)|\1|")

                # สร้าง URL ใหม่แบบฝัง Token
                NEW_URL="https://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST}/${REPO_PATH}"

                # สั่งเปลี่ยน URL
                git remote set-url origin "$NEW_URL"

                echo "✅ [$dirname] Updated successfully."
            else
                echo "⚠️  [$dirname] Skipped (Not hosted on $GIT_HOST)"
            fi
        )
    fi
    # (ลบ else ที่ว่างเปล่าทิ้งไปแล้ว เพื่อแก้ Syntax Error)
done

echo "-------------------------------------------------------"
echo "🎉 Process Completed!"
echo "   (Note: Try running 'git pull' in one of the updated folders to verify)"