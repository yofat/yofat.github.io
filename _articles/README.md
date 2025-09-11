# 文章管理說明

本站支援兩種文章管理方式：

## 方式一：傳統 Jekyll 方式（_posts 資料夾）

將文章放在 `_posts/` 資料夾中，檔案名稱格式：`YYYY-MM-DD-title.md`

```
_posts/
├── 2025-01-15-jekyll-blog-guide.md
├── 2025-01-16-javascript-advanced-techniques.md
└── 2025-09-10-hello-world.md
```

## 方式二：分類管理方式（_articles 資料夾）

將文章按分類放在 `_articles/` 資料夾中，更方便管理：

```
_articles/
├── 人工智能/
│   ├── python-data-science.md
│   └── machine-learning-basics.md
├── 程式語言/
│   ├── javascript-advanced.md
│   └── python-tips.md
├── 網頁開發/
│   ├── jekyll-blog-guide.md
│   └── css-grid-layout.md
├── 生活分享/
│   ├── reading-notes.md
│   └── travel-diary.md
├── 教學/
│   ├── python-tutorial.md
│   └── git-guide.md
├── 功能項目/
│   ├── blog-system.md
│   └── automation-script.md
├── 工具分享/
│   ├── vscode-extensions.md
│   └── useful-websites.md
└── 心得筆記/
    ├── learning-notes.md
    └── project-summary.md
```

## 📁 分類說明

### 🤖 人工智能
- AI 相關技術和應用
- 機器學習和深度學習
- 資料科學和分析
- AI 工具和框架

### 💻 程式語言
- 各種程式語言教學
- 語言特性和技巧
- 程式設計概念
- 語言比較和選擇

### 🌐 網頁開發
- 前端技術 (HTML, CSS, JavaScript)
- 後端開發技術
- 框架和函式庫
- 網站建置和部署

### 🎯 生活分享
- 個人經驗分享
- 日常生活記錄
- 興趣愛好相關
- 非技術性內容

### 📚 教學
- 詳細的教學指南
- 步驟式教學文章
- 從零開始的教學
- 實戰教學案例

### 🔧 功能項目
- 具體功能開發記錄
- 專案實作展示
- 工具開發分享
- 創意實作項目

### 🛠️ 工具分享
- 實用工具推薦
- 開發工具介紹
- 線上服務分享
- 效率工具整理

### 📝 心得筆記
- 學習心得體會
- 技術筆記整理
- 思考記錄分享
- 經驗總結回顧

## 文章模板

每篇文章開頭需要 Front Matter：

```yaml
---
layout: post
title: 文章標題
categories: [大分類, 子分類]
tags: [標籤1, 標籤2]
date: 2025-01-15
excerpt: 文章摘要（可選）
---

# 文章標題

文章內容...
```

## 注意事項

1. **檔案編碼**：請使用 UTF-8 編碼
2. **檔案名稱**：建議使用英文檔名，避免特殊字符
3. **圖片資源**：放在 `assets/image/` 資料夾中
4. **分類對應**：確保分類名稱與 `_data/categories.yml` 和 `_data/tags.yml` 一致

## 建議工作流程

1. 在對應分類資料夾中創建 `.md` 檔案
2. 填寫 Front Matter
3. 撰寫文章內容
4. 確認分類和標籤正確
5. 提交更新

這樣的結構讓您可以：
- 📁 按主題分類管理文章
- 🔍 快速找到相關文章
- 📝 更直觀的檔案組織
- 🏷️ 靈活的標籤系統

## 注意事項

⚠️ **重要**：`_articles` 資料夾中的文章需要 Jekyll 本地伺服器才能正確顯示。如果您是直接打開 HTML 檔案，請使用 `_posts` 資料夾。
