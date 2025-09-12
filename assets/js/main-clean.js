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
  // === Hero 標題動畫 ===
  const heroSpans = document.querySelectorAll("#hero-title span");
  if (heroSpans.length > 0) {
    anime({
      targets: heroSpans,
      opacity: [0, 1],
      translateY: [30, 0],
      delay: anime.stagger(200),
      duration: 1000,
      easing: "easeOutExpo"
    });
  }

  // === TOC 生成（只在文章頁面） ===
  const tocRoot = document.getElementById("toc");
  const scope = document.querySelector(".main-content");
  const isPostPage = document.body.classList.contains('grid-page') || document.querySelector('article.post-article');
  
  if (tocRoot && scope && isPostPage) {
    const headings = scope.querySelectorAll("article h1, article h2, article h3, .post-content h1, .post-content h2, .post-content h3");
    
    if (headings.length === 0) {
      tocRoot.innerHTML = '<p class="toc-empty">本文暂无目录</p>';
      return;
    }

    // 為標題添加 ID
    headings.forEach((heading, index) => {
      if (!heading.id) {
        heading.id = `heading-${index}`;
      }
    });

    // 創建 TOC 標題
    const tocHeader = document.createElement("div");
    tocHeader.className = "toc-header";
    tocHeader.innerHTML = '<h4 class="toc-title">📖 文章目錄</h4>';
    
    // 全部展開/收縮按鈕
    const toggleAll = document.createElement("span");
    toggleAll.className = "toc-toggle";
    toggleAll.textContent = "全部展開";
    toggleAll.addEventListener("click", () => {
      const isExpanded = toggleAll.textContent === "全部收縮";
      const allChildren = tocRoot.querySelectorAll(".toc-children");
      const allIcons = tocRoot.querySelectorAll(".toc-h1-icon");
      
      allChildren.forEach(child => {
        if (isExpanded) {
          child.classList.remove("expanded");
        } else {
          child.classList.add("expanded");
        }
      });
      
      allIcons.forEach(icon => {
        if (isExpanded) {
          icon.classList.remove("expanded");
        } else {
          icon.classList.add("expanded");
        }
      });
      
      toggleAll.textContent = isExpanded ? "全部展開" : "全部收縮";
    });
    tocHeader.appendChild(toggleAll);
    tocRoot.appendChild(tocHeader);

    // 生成層級結構
    const structure = [];
    let currentH1 = null;
    
    headings.forEach(h => {
      if (h.tagName === "H1") {
        currentH1 = { heading: h, children: [] };
        structure.push(currentH1);
      } else if (currentH1) {
        currentH1.children.push(h);
      }
    });
    
    // 建立 DOM 結構
    structure.forEach(item => {
      const h1Item = document.createElement("div");
      h1Item.className = "toc-h1-item";
      
      // H1 切換按鈕
      const toggle = document.createElement("div");
      toggle.className = "toc-h1-toggle";
      
      const icon = document.createElement("span");
      icon.className = "toc-h1-icon";
      icon.innerHTML = "▶";
      
      const text = document.createElement("span");
      text.className = "toc-h1-text";
      text.textContent = item.heading.textContent;
      
      toggle.appendChild(icon);
      toggle.appendChild(text);
      
      // H1 點擊事件
      toggle.addEventListener("click", (e) => {
        e.preventDefault();
        
        const targetPosition = item.heading.getBoundingClientRect().top + window.pageYOffset - 80;
        window.scrollTo({
          top: targetPosition,
          behavior: "smooth"
        });
        
        history.replaceState(null, "", `#${item.heading.id}`);
        
        // 切換折疊狀態
        const children = h1Item.querySelector(".toc-children");
        const isExpanded = children && children.classList.contains("expanded");
        
        if (children) {
          children.classList.toggle("expanded");
          icon.classList.toggle("expanded");
        }
      });
      
      h1Item.appendChild(toggle);
      
      // 子項目容器
      if (item.children.length > 0) {
        const childrenContainer = document.createElement("div");
        childrenContainer.className = "toc-children";
        
        item.children.forEach(child => {
          const link = document.createElement("a");
          link.href = `#${child.id}`;
          link.textContent = child.textContent;
          link.className = "toc-link";
          link.setAttribute("data-level", child.tagName.toLowerCase().slice(1));
          
          link.addEventListener("click", (e) => {
            e.preventDefault();
            const targetPosition = child.getBoundingClientRect().top + window.pageYOffset - 80;
            
            window.scrollTo({
              top: targetPosition,
              behavior: "smooth"
            });
            
            history.replaceState(null, "", `#${child.id}`);
          });
          
          childrenContainer.appendChild(link);
        });
        
        h1Item.appendChild(childrenContainer);
      }
      
      tocRoot.appendChild(h1Item);
    });

    // Scrollspy：高亮目前章節
    const allLinks = tocRoot.querySelectorAll("a, .toc-h1-toggle");
    const linkMap = new Map();
    
    // 建立 ID 到元素的映射
    headings.forEach(h => {
      if (h.tagName === "H1") {
        const toggle = Array.from(allLinks).find(el => 
          el.classList.contains("toc-h1-toggle") && 
          el.querySelector(".toc-h1-text").textContent === h.textContent
        );
        if (toggle) linkMap.set(h.id, toggle);
      } else {
        const link = Array.from(allLinks).find(el => 
          el.getAttribute && el.getAttribute("href") === `#${h.id}`
        );
        if (link) linkMap.set(h.id, link);
      }
    });
    
    const observer = new IntersectionObserver(entries => {
      entries.forEach(en => {
        if (en.isIntersecting) {
          const link = linkMap.get(en.target.id);
          if (link) {
            // 移除所有活動狀態
            allLinks.forEach(l => l.classList.remove("active"));
            // 添加當前活動狀態
            link.classList.add("active");
            
            // 如果是 H2/H3，自動展開父級 H1
            if (en.target.tagName !== "H1") {
              const parentH1 = Array.from(headings).find(h => 
                h.tagName === "H1" && h.compareDocumentPosition(en.target) & Node.DOCUMENT_POSITION_FOLLOWING
              );
              if (parentH1) {
                const parentToggle = linkMap.get(parentH1.id);
                if (parentToggle) {
                  const parentItem = parentToggle.closest(".toc-h1-item");
                  const children = parentItem.querySelector(".toc-children");
                  const icon = parentToggle.querySelector(".toc-h1-icon");
                  
                  if (children && !children.classList.contains("expanded")) {
                    children.classList.add("expanded");
                    icon.classList.add("expanded");
                  }
                }
              }
            }
          }
        }
      });
    }, { rootMargin: "0px 0px -70% 0px", threshold: 0.1 });
    
    headings.forEach(h => observer.observe(h));
  }

  // === 主題切換 ===
  const toggleBtn = document.getElementById("theme-toggle");
  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      document.documentElement.classList.toggle("light");
      toggleBtn.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
      
      // 切換右欄頭像
      updateProfileAvatar();
    });
  }
  
  // 初始化時設置正確的頭像
  updateProfileAvatar();
});

// === 更新個人頭像根據主題 ===
function updateProfileAvatar() {
  const profileAvatar = document.getElementById("profile-avatar");
  if (profileAvatar) {
    const isLightTheme = document.documentElement.classList.contains("light");
    profileAvatar.src = isLightTheme 
      ? "/assets/image/logo_transparent.png" 
      : "/assets/image/logo_inverted.png";
  }
}
