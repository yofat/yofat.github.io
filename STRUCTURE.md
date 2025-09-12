# YoFat's Blog - 資料結構說明

## 📁 目錄結構

```
yofat.github.io/
├── 📄 配置檔案
│   ├── _config.yml           # Jekyll 設定檔
│   ├── README.md            # 專案說明
│   └── search.json          # 搜尋索引
│
├── 🌐 頁面檔案
│   ├── index.html           # 首頁
│   ├── posts.html           # 文章列表
│   ├── categories.html      # 分類頁面
│   ├── tags.html           # 標籤頁面
│   ├── search.html         # 搜尋頁面
│   └── explore.html        # 探索頁面
│
├── 📝 內容資料
│   ├── _articles/          # 文章檔案 (Markdown)
│   │   ├── 人工智能/
│   │   ├── 功能項目/
│   │   ├── 工具分享/
│   │   ├── 心得筆記/       # (空目錄)
│   │   ├── 教學/
│   │   ├── 生活分享/
│   │   ├── 程式語言/
│   │   └── 網頁開發/
│   ├── _posts/             # Jekyll 標準文章目錄
│   └── _data/              # 資料檔案
│       ├── categories.yml
│       └── tags.yml
│
├── 🎨 版面設計
│   ├── _layouts/           # Jekyll 版面範本
│   │   ├── default.html
│   │   └── post.html
│   └── _includes/          # 可重用組件
│       ├── head.html
│       ├── header.html
│       └── footer.html
│
├── 🎯 靜態資源
│   └── assets/
│       ├── css/
│       │   └── main.css    # 主要樣式檔案
│       ├── js/
│       │   ├── main.js     # 主要 JavaScript
│       │   └── code-blocks.js
│       └── image/
│           ├── logo.png    # 標準 Logo
│           ├── logo.jpg    # 頭像用 Logo
│           ├── logo_transparent.png  # 透明版 Logo (光明模式)
│           ├── logo_inverted.png     # 反色版 Logo (黑暗模式)
│           ├── icon.png    # 網站圖示
│           └── banner.png  # 橫幅圖片
│
└── 🔧 工具腳本
    └── tools/
        ├── article-manager.ps1
        ├── drop-article.ps1
        ├── manage-posts.ps1
        ├── manage-posts.sh
        ├── master-tool.ps1
        ├── optimize-images.ps1
        └── quick-post.ps1
```

## 🎨 主題設計

### 配色方案
- **主色調**: 黑紅色系 (`#ff2b47` 血紅色, `#0d0d0f` 深黑色)
- **輔助色**: 藍色系 (`#00d4ff` 科技藍)
- **主題切換**: 支援亮色/暗色模式

### 版面設計
- **三欄式布局**: 左欄導航 + 中欄內容 + 右欄資訊
- **Hero 區域**: 佔滿寬度的標題區域
- **響應式設計**: 適配各種螢幕尺寸

## 🔧 功能特色

### JavaScript 功能
- Hero 標題動畫 (anime.js)
- 文章目錄 (TOC) 自動生成
- 主題切換 (亮色/暗色)
- 頁面瀏覽計數
- 滾動進度條

### 內容管理
- Markdown 文章支援
- 分類與標籤系統
- 搜尋功能
- 文章預覽

## 📱 技術棧

- **框架**: Jekyll (GitHub Pages)
- **樣式**: CSS Grid + Flexbox
- **動畫**: Anime.js
- **字型**: Inter, Noto Sans TC
- **圖示**: Emoji + 自訂圖片

## 🚀 部署資訊

- **託管**: GitHub Pages
- **網域**: yofat.github.io
- **分支**: main
- **自動部署**: GitHub Actions

---
*最後更新: 2025年9月12日*
