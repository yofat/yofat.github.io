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
