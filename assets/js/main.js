// --- anime.js hero 動畫 + 粒子 ---
document.addEventListener('DOMContentLoaded', () => {
  const title = document.getElementById('hero-title');
  if (title) {
    anime({ targets: '#hero-title', translateY: [-12, 0], opacity: [0,1], duration: 1200, easing: 'easeOutExpo' });
  }
  const canvas = document.getElementById('hero-particles');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    const w = canvas.width = canvas.offsetWidth, h = canvas.height;
    const dots = Array.from({length: 60}, ()=>({ x: Math.random()*w, y: Math.random()*h, r: Math.random()*2+0.5, vx:(Math.random()-0.5)*0.6, vy:(Math.random()-0.5)*0.6 }));
    function draw(){
      ctx.clearRect(0,0,w,h);
      dots.forEach(d=>{
        d.x+=d.vx; d.y+=d.vy;
        if(d.x<0||d.x>w) d.vx*=-1; if(d.y<0||d.y>h) d.vy*=-1;
        ctx.beginPath(); ctx.arc(d.x,d.y,d.r,0,Math.PI*2); ctx.fillStyle='rgba(110,231,183,0.6)'; ctx.fill();
      });
      requestAnimationFrame(draw);
    } draw();
  }
});

// --- 免費 countapi：總站與每篇文章計數 ---
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

// --- GitHub stars 備援（若 buttons.js 顯示失敗，抓 API 顯示數字） ---
(function(){
  const el = document.querySelector('.github-star');
  if (!el) return;
  setTimeout(() => {
    // 若 3 秒後 GitHub Button 還沒 render，顯示備援
    if (!el.querySelector('iframe')) {
      const owner = document.documentElement.dataset.owner || "{{ site.github_owner }}";
      const repo  = document.documentElement.dataset.repo  || "{{ site.github_repo }}";
      fetch(`https://api.github.com/repos/${owner}/${repo}`).then(r=>r.json()).then(j=>{
        const s = document.createElement('span');
        s.textContent = `⭐ ${j.stargazers_count ?? ''}`;
        el.appendChild(s);
      }).catch(()=>{});
    }
  }, 3000);
})();

document.addEventListener("DOMContentLoaded", () => {
  // Hero title animation: 每個 span 逐一淡入
  const spans = document.querySelectorAll("#hero-title span");
  if (spans.length > 0) {
    anime({
      targets: spans,
      opacity: [0, 1],
      translateY: [30, 0],
      delay: anime.stagger(200),
      duration: 1000,
      easing: "easeOutExpo"
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  // === Hero title：逐字淡入 ===
  const spans = document.querySelectorAll("#hero-title span");
  if (spans.length) {
    anime({
      targets: spans,
      opacity: [0, 1],
      translateY: [30, 0],
      delay: anime.stagger(200),
      duration: 1000,
      easing: "easeOutExpo"
    });
  }

  // === 自動產生 HackMD 風格的可折疊 TOC ===
  const tocRoot = document.getElementById("toc");
  const scope = document.querySelector(".maincol");
  if (tocRoot && scope) {
    const headings = scope.querySelectorAll("h1, h2, h3");
    const ids = new Set();
    
    // 創建全部展開/收縮按鈕
    const tocHeader = tocRoot.parentElement.querySelector("h3");
    if (tocHeader) {
      const toggleAll = document.createElement("span");
      toggleAll.className = "toc-toggle";
      toggleAll.textContent = "全部展開";
      toggleAll.addEventListener("click", () => {
        const isExpanded = toggleAll.textContent === "全部收縮";
        const h1Items = tocRoot.querySelectorAll(".toc-h1-item");
        h1Items.forEach(item => {
          const children = item.querySelector(".toc-children");
          const icon = item.querySelector(".toc-h1-icon");
          if (isExpanded) {
            children.classList.remove("expanded");
            icon.classList.remove("expanded");
          } else {
            children.classList.add("expanded");
            icon.classList.add("expanded");
          }
        });
        toggleAll.textContent = isExpanded ? "全部展開" : "全部收縮";
      });
      tocHeader.appendChild(toggleAll);
    }
    
    function slugify(t) {
      return t.toLowerCase().trim()
        .replace(/[^\u4e00-\u9fa5\w\s-]/g, "")
        .replace(/\s+/g, "-")
        .replace(/-+/g, "-");
    }
    
    // 建立階層結構
    const structure = [];
    let currentH1 = null;
    
    headings.forEach(h => {
      if (!h.id) {
        let base = slugify(h.textContent) || "section";
        let id = base, i = 2;
        while (ids.has(id)) { id = `${base}-${i++}`; }
        ids.add(id);
        h.id = id;
      }
      
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
      icon.innerHTML = "▶"; // 使用三角形箭頭
      
      const text = document.createElement("span");
      text.className = "toc-h1-text";
      text.textContent = item.heading.textContent;
      
      toggle.appendChild(icon);
      toggle.appendChild(text);
      
      // H1 點擊事件
      toggle.addEventListener("click", (e) => {
        e.preventDefault();
        
        // 平滑滾動到 H1 - 使用更好的滾動效果
        const targetPosition = item.heading.getBoundingClientRect().top + window.pageYOffset - 80;
        
        window.scrollTo({
          top: targetPosition,
          behavior: "smooth"
        });
        
        // 更新 URL 但不跳轉
        history.replaceState(null, "", `#${item.heading.id}`);
        
        // 切換折疊狀態
        const children = h1Item.querySelector(".toc-children");
        const isExpanded = children.classList.contains("expanded");
        
        children.classList.toggle("expanded");
        icon.classList.toggle("expanded");
        
        // 如果是展開動作，先展開再滾動到內容
        if (!isExpanded) {
          setTimeout(() => {
            const newPosition = item.heading.getBoundingClientRect().top + window.pageYOffset - 80;
            window.scrollTo({
              top: newPosition,
              behavior: "smooth"
            });
          }, 200);
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
            // 平滑滾動到子標題 - 動態計算位置
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
          const id = en.target.id;
          // 清除所有 active 狀態
          allLinks.forEach(l => l.classList.remove("active"));
          // 設置當前 active
          const activeElement = linkMap.get(id);
          if (activeElement) {
            activeElement.classList.add("active");
            // 如果是 H2/H3，確保其父 H1 是展開的
            if (en.target.tagName !== "H1") {
              const h1Item = activeElement.closest(".toc-h1-item");
              if (h1Item) {
                const children = h1Item.querySelector(".toc-children");
                const icon = h1Item.querySelector(".toc-h1-icon");
                if (children && !children.classList.contains("expanded")) {
                  children.classList.add("expanded");
                  icon.classList.add("expanded");
                }
              }
            }
          }
        }
      });
    }, { rootMargin: "0px 0px -70% 0px", threshold: 0.1 });
    
    headings.forEach(h => observer.observe(h));
  }
});
document.addEventListener("DOMContentLoaded", () => {
  // 主題切換
  const toggleBtn = document.getElementById("theme-toggle");
  if(toggleBtn){
    toggleBtn.addEventListener("click", () => {
      document.documentElement.classList.toggle("light");
      toggleBtn.textContent = document.documentElement.classList.contains("light") ? "☀️" : "🌙";
    });
  }
});