# 🛠️ 文章管理工具

這個資料夾包含所有用於管理部落格文章的工具腳本。

## 📋 工具清單

### Windows PowerShell 工具

| 工具名稱 | 功能說明 | 使用方式 | 推薦度 |
|----------|----------|----------|--------|
| **master-tool.ps1** | 🎯 統一管理工具 (推薦) | `.\tools\master-tool.ps1` | ⭐⭐⭐⭐⭐ |
| **quick-post.ps1** | 📝 快速創建文章 | `.\tools\quick-post.ps1 -Title "標題" -Category "分類"` | ⭐⭐⭐⭐ |
| **article-manager.ps1** | 📦 批量文章管理器 | `.\tools\article-manager.ps1` | ⭐⭐⭐⭐ |
| **drop-article.ps1** | 📁 拖放文章處理工具 | 拖拽 .md 檔案到此腳本 | ⭐⭐⭐ |

### Linux/Mac 工具

| 工具名稱 | 功能說明 | 使用方式 |
|----------|----------|----------|
| **manage-posts.sh** | Linux/Mac 文章管理 | `./tools/manage-posts.sh` |

## 🚀 快速開始

### 🎯 推薦方式：使用統一工具
```powershell
# 啟動主工具 (互動模式)
.\tools\master-tool.ps1

# 命令列模式 - 快速創建
.\tools\master-tool.ps1 -Action create -Title "我的文章" -Category "程式語言"

# 其他命令
.\tools\master-tool.ps1 -Action stats    # 顯示統計
.\tools\master-tool.ps1 -Action clean    # 清理空檔案
.\tools\master-tool.ps1 -Action search   # 搜尋文章
```
```

### 方法二：全功能管理器
```powershell
# Windows
.\tools\article-manager.ps1

# Linux/Mac
./tools/manage-posts.sh
```

### 方法三：拖放處理
1. 將 .md 檔案拖放到 `tools\drop-article.ps1`
2. 自動處理並分類

## 📚 詳細功能

### quick-post.ps1 - 快速創建工具
- ✅ 支援 8 種分類
- ✅ 自動生成檔案名稱
- ✅ 標準 Front Matter 格式
- ✅ 互動式或命令列模式

```powershell
# 互動模式
.\tools\quick-post.ps1

# 命令列模式
.\tools\quick-post.ps1 -Title "Python 教學" -Category "教學" -Tags "Python,教學"
```

### article-manager.ps1 - 全功能管理器
- 🚀 快速創建文章
- 📁 批量處理文章
- 📋 列出所有文章
- 🔍 搜尋文章功能
- 🧹 清理空檔案
- 📊 文章統計分析

### drop-article.ps1 - 拖放工具
- 📁 自動偵測文章格式
- 🏷️ 智能分類建議
- ✨ 自動添加 Front Matter
- 📝 格式標準化

## 🎯 支援的分類

1. **人工智能** - AI、機器學習、資料科學
2. **程式語言** - 程式語言教學和技巧
3. **網頁開發** - 前端、後端、框架
4. **生活分享** - 個人經驗、日常記錄
5. **教學** - 詳細教學指南
6. **功能項目** - 專案實作展示
7. **工具分享** - 實用工具推薦
8. **心得筆記** - 學習心得整理

## 💡 使用技巧

### 快速創建不同類型文章
```powershell
# 技術教學
.\tools\quick-post.ps1 -Title "React Hooks 教學" -Category "教學" -Tags "React,Hooks,教學"

# 專案展示
.\tools\quick-post.ps1 -Title "部落格系統開發" -Category "功能項目" -Tags "專案,React,Node.js"

# 工具推薦
.\tools\quick-post.ps1 -Title "VSCode 插件推薦" -Category "工具分享" -Tags "VSCode,插件,工具"

# 學習心得
.\tools\quick-post.ps1 -Title "學習 TypeScript 心得" -Category "心得筆記" -Tags "TypeScript,學習,心得"
```

### 批量處理舊文章
1. 執行 `.\tools\article-manager.ps1`
2. 選擇選項 2 "批量處理 _posts 資料夾"
3. 自動分類到適當的 `_articles` 資料夾

### 文章搜尋和統計
1. 執行 `.\tools\article-manager.ps1`
2. 選擇選項 4 "搜尋文章" 或選項 6 "文章統計"

## 🔧 安裝要求

### Windows
- PowerShell 5.1 或更高版本
- 執行原則設定：`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Linux/Mac
- Bash shell
- 執行權限：`chmod +x tools/manage-posts.sh`

## 📁 檔案結構

```
tools/
├── README.md              # 本說明檔案
├── quick-post.ps1         # 快速創建工具 (Windows)
├── article-manager.ps1    # 全功能管理器 (Windows)
├── drop-article.ps1       # 拖放處理工具 (Windows)
├── manage-posts.ps1       # 傳統管理工具 (Windows)
└── manage-posts.sh        # 管理工具 (Linux/Mac)
```

## 🎉 開始使用

立即試試創建您的第一篇文章：

```powershell
.\tools\quick-post.ps1 -Title "開始使用新工具" -Category "心得筆記" -Tags "工具,開始"
```
