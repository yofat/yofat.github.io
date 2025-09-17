source "https://rubygems.org"

# 使用 GitHub Pages 相容的 Jekyll 版本
gem "github-pages", group: :jekyll_plugins

# Windows 時區資料支援
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Jekyll 插件 - 只保留 GitHub Pages 支援的插件
group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
  # jekyll-paginate 不支援，已移除
  # kramdown-parser-gfm 已經包含在 github-pages 中
end
