# Jekyll 部落格部署指南

## 🚀 部署方式

### 方式一：GitHub Pages（推薦 - 簡單）

1. **使用 GitHub Pages 支援的插件**
   - 你的 `Gemfile` 和 `_config.yml` 已經配置好了
   - 推送到 `main` 分支，GitHub Pages 會自動部署

2. **支援的插件**：
   - ✅ `jekyll-feed`
   - ✅ `jekyll-sitemap`
   - ✅ `jekyll-seo-tag`
   - ✅ `kramdown-parser-gfm` (GFM 支援)

3. **不支援的插件**：
   - ❌ `jekyll-paginate` (已移除)

### 方式二：GitHub Actions（推薦 - 功能完整）

1. **使用更多插件**
   - 已經創建了 `.github/workflows/jekyll.yml`
   - 可以支援所有 Jekyll 插件

2. **啟用方法**：
   - 進入 GitHub 倉庫的 Settings > Pages
   - 將 Source 改為 "GitHub Actions"

3. **支援的插件**：
   - 所有 Jekyll 插件都可以使用
   - 包括 `jekyll-paginate` 等

### 方式三：本地生成後推送

1. **本地生成靜態文件**
   ```bash
   # 使用完整功能的 Gemfile
   cp Gemfile.local Gemfile
   bundle install
   bundle exec jekyll build
   ```

2. **推送到 GitHub**
   ```bash
   git add .
   git commit -m "Update site"
   git push
   ```

## 📋 當前配置

### GitHub Pages 配置
- 使用 `github-pages` gem
- 只支援官方認可的插件
- 部署簡單快速

### GitHub Actions 配置
- 使用標準 Jekyll
- 支援所有插件
- 需要更多配置但功能完整

## 🔧 本地開發

```bash
# 安裝依賴
bundle install

# 本地預覽
bundle exec jekyll serve

# 生成靜態文件
bundle exec jekyll build
```

## 📝 注意事項

1. **插件相容性**：GitHub Pages 有插件限制
2. **部署時間**：GitHub Actions 可能需要 2-3 分鐘
3. **功能測試**：建議先在本地測試所有功能

選擇適合你的部署方式吧！🎉