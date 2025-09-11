// 代碼塊增強功能
document.addEventListener('DOMContentLoaded', function() {
  // 為所有代碼塊添加行號和複製按鈕
  function enhanceCodeBlocks() {
    const codeBlocks = document.querySelectorAll('pre code');
    
    codeBlocks.forEach(function(codeElement, index) {
      const pre = codeElement.parentElement;
      if (pre.tagName !== 'PRE') return;
      
      // 跳過已經處理過的代碼塊
      if (pre.parentElement.classList.contains('code-block')) return;
      
      // 獲取語言類型
      let language = '';
      const classList = codeElement.classList;
      for (let className of classList) {
        if (className.startsWith('language-')) {
          language = className.replace('language-', '');
          break;
        }
      }
      if (!language) language = 'text';
      
      // 獲取代碼內容和行數
      const codeContent = codeElement.textContent;
      const lines = codeContent.split('\n');
      if (lines[lines.length - 1] === '') {
        lines.pop(); // 移除最後的空行
      }
      
      // 創建新的結構
      const codeBlock = document.createElement('div');
      codeBlock.className = 'code-block';
      
      // 創建標題
      const codeHeader = document.createElement('div');
      codeHeader.className = 'code-header';
      codeHeader.innerHTML = `
        <span class="code-lang">${language}</span>
        <button class="code-copy" onclick="copyCode(${index})">複製</button>
      `;
      
      // 創建內容區域
      const codeContentDiv = document.createElement('div');
      codeContentDiv.className = 'code-content';
      
      // 創建行號
      const lineNumbers = document.createElement('div');
      lineNumbers.className = 'line-numbers';
      for (let i = 1; i <= lines.length; i++) {
        lineNumbers.innerHTML += i + '\n';
      }
      
      // 重新組裝
      const newPre = pre.cloneNode(true);
      newPre.setAttribute('data-code-index', index);
      
      codeContentDiv.appendChild(lineNumbers);
      codeContentDiv.appendChild(newPre);
      
      codeBlock.appendChild(codeHeader);
      codeBlock.appendChild(codeContentDiv);
      
      // 替換原來的 pre 元素
      pre.parentElement.replaceChild(codeBlock, pre);
    });
  }
  
  // 複製代碼功能
  window.copyCode = function(index) {
    const pre = document.querySelector(`pre[data-code-index="${index}"]`);
    if (!pre) return;
    
    const code = pre.querySelector('code');
    const text = code.textContent;
    
    // 使用現代剪貼板 API
    if (navigator.clipboard) {
      navigator.clipboard.writeText(text).then(() => {
        showCopySuccess(index);
      });
    } else {
      // 回退方案
      const textArea = document.createElement('textarea');
      textArea.value = text;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      showCopySuccess(index);
    }
  };
  
  // 顯示複製成功提示
  function showCopySuccess(index) {
    const button = document.querySelector(`pre[data-code-index="${index}"]`)
      .parentElement.parentElement.querySelector('.code-copy');
    
    if (button) {
      const originalText = button.textContent;
      button.textContent = '已複製!';
      button.style.background = 'rgba(110, 231, 183, 0.3)';
      
      setTimeout(() => {
        button.textContent = originalText;
        button.style.background = '';
      }, 2000);
    }
  }
  
  // 初始化
  enhanceCodeBlocks();
});
