# 🚀 YoFat 部落格 - 超快文章管理系統

## 📁 新的檔案結構

```
YoFat 部落格/
├── 🚀 tools/                     # 工具資料夾
│   ├── article-manager.ps1       # 主要管理工具
│   ├── quick-post.ps1            # 快速創建文章
│   ├── drop-article.ps1          # 拖放文章工具
│   └── README.md                 # 工具說明
├── _articles/                    # 文章資料夾
│   ├── 人工智能/
│   ├── 程式語言/
│   ├── 網頁開發/
│   └── 生活分享/
└── _posts/                       # 舊文章(可刪除)
```

## 🎯 三種超快創建文章的方法

### 方法一：一鍵快速創建 ⚡
```powershell
# 互動式創建
.\tools\quick-post.ps1

# 直接指定參數
.\tools\quick-post.ps1 -Title "Python 教學" -Category "程式語言" -Tags "Python,教學"

# 查看說明
.\tools\quick-post.ps1 -Help
```

### 方法二：拖放文章 📁
1. 將任何 `.md` 檔案拖放到 `tools\drop-article.ps1`
2. 自動處理並分類
3. 沒有 Front Matter 會自動添加

### 方法三：全功能管理器 🚀
```powershell
.\tools\article-manager.ps1
```
功能包括：
- 快速創建文章
- 批量處理舊文章
- 文章搜尋
- 統計分析
- 清理工具

## 📝 文章格式

每篇文章都會自動添加標準 Front Matter：

```yaml
---
layout: post
title: 文章標題
categories: [分類]
tags: ["標籤1", "標籤2"]
date: 2025-01-17
excerpt: 
---

# 文章標題

文章內容...
```

## 🎨 分類說明

| 分類 | 適用內容 | 範例 |
|------|----------|------|
| **人工智能** | AI、機器學習、深度學習 | Python 資料科學、TensorFlow |
| **程式語言** | 程式語言教學、技巧 | JavaScript、Python 技巧 |
| **網頁開發** | 前端、後端、框架 | React、CSS、Jekyll |
| **生活分享** | 心得、筆記、雜談 | 閱讀心得、生活感想 |
| **教學** | 詳細教學指南、步驟教學 | Python 入門、Git 教學 |
| **功能項目** | 專案實作、功能開發 | 部落格系統、自動化腳本 |
| **工具分享** | 實用工具、資源推薦 | VSCode 插件、線上工具 |
| **心得筆記** | 學習心得、技術筆記 | 學習記錄、專案總結 |

## 🚀 快速上手

### 1. 立即創建第一篇文章
```powershell
.\tools\quick-post.ps1 -Title "我的第一篇文章" -Category "生活分享"
```

### 2. 啟動本地預覽
```bash
bundle exec jekyll serve
```

### 3. 查看結果
- 首頁：http://localhost:4000
- 所有文章：http://localhost:4000/posts.html
- 分類頁：http://localhost:4000/categories.html

## 💡 實用技巧

### 快速模板
```powershell
# 技術文章
.\tools\quick-post.ps1 -Title "技術標題" -Category "程式語言" -Tags "技術,教學"

# AI 文章  
.\tools\quick-post.ps1 -Title "AI 標題" -Category "人工智能" -Tags "AI,機器學習"

# 網頁開發
.\tools\quick-post.ps1 -Title "網頁標題" -Category "網頁開發" -Tags "前端,CSS"

# 教學文章
.\tools\quick-post.ps1 -Title "教學標題" -Category "教學" -Tags "教學,指南"

# 功能項目
.\tools\quick-post.ps1 -Title "專案標題" -Category "功能項目" -Tags "專案,實作"

# 工具分享
.\tools\quick-post.ps1 -Title "工具標題" -Category "工具分享" -Tags "工具,推薦"

# 心得筆記
.\tools\quick-post.ps1 -Title "心得標題" -Category "心得筆記" -Tags "心得,學習"
```

### 批量處理
如果您有很多舊的 `.md` 檔案：
1. 執行 `.\tools\article-manager.ps1`
2. 選擇 "批量處理 _posts 資料夾"
3. 自動分類到適當的資料夾

### 文章管理
```powershell
# 查看所有文章
.\tools\article-manager.ps1  # 選項 3

# 搜尋文章
.\tools\article-manager.ps1  # 選項 4

# 文章統計
.\tools\article-manager.ps1  # 選項 6
```

## 🎉 優勢特點

✅ **超快創建**：一條命令創建文章  
✅ **自動分類**：智能分類到合適資料夾  
✅ **拖放支援**：直接拖拽檔案  
✅ **批量處理**：一次處理多個檔案  
✅ **搜尋功能**：快速找到文章  
✅ **統計分析**：了解創作狀況  
✅ **自動格式**：標準化 Front Matter  

## 📚 常見問題

### Q: 如何修改現有文章？
A: 直接編輯 `_articles/分類/檔案.md`

### Q: 如何刪除舊的 _posts 資料夾？
A: 確認文章都移動後，可以安全刪除

### Q: 如何添加新分類？
A: 在 `_articles/` 下創建新資料夾，並更新工具腳本

### Q: 如何備份文章？
A: 整個 `_articles/` 資料夾就是您的文章庫

---

**🎯 現在就開始創作吧！**

```powershell
# 創建您的第一篇文章
.\tools\quick-post.ps1 -Title "開始使用新系統" -Category "生活分享" -Tags "部落格,開始"
```
