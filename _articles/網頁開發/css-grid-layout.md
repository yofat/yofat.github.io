---
layout: post
title: CSS Grid 佈局完全指南
categories: [網頁開發, 前端技術]
tags: [CSS, 佈局, 響應式設計]
date: 2025-01-17
excerpt: 深入了解 CSS Grid 佈局系統，從基礎概念到實際應用
---

# CSS Grid 佈局完全指南

CSS Grid 是現代網頁佈局的強大工具，它提供了二維佈局系統，讓我們能夠更靈活地控制網頁元素的排列。

## 什麼是 CSS Grid？

CSS Grid Layout 是一種二維佈局方法，可以同時處理行和列。與 Flexbox 主要處理一維佈局不同，Grid 可以讓我們創建複雜的佈局結構。

### 基本概念

- **Grid Container**：設置了 `display: grid` 的父元素
- **Grid Items**：Grid Container 的直接子元素
- **Grid Lines**：分隔網格的線條
- **Grid Tracks**：相鄰兩條網格線之間的空間
- **Grid Areas**：由四條網格線圍成的區域

## 基本用法

### 創建網格容器

```css
.grid-container {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-template-rows: 100px 200px;
  gap: 20px;
}
```

### 定義網格線

```css
.grid-container {
  grid-template-columns: 
    [sidebar-start] 250px 
    [sidebar-end main-start] 1fr 
    [main-end];
}
```

## 實際應用：三欄佈局

讓我們看看如何創建一個典型的三欄佈局：

```css
.layout {
  display: grid;
  grid-template-columns: 260px 1fr 300px;
  grid-template-areas: 
    "sidebar main aside";
  gap: 1.5rem;
  min-height: 100vh;
}

.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.aside { grid-area: aside; }
```

### 響應式設計

```css
@media (max-width: 768px) {
  .layout {
    grid-template-columns: 1fr;
    grid-template-areas: 
      "main";
  }
  
  .sidebar,
  .aside {
    display: none;
  }
}
```

## 進階技巧

### 1. 自動調整列數

```css
.auto-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}
```

### 2. 網格對齊

```css
.centered-grid {
  display: grid;
  place-items: center;
  justify-content: center;
  align-content: center;
}
```

### 3. 不規則佈局

```css
.masonry-like {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  grid-auto-rows: max-content;
  gap: 1rem;
}

.item-large {
  grid-column: span 2;
}
```

## 實用範例

### 卡片佈局

```html
<div class="card-grid">
  <div class="card">卡片 1</div>
  <div class="card featured">特色卡片</div>
  <div class="card">卡片 3</div>
  <div class="card">卡片 4</div>
</div>
```

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.card.featured {
  grid-column: span 2;
  grid-row: span 2;
}
```

## 瀏覽器支援

CSS Grid 在現代瀏覽器中得到了廣泛支援：

- Chrome 57+
- Firefox 52+
- Safari 10.1+
- Edge 16+

## 總結

CSS Grid 是現代網頁佈局的核心技術，它提供了：

- **靈活性**：二維佈局控制
- **簡潔性**：減少複雜的 CSS 結構
- **響應式**：內建的響應式設計能力
- **維護性**：更容易理解和維護的代碼

掌握 CSS Grid，你就能創建出更加靈活和現代的網頁佈局！

## 延伸閱讀

- [MDN CSS Grid Layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout)
- [CSS Grid Garden](https://cssgridgarden.com/) - 互動學習遊戲
- [Grid by Example](https://gridbyexample.com/) - 實例集合
