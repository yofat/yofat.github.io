
// Code block copy buttons for Rouge-highlighted blocks
document.addEventListener('DOMContentLoaded', function() {
  function enhanceRougeBlocks() {
    const rougeBlocks = document.querySelectorAll('.highlighter-rouge');

    rougeBlocks.forEach(function(rougeBlock, index) {
      if (rougeBlock.classList.contains('enhanced')) return;
      // prefer .highlight container, fallback to first <pre>
      const highlightDiv = rougeBlock.querySelector('.highlight') || rougeBlock.querySelector('pre');
      if (!highlightDiv) return;

      const header = document.createElement('div');
      header.className = 'code-header';
      header.innerHTML = '\n        <span class="code-lang">' + getLanguageFromRougeBlock(rougeBlock) + '</span>' +
                         '<button class="code-copy" data-code-index="' + index + '"><span>📋</span> 複製</button>\n      ';

      highlightDiv.parentElement.insertBefore(header, highlightDiv);
      highlightDiv.classList.add('enhanced-block');
      rougeBlock.classList.add('enhanced');
    });
  }

  function getLanguageFromRougeBlock(rougeBlock) {
    for (let i = 0; i < rougeBlock.classList.length; i++) {
      const className = rougeBlock.classList[i];
      if (className.indexOf('language-') === 0) return className.replace('language-', '').toUpperCase();
    }
    return 'CODE';
  }

  function copyRougeCode(index) {
    const block = document.querySelectorAll('.highlighter-rouge')[index];
    if (!block) return showCopyError(index);

    let text = '';
    const table = block.querySelector('.rouge-table');
    if (table) {
      const codeCells = table.querySelectorAll('.rouge-code pre');
      if (codeCells.length) text = codeCells[0].textContent;
    } else {
      const codeEl = block.querySelector('code');
      if (codeEl) text = codeEl.textContent;
      else {
        const pre = block.querySelector('pre');
        if (pre) text = pre.textContent;
      }
    }

    text = (text || '').trim();
    if (!text) return showCopyError(index);

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(function() { showCopySuccess(index); }).catch(function() { fallbackCopyTextToClipboard(text, index); });
    } else {
      fallbackCopyTextToClipboard(text, index);
    }
  }

  function fallbackCopyTextToClipboard(text, index) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.focus();
    ta.select();
    try { document.execCommand('copy'); showCopySuccess(index); } catch (e) { showCopyError(index); }
    document.body.removeChild(ta);
  }

  function showCopySuccess(index) {
    const btn = document.querySelectorAll('.code-copy')[index];
    if (!btn) return;
    const orig = btn.innerHTML;
    btn.innerHTML = '<span>✅</span> 已複製!';
    btn.style.background = 'linear-gradient(135deg, var(--success), var(--success))';
    btn.style.color = 'white';
    setTimeout(function() { btn.innerHTML = orig; btn.style.background = ''; btn.style.color = ''; }, 1800);
  }

  function showCopyError(index) {
    const btn = document.querySelectorAll('.code-copy')[index];
    if (!btn) return;
    const orig = btn.innerHTML;
    btn.innerHTML = '<span>❌</span> 複製失敗';
    btn.style.background = 'linear-gradient(135deg, var(--error), var(--error))';
    btn.style.color = 'white';
    setTimeout(function() { btn.innerHTML = orig; btn.style.background = ''; btn.style.color = ''; }, 1800);
  }

  // Click handler (delegated)
  document.addEventListener('click', function(e) {
    const btn = e.target.closest && e.target.closest('.code-copy');
    if (!btn) return;
    const idxAttr = btn.getAttribute('data-code-index');
    const idx = idxAttr !== null ? parseInt(idxAttr, 10) : NaN;
    if (!isNaN(idx)) copyRougeCode(idx);
  });

  // Init
  function init() { enhanceRougeBlocks(); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
});

