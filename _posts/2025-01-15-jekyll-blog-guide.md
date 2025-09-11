---
layout: post
title: Jekyll 搭建個人博客完整指南
categories: [技術, 前端]
tags: [工具, Jekyll]
---

# Jekyll 搭建個人博客完整指南

Jekyll 是一個靜態網站生成器，非常適合用來建立個人博客。本文將詳細介紹如何從零開始搭建一個功能完整的 Jekyll 博客。

## 什麼是 Jekyll？

Jekyll 是一個用 Ruby 語言寫的靜態網站生成器，它可以將 Markdown 文件轉換成靜態 HTML 網站。Jekyll 的主要優勢包括：

- **免費託管**：可以直接部署到 GitHub Pages
- **快速載入**：生成的是靜態文件，載入速度快
- **易於維護**：使用 Markdown 寫作，版本控制友好
- **高度客製化**：支援 Liquid 模板引擎

## 環境準備

在開始之前，你需要安裝以下軟體：

1. **Ruby**（版本 2.7 或以上）
2. **RubyGems**
3. **Git**
4. **Text Editor**（推薦 VS Code）

## 建立 Jekyll 網站

### 1. 安裝 Jekyll

```bash
gem install jekyll bundler
```

### 2. 創建新網站

```bash
jekyll new my-blog
cd my-blog
```

### 3. 啟動本地服務器

```bash
bundle exec jekyll serve
```

## 目錄結構

一個典型的 Jekyll 網站結構如下：

```
_config.yml     # 配置文件
_posts/         # 博客文章
_layouts/       # 頁面布局
_includes/      # 可重用組件
_sass/          # Sass 樣式文件
assets/         # 靜態資源
index.html      # 首頁
```

## 配置文件

`_config.yml` 是 Jekyll 的核心配置文件：

```yaml
title: 我的技術博客
description: 分享程式設計經驗和學習心得
url: "https://username.github.io"
baseurl: ""

# 插件
plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-seo-tag

# Markdown 處理器
markdown: kramdown
highlighter: rouge
```

## 寫作格式

Jekyll 使用 YAML Front Matter 來定義文章的元數據：

```yaml
---
layout: post
title: 文章標題
date: 2025-01-01 12:00:00 +0800
categories: [技術, 教學]
tags: [Jekyll, 建站]
---
```

文章內容使用 Markdown 格式...

## 部署到 GitHub Pages

1. 在 GitHub 創建一個名為 `username.github.io` 的倉庫
2. 將本地代碼推送到 GitHub
3. 在倉庫設置中啟用 GitHub Pages

## 進階功能

### 搜尋功能

可以使用 Lunr.js 實現客戶端搜尋：

```javascript
// 建立搜尋索引
const idx = lunr(function () {
  this.ref('url');
  this.field('title');
  this.field('content');
  data.forEach(doc => this.add(doc));
});
```

### SEO 優化

安裝 `jekyll-seo-tag` 插件自動生成 SEO 標籤：

```html
{% raw %}{% seo %}{% endraw %}
```

### 評論系統

可以整合 Disqus 或 GitTalk 等評論系統。

## 總結

Jekyll 是一個功能強大且易於使用的靜態網站生成器。通過本文的介紹，你應該能夠：

1. 理解 Jekyll 的基本概念
2. 搭建自己的 Jekyll 博客
3. 配置和客製化網站
4. 部署到 GitHub Pages

開始你的 Jekyll 之旅吧！如果遇到問題，可以參考官方文檔或在社群中尋求幫助。
