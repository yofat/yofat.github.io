// Rouge 語法高亮器增強功能
document.addEventListener('DOMContentLoaded', function() {
  // 為 Rouge 生成的程式碼區塊添加複製功能
  function enhanceRougeBlocks() {
    // 查找所有 Rouge 生成的程式碼區塊
    const rougeBlocks = document.querySelectorAll('.highlighter-rouge');

    rougeBlocks.forEach(function(rougeBlock, index) {
      // 檢查是否已經處理過
      if (rougeBlock.classList.contains('enhanced')) {
        return;
      }

      // 找到內部的 highlight 容器
      const highlightDiv = rougeBlock.querySelector('.highlight');
      if (!highlightDiv) {
        return;
      }

      // 創建標題區域
      const header = document.createElement('div');
      header.className = 'code-header';
      header.innerHTML = `
        <span class="code-lang">${getLanguageFromRougeBlock(rougeBlock)}</span>
        <button class="code-copy" onclick="copyRougeCode(${index})">
          <span>📋</span> 複製
        </button>
      `;

      // 將標題插入到 highlight 容器之前
      highlightDiv.parentElement.insertBefore(header, highlightDiv);

      // 為 highlight 容器添加增強類別
      highlightDiv.classList.add('enhanced-block');

      // 標記整個 rouge 區塊為已處理
      rougeBlock.classList.add('enhanced');
    });
  }

  // 從 Rouge 區塊中提取語言
  function getLanguageFromRougeBlock(rougeBlock) {
    const classList = rougeBlock.classList;
    for (let className of classList) {
      if (className.startsWith('language-')) {
        const lang = className.replace('language-', '');
        return lang.toUpperCase();
      }
    }
    return 'CODE';
  }

  // 複製 Rouge 程式碼
  window.copyRougeCode = function(index) {
    const rougeBlock = document.querySelectorAll('.highlighter-rouge')[index];
    if (!rougeBlock) {
      console.error('找不到 Rouge 程式碼區塊:', index);
      return;
    }

    let text = '';

    // 檢查是否有行號表格結構
    const rougeTable = rougeBlock.querySelector('.rouge-table');
    if (rougeTable) {
      // 從表格結構中提取程式碼
      const codeCells = rougeTable.querySelectorAll('.rouge-code pre');
      if (codeCells.length > 0) {
        text = codeCells[0].textContent;
      }
    } else {
      // 從簡單的 pre 結構中提取
      const codeElement = rougeBlock.querySelector('code');
      if (codeElement) {
        text = codeElement.textContent;
      }
    }

    // 移除可能的額外空白
    text = text.trim();

    if (!text) {
      showCopyError(index);
      return;
    }

    // 使用現代剪貼板 API
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(() => {
        showCopySuccess(index);
      }).catch(err => {
        console.error('現代剪貼板 API 失敗:', err);
        fallbackCopyTextToClipboard(text, index);
      });
    } else {
      fallbackCopyTextToClipboard(text, index);
    }
  };

  // 回退複製方法
  function fallbackCopyTextToClipboard(text, index) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.left = '-999999px';
    textArea.style.top = '-999999px';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
      const successful = document.execCommand('copy');
      if (successful) {
        showCopySuccess(index);
      } else {
        showCopyError(index);
      }
    } catch (err) {
      console.error('複製失敗:', err);
      showCopyError(index);
    }

    document.body.removeChild(textArea);
  }

  // 顯示複製成功提示
  function showCopySuccess(index) {
    const button = document.querySelectorAll('.code-copy')[index];
    if (button) {
      const originalContent = button.innerHTML;
      button.innerHTML = '<span>✅</span> 已複製!';
      button.style.background = 'linear-gradient(135deg, var(--success), var(--success))';
      button.style.borderColor = 'var(--success)';
      button.style.color = 'white';
      button.style.transform = 'scale(1.05)';

      setTimeout(() => {
        button.innerHTML = originalContent;
        button.style.background = '';
        button.style.borderColor = '';
        button.style.color = '';
        button.style.transform = '';
      }, 2000);
    }
  }

  // 顯示複製錯誤提示
  function showCopyError(index) {
    const button = document.querySelectorAll('.code-copy')[index];
    if (button) {
      const originalContent = button.innerHTML;
      button.innerHTML = '<span>❌</span> 複製失敗';
      button.style.background = 'linear-gradient(135deg, var(--error), var(--error))';
      button.style.borderColor = 'var(--error)';
      button.style.color = 'white';

      setTimeout(() => {
        button.innerHTML = originalContent;
        button.style.background = '';
        button.style.borderColor = '';
        button.style.color = '';
      }, 2000);
    }
  }

  // 初始化
  function init() {
    console.log('初始化 Rouge 語法高亮器增強功能...');
    enhanceRougeBlocks();
    console.log('Rouge 語法高亮器增強功能初始化完成');
  }

  // 確保 DOM 完全載入後執行
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
});
