# YoFat 部落格

> 技術 × 人工智能 × 網路安全 × 筆記分享

---

## 🚀 快速開始

```powershell
bundle install
.\start.ps1
# 瀏覽器打開 http://localhost:4000
```

---

## 主要功能

- 一鍵啟動、響應式設計、亮暗色主題
- 全文搜尋、RSS Feed、自動目錄
- 文章分類、標籤、瀏覽數統計

---

## 管理工具

- `.\tools\master-tool.ps1`：主控台
- `.\tools\quick-post.ps1`：快速發文
- `.\tools\article-manager.ps1`：批量管理
- `.\tools\drop-article.ps1`：拖放導入
- `.\tools\manage-posts.ps1`：批次處理
- `.\tools\optimize-images.ps1`：圖片優化

---

## 內容分類

- 人工智能、程式語言、網頁開發、網路安全、教學、工具、心得

---

## 精選連結

- [首頁](https://yofat.github.io)
- [所有文章](https://yofat.github.io/posts.html)
- [分類](https://yofat.github.io/categories.html)
- [標籤](https://yofat.github.io/tags.html)
- [搜尋](https://yofat.github.io/search.html)
- [RSS Feed](https://yofat.github.io/feed.xml)

---


## 工具使用說明

- `tools/master-tool.ps1`：主控台，整合所有常用管理功能，依指示選單操作。
- `tools/quick-post.ps1`：快速建立新文章。
	- 範例：`./tools/quick-post.ps1 -Title "文章標題" -Category "分類"`
- `tools/article-manager.ps1`：批量管理現有文章（如批次分類、標籤、搬移等）。
- `tools/drop-article.ps1`：拖放 Markdown 檔案自動導入文章。
- `tools/manage-posts.ps1`：批次處理文章（如批量重命名、格式優化等）。
- `tools/optimize-images.ps1`：自動壓縮與優化 assets/image/ 內所有圖片。

---

## 相關教學文章

- [YoFat 部落格完整使用指南](https://yofat.github.io/教學/YoFat部落格完整使用指南/)
- [Jekyll 部落格環境安裝指南](https://yofat.github.io/教學/Jekyll部落格環境安裝指南/)
- [Jekyll 部落格完整開發指南](https://yofat.github.io/教學/Jekyll部落格完整開發指南/)
- [Git 完整教學指南](https://yofat.github.io/教學/Git完整教學指南/)
- [文章模板範例](https://yofat.github.io/技術/template-example/)

---

## 專案結構

```
_posts/      # 文章
_layouts/    # 模板
_includes/   # 組件
_data/       # 分類/標籤
assets/      # 靜態資源
tools/       # 工具
_config.yml  # 設定
start.ps1    # 啟動
```

---

## 技術棧

- Jekyll 4.3+ / GitHub Pages
- Rouge / Lunr.js / jekyll-feed
- PowerShell / SCSS

---

> 作者：[YoFat](https://github.com/yofat)｜MIT 授權