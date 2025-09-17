// YoFat's Blog - Main JavaScript
// 簡潔乾淨的主要功能

// === 計數器功能 ===
(function(){
  const NAMESPACE = (window.__COUNT_NS__) || (location.hostname || 'localhost');
  function hit(key){
    fetch(`https://api.countapi.xyz/hit/${encodeURIComponent(NAMESPACE)}/${encodeURIComponent(key)}`).catch(()=>{});
  }
  function get(key){
    return fetch(`https://api.countapi.xyz/get/${encodeURIComponent(NAMESPACE)}/${encodeURIComponent(key)}`).then(r=>r.json());
  }

  // 全站總計
  hit("site:total");

  // 單篇文章
  const article = document.querySelector('article.post');
  if (article) {
    const key = article.getAttribute('data-count-key');
    hit(key);
    get(key).then(j=>{
      const el = document.getElementById('view-count');
      if (el) el.textContent = j?.value ?? 0;
    }).catch(()=>{});
  }
})();

document.addEventListener("DOMContentLoaded", () => {
  // === 滾動進度條 ===
  const progressTop = document.getElementById('scroll-progress-top');
  const progressBottom = document.getElementById('scroll-progress-bottom');
  
  function updateProgress() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const docHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrollPercent = (scrollTop / docHeight) * 100;
    
    if (progressTop) {
      progressTop.style.width = scrollPercent + '%';
    }
    if (progressBottom) {
      progressBottom.style.width = scrollPercent + '%';
      progressBottom.style.opacity = scrollPercent > 10 ? '1' : '0';
    }
  }
  
  window.addEventListener('scroll', updateProgress);
  updateProgress();

  // === Hero 標題動畫 ===
  const heroSpans = document.querySelectorAll("#hero-title span");
  if (heroSpans.length > 0) {
    anime({
      targets: heroSpans,
      opacity: [0, 1],
      translateY: [30, 0],
      delay: anime.stagger(300), // 增加延遲讓每個部分更明顯
      duration: 1200,
      easing: "easeOutExpo"
    });
  }

  // === 文章連結功能 ===
  const articleLinks = document.querySelectorAll('.article-link, .btn-primary');
  articleLinks.forEach(link => {
    if (link.href && link.href.includes('/posts.html')) {
      link.addEventListener('click', (e) => {
        // 確保連結正常工作
        window.location.href = link.href;
      });
    }
  });

  // === TOC 生成（HackMD 風格） ===
  const tocRoot = document.getElementById("toc-nav");
  const scope = document.querySelector(".post-content");
  const isPostPage = document.body.classList.contains('post-page') || document.querySelector('article.post-article') || document.body.classList.contains('layout-post');

  // 首頁不顯示 TOC
  if (tocRoot && !isPostPage) {
    return;
  }

  if (tocRoot && scope && isPostPage) {
    const headings = scope.querySelectorAll("h1, h2, h3");

    if (headings.length === 0) {
      tocRoot.innerHTML = '<p class="toc-empty">本文暂无目录</p>';
      return;
    }

    // 清除現有內容
    tocRoot.innerHTML = '';

    // 創建控制按鈕區域 - 文字形式
    const tocControls = document.createElement("div");
    tocControls.className = "toc-controls";

    // 全部展開文字鏈接
    const expandAllLink = document.createElement("a");
    expandAllLink.className = "toc-control-btn";
    expandAllLink.textContent = "展開全部";
    expandAllLink.href = "#";
    expandAllLink.addEventListener("click", (e) => {
      e.preventDefault();
      toggleAllItems(true);
      updateControlButtons();
    });

    // 全部收起文字鏈接
    const collapseAllLink = document.createElement("a");
    collapseAllLink.className = "toc-control-btn";
    collapseAllLink.textContent = "收起全部";
    collapseAllLink.href = "#";
    collapseAllLink.addEventListener("click", (e) => {
      e.preventDefault();
      toggleAllItems(false);
      updateControlButtons();
    });

    // 回到頂部文字鏈接
    const backToTopLink = document.createElement("a");
    backToTopLink.className = "toc-control-btn";
    backToTopLink.textContent = "回到頂部";
    backToTopLink.href = "#";
    backToTopLink.addEventListener("click", (e) => {
      e.preventDefault();
      window.scrollTo({ top: 0, behavior: "smooth" });
    });

    tocControls.appendChild(expandAllLink);
    tocControls.appendChild(collapseAllLink);
    tocControls.appendChild(backToTopLink);

    // 創建 TOC 列表容器
    const tocList = document.createElement("ul");
    tocList.className = "toc-list";

    // 存儲所有 TOC 項目以便控制
    const tocItems = [];
    let currentH1Item = null;

    headings.forEach((heading, index) => {
      const headingText = heading.textContent.trim();
      const headingLevel = parseInt(heading.tagName.charAt(1));

      // 總是重新生成 ID，使用標題文字而不是 Jekyll 生成的 ID
      // 將標題文字轉換為 URL 友好的格式
      let slug = headingText
        .toLowerCase()
        .replace(/[^\w\s-]/g, '') // 移除特殊字符
        .replace(/\s+/g, '-') // 將空格轉為連字符
        .replace(/-+/g, '-') // 移除多餘的連字符
        .replace(/^-|-$/g, ''); // 移除開頭和結尾的連字符

      // 如果 slug 為空，使用默認格式
      if (!slug) {
        slug = `heading-${index}`;
      }

      // 確保唯一性
      let uniqueSlug = slug;
      let counter = 1;
      const existingIds = Array.from(document.querySelectorAll('[id]')).map(el => el.id);
      while (existingIds.includes(uniqueSlug)) {
        uniqueSlug = `${slug}-${counter}`;
        counter++;
      }

      heading.id = uniqueSlug;

      // 創建列表項目
      const listItem = document.createElement("li");
      listItem.className = `toc-item toc-level-${headingLevel}`;

      // 創建鏈接
      const link = document.createElement("a");
      link.href = `#${heading.id}`;
      link.className = "toc-link";
      link.textContent = headingText;
      link.setAttribute("data-level", headingLevel);

      // HackMD 風格的字體大小
      if (headingLevel === 1) {
        link.style.fontSize = "14px";
        link.style.fontWeight = "600";
        link.style.paddingLeft = "24px";
      } else if (headingLevel === 2) {
        link.style.fontSize = "13px";
        link.style.fontWeight = "500";
        link.style.paddingLeft = "48px";
      } else if (headingLevel === 3) {
        link.style.fontSize = "12px";
        link.style.fontWeight = "400";
        link.style.paddingLeft = "72px";
        link.style.color = "var(--text-tertiary)";
      }

      // 點擊事件
      link.addEventListener("click", (e) => {
        e.preventDefault();
        const targetPosition = heading.getBoundingClientRect().top + window.pageYOffset - 80;

        window.scrollTo({
          top: targetPosition,
          behavior: "smooth"
        });

        history.replaceState(null, "", `#${heading.id}`);
      });

      listItem.appendChild(link);

      // 處理階層結構
      if (headingLevel === 1) {
        // H1 作為頂級項目
        tocList.appendChild(listItem);
        currentH1Item = { element: listItem, level: 1, children: [] };
        tocItems.push(currentH1Item);
      } else {
        // H2/H3 作為子項目
        if (currentH1Item) {
          if (!currentH1Item.childrenContainer) {
            currentH1Item.childrenContainer = document.createElement("ul");
            currentH1Item.childrenContainer.className = "toc-children";
            currentH1Item.element.appendChild(currentH1Item.childrenContainer);
          }
          currentH1Item.childrenContainer.appendChild(listItem);
          currentH1Item.children.push({ element: listItem, level: headingLevel });
        } else {
          // 如果沒有父級 H1，直接添加到主列表
          tocList.appendChild(listItem);
        }
      }
    });

    // 先添加列表，然後添加控制按鈕在底部
    tocRoot.appendChild(tocList);
    tocRoot.appendChild(tocControls);

    // 控制按鈕狀態更新函數
    function updateControlButtons() {
      const hasExpanded = tocRoot.querySelector('.toc-children.expanded') !== null;
      const hasCollapsed = tocRoot.querySelector('.toc-children:not(.expanded)') !== null;

      // 更新文字鏈接的樣式
      expandAllLink.style.opacity = hasExpanded ? "0.5" : "1";
      collapseAllLink.style.opacity = hasCollapsed ? "1" : "0.5";
    }

    // 全部展開/收起功能
    function toggleAllItems(expand) {
      const childrenContainers = tocRoot.querySelectorAll('.toc-children');
      childrenContainers.forEach(container => {
        if (expand) {
          container.classList.add('expanded');
        } else {
          container.classList.remove('expanded');
        }
      });
    }

    // 初始化控制按鈕狀態
    updateControlButtons();

    // Scrollspy：高亮目前章節並自動展開/收起
    const allLinks = tocRoot.querySelectorAll(".toc-link");
    let currentActiveH1 = null; // 追蹤當前活躍的 H1

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // 移除所有活動狀態
          allLinks.forEach(link => link.classList.remove("active"));

          // 找到對應的鏈接並高亮
          const targetLink = Array.from(allLinks).find(link =>
            link.getAttribute("href") === `#${entry.target.id}`
          );

          if (targetLink) {
            targetLink.classList.add("active");

            // 處理階層展開/收起邏輯
            const currentLevel = parseInt(targetLink.getAttribute("data-level"));
            const tocItem = targetLink.closest('.toc-item');

            if (currentLevel === 1) {
              // 如果是新的 H1，收起之前活躍的 H1
              if (currentActiveH1 && currentActiveH1 !== tocItem) {
                const prevChildren = currentActiveH1.querySelector('.toc-children');
                if (prevChildren && prevChildren.classList.contains('expanded')) {
                  prevChildren.classList.remove('expanded');
                }
              }

              // 設置新的活躍 H1
              currentActiveH1 = tocItem;

              // 展開當前 H1 的所有子項目
              const childrenContainer = tocItem.querySelector('.toc-children');
              if (childrenContainer && !childrenContainer.classList.contains('expanded')) {
                childrenContainer.classList.add('expanded');
                updateControlButtons();
              }
            } else if (currentLevel === 2) {
              // 如果是 H2，確保其父級 H1 已展開
              const parentH1 = tocItem.closest('.toc-list > .toc-item');
              if (parentH1) {
                // 如果父級 H1 不是當前活躍的，切換到這個 H1
                if (currentActiveH1 !== parentH1) {
                  // 收起之前活躍的 H1
                  if (currentActiveH1) {
                    const prevChildren = currentActiveH1.querySelector('.toc-children');
                    if (prevChildren && prevChildren.classList.contains('expanded')) {
                      prevChildren.classList.remove('expanded');
                    }
                  }

                  // 設置新的活躍 H1
                  currentActiveH1 = parentH1;
                }

                // 展開當前 H1 的子項目
                const parentChildren = parentH1.querySelector('.toc-children');
                if (parentChildren && !parentChildren.classList.contains('expanded')) {
                  parentChildren.classList.add('expanded');
                  updateControlButtons();
                }
              }
            }
            // H3 不需要特殊處理，因為其父級已經展開
          }
        }
      });
    }, {
      rootMargin: "0px 0px -70% 0px",
      threshold: 0.1
    });

    headings.forEach(h => observer.observe(h));
  }

  // === 滾動進度條 ===
  const scrollProgressTop = document.getElementById('scroll-progress-top');
  const scrollProgressBottom = document.getElementById('scroll-progress-bottom');
  
  if (scrollProgressTop || scrollProgressBottom) {
    window.addEventListener('scroll', () => {
      const scrollTop = window.scrollY;
      const documentHeight = document.documentElement.scrollHeight - window.innerHeight;
      const scrollPercent = (scrollTop / documentHeight) * 100;
      
      if (scrollProgressTop) {
        scrollProgressTop.style.width = scrollPercent + '%';
      }
      
      if (scrollProgressBottom) {
        scrollProgressBottom.style.width = scrollPercent + '%';
        scrollProgressBottom.style.opacity = scrollPercent > 10 ? '1' : '0';
      }
    });
  }
});

// === 主題切換 ===
// 因為 defer 腳本在 DOMContentLoaded 之後執行，所以不使用 DOMContentLoaded 事件
const toggleBtn = document.getElementById("theme-toggle");
const themeIcon = document.getElementById("theme-icon");

if (toggleBtn) {
  toggleBtn.addEventListener("click", () => {
    document.documentElement.classList.toggle("light");
    
    // 更新圖標
    if (themeIcon) {
      themeIcon.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
    } else {
      toggleBtn.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
    }
    
    // 保存主題偏好到 localStorage
    const currentTheme = document.documentElement.classList.contains("light") ? "light" : "dark";
    localStorage.setItem("theme", currentTheme);
    
    // 切換右欄頭像
    updateProfileAvatar();
  });
}

// 載入儲存的主題偏好
const savedTheme = localStorage.getItem("theme");
if (savedTheme === "light") {
  document.documentElement.classList.add("light");
}

// 初始化時設置正確的圖標
if (themeIcon) {
  themeIcon.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
} else if (toggleBtn) {
  toggleBtn.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
}

// 初始化時設置正確的頭像
updateProfileAvatar();

// === 更新個人頭像根據主題 ===
function updateProfileAvatar() {
  const profileAvatar = document.querySelector(".profile-avatar");
  if (profileAvatar) {
    const isLightTheme = document.documentElement.classList.contains("light");
    profileAvatar.src = isLightTheme 
      ? "/assets/image/banner.png" 
      : "/assets/image/logo_inverted.png";
  }
}
