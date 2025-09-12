# 📁 YoFat 部落格檔案結構說明

## 📋 主要目錄結構

```
YoFat 部落格/
├── 🏠 主要頁面
│   ├── index.html          # 首頁
│   ├── posts.html          # 所有文章頁面
│   ├── categories.html     # 分類頁面
│   ├── tags.html           # 標籤頁面
│   └── search.html         # 搜尋頁面
├── 🛠️ tools/               # 工具資料夾
│   ├── quick-post.ps1      # 快速創建文章
│   ├── article-manager.ps1 # 全功能管理器
│   ├── drop-article.ps1    # 拖放處理工具
│   ├── manage-posts.ps1    # Windows 管理工具
│   ├── manage-posts.sh     # Linux/Mac 管理工具
│   └── README.md           # 工具說明文檔
├── 📝 _articles/           # 文章資料夾（推薦）
│   ├── 人工智能/
│   ├── 程式語言/
│   ├── 網頁開發/
│   ├── 生活分享/
│   ├── 教學/
│   ├── 功能項目/
│   ├── 工具分享/
│   └── 心得筆記/
├── 📄 _posts/              # 傳統文章資料夾
├── 🎨 assets/              # 靜態資源
│   ├── css/                # 樣式檔案
│   ├── js/                 # JavaScript 檔案
│   └── image/              # 圖片資源
├── ⚙️ _data/               # 資料檔案
├── 🧩 _includes/           # 模板片段
├── 📄 _layouts/            # 頁面佈局
└── 📚 說明文檔
    ├── QUICK-START.md      # 快速開始指南
    ├── FILES-GUIDE.md      # 本檔案
    └── _articles/README.md # 文章管理說明
```

## 🛠️ 工具使用指南

### 🚀 快速創建文章
```powershell
# 最快速的方式
.\tools\quick-post.ps1 -Title "我的文章" -Category "生活分享"

# 完整參數
.\tools\quick-post.ps1 -Title "Python 教學" -Category "教學" -Tags "Python,教學"
```

### 📦 全功能管理器
```powershell
.\tools\article-manager.ps1
```
提供功能：
- 🚀 快速創建文章
- 📁 批量處理文章
- 📋 列出所有文章
- 🔍 搜尋文章
- 🧹 清理空檔案
- 📊 文章統計

### 🎯 拖放處理
直接將 `.md` 檔案拖放到 `tools\drop-article.ps1`，自動處理並分類。

## 📝 文章管理系統

### 方式一：_articles 資料夾（推薦）
**特點：**
- ✅ 按分類組織，結構清晰
- ✅ 8 種分類涵蓋各種內容
- ✅ 每個分類有詳細說明
- ✅ 工具完整支援

**分類說明：**
- 🤖 **人工智能** - AI、機器學習、資料科學
- 💻 **程式語言** - 程式語言教學和技巧
- 🌐 **網頁開發** - 前端、後端、框架
- 🎯 **生活分享** - 個人經驗、日常記錄
- 📚 **教學** - 詳細教學指南和步驟教學
- 🔧 **功能項目** - 專案實作展示和功能開發
- 🛠️ **工具分享** - 實用工具推薦和資源分享
- 📝 **心得筆記** - 學習心得和技術筆記整理

### 方式二：_posts 資料夫（傳統）
**特點：**
- ✅ Jekyll 原生支援
- ✅ 檔案名稱：`YYYY-MM-DD-title.md`
- ⚠️ 所有文章在同一資料夾

## 🎯 建議工作流程

### 新手推薦流程
1. **創建文章**：`.\tools\quick-post.ps1`
2. **編輯內容**：用喜歡的編輯器編輯
3. **本地預覽**：`bundle exec jekyll serve`
4. **發布**：Git 提交推送

### 進階用戶流程
1. **管理工具**：`.\tools\article-manager.ps1`
2. **批量處理**：選項 2 處理舊文章
3. **統計分析**：選項 6 查看統計
4. **搜尋管理**：選項 4 搜尋文章

## 📊 各頁面功能

| 頁面 | 主要功能 | 特色 |
|------|----------|------|
| **index.html** | 首頁 | 最新文章、關於我、英雄圖片 |
| **posts.html** | 文章列表 | 年份時間軸、分類篩選、進度條 |
| **categories.html** | 分類瀏覽 | 左側 TOC、分類展開、統計數據 |
| **tags.html** | 標籤瀏覽 | 標籤雲、快速篩選、相關文章 |
| **search.html** | 搜尋功能 | 即時搜尋、建議功能、載入動畫 |

## 🎨 樣式和資源

### CSS 檔案
- `assets/css/main.css` - 主要樣式
- `assets/css/style.css` - 補充樣式

### JavaScript 檔案
- `assets/js/main.js` - 主要功能
- `assets/js/code-blocks.js` - 程式碼區塊高亮

### 圖片資源
- `assets/image/` - 存放所有圖片
- 支援 JPG、PNG、SVG 等格式

## 🔧 配置檔案

### Jekyll 配置
- `_config.yml` - 主要配置檔案
- `_data/categories.yml` - 分類定義
- `_data/tags.yml` - 標籤定義

### 佈局模板
- `_layouts/default.html` - 預設佈局
- `_layouts/post.html` - 文章佈局
- `_includes/` - 共用模板片段

## 💡 使用技巧

### 快速開始
```powershell
# 1. 創建第一篇文章
.\tools\quick-post.ps1 -Title "Hello World" -Category "生活分享"

# 2. 啟動本地伺服器
bundle exec jekyll serve

# 3. 瀏覽器打開 http://localhost:4000
```

### 文章管理
```powershell
# 查看所有工具功能
.\tools\article-manager.ps1

# 快速創建不同類型文章
.\tools\quick-post.ps1 -Title "React 教學" -Category "教學" -Tags "React,前端"
.\tools\quick-post.ps1 -Title "工具推薦" -Category "工具分享" -Tags "工具,效率"
```

### 內容組織
- 📚 **教學類**：放在 `_articles/教學/`
- 🔧 **專案類**：放在 `_articles/功能項目/`
- 🛠️ **工具類**：放在 `_articles/工具分享/`
- 📝 **心得類**：放在 `_articles/心得筆記/`

## 📖 學習資源

- 📘 `QUICK-START.md` - 新手入門必讀
- 📗 `tools/README.md` - 工具詳細說明
- 📙 `_articles/README.md` - 文章管理說明
- 📕 各分類 `README.md` - 分類寫作指南

---

🎉 **開始創建您的內容吧！**

```powershell
.\tools\quick-post.ps1 -Title "我的第一篇文章" -Category "生活分享" -Tags "開始,部落格"
```
