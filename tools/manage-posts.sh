#!/bin/bash
# 文章管理腳本

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== YoFat 部落格文章管理工具 ===${NC}"
echo ""

# 顯示選項
echo "請選擇操作："
echo "1. 創建新文章 (articles 資料夾)"
echo "2. 創建新文章 (_posts 資料夾)"
echo "3. 列出所有文章"
echo "4. 檢查文章格式"
echo "5. 退出"
echo ""

read -p "請輸入選項 (1-5): " choice

case $choice in
  1)
    echo -e "${YELLOW}創建新文章 (articles 資料夾)${NC}"
    echo "可用分類："
    echo "- 人工智能"
    echo "- 程式語言" 
    echo "- 網頁開發"
    echo "- 生活分享"
    echo ""
    
    read -p "請選擇分類: " category
    read -p "請輸入文章標題: " title
    read -p "請輸入檔案名稱 (英文): " filename
    
    # 創建日期
    date=$(date +"%Y-%m-%d")
    
    # 創建文件路徑
    filepath="articles/${category}/${filename}.md"
    
    # 檢查目錄是否存在
    if [ ! -d "articles/${category}" ]; then
      echo -e "${RED}錯誤：分類目錄不存在${NC}"
      exit 1
    fi
    
    # 創建文章文件
    cat > "$filepath" << EOF
---
layout: post
title: ${title}
categories: [${category}]
tags: []
date: ${date}
excerpt: 
---

# ${title}

在這裡開始撰寫您的文章內容...

## 章節標題

文章內容

EOF
    
    echo -e "${GREEN}文章已創建：${filepath}${NC}"
    ;;
    
  2)
    echo -e "${YELLOW}創建新文章 (_posts 資料夾)${NC}"
    read -p "請輸入文章標題: " title
    read -p "請輸入檔案名稱 (英文): " filename
    
    # 創建日期
    date=$(date +"%Y-%m-%d")
    
    # 創建文件路徑
    filepath="_posts/${date}-${filename}.md"
    
    # 創建文章文件
    cat > "$filepath" << EOF
---
layout: post
title: ${title}
categories: []
tags: []
date: ${date}
excerpt: 
---

# ${title}

在這裡開始撰寫您的文章內容...

## 章節標題

文章內容

EOF
    
    echo -e "${GREEN}文章已創建：${filepath}${NC}"
    ;;
    
  3)
    echo -e "${YELLOW}所有文章列表：${NC}"
    echo ""
    echo -e "${BLUE}_posts 資料夾：${NC}"
    if [ -d "_posts" ]; then
      ls -la _posts/*.md 2>/dev/null || echo "無文章"
    fi
    echo ""
    echo -e "${BLUE}articles 資料夾：${NC}"
    if [ -d "articles" ]; then
      find articles -name "*.md" -type f 2>/dev/null || echo "無文章"
    fi
    ;;
    
  4)
    echo -e "${YELLOW}檢查文章格式...${NC}"
    echo ""
    
    # 檢查 _posts
    echo -e "${BLUE}檢查 _posts 資料夾：${NC}"
    for file in _posts/*.md; do
      if [ -f "$file" ]; then
        if head -1 "$file" | grep -q "---"; then
          echo -e "${GREEN}✓ $file${NC}"
        else
          echo -e "${RED}✗ $file (缺少 Front Matter)${NC}"
        fi
      fi
    done
    
    # 檢查 articles
    echo -e "${BLUE}檢查 articles 資料夾：${NC}"
    find articles -name "*.md" -type f | while read file; do
      if head -1 "$file" | grep -q "---"; then
        echo -e "${GREEN}✓ $file${NC}"
      else
        echo -e "${RED}✗ $file (缺少 Front Matter)${NC}"
      fi
    done
    ;;
    
  5)
    echo -e "${GREEN}再見！${NC}"
    exit 0
    ;;
    
  *)
    echo -e "${RED}無效選項${NC}"
    exit 1
    ;;
esac
