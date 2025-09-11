# 📁 拖放文章工具 (PowerShell)
# 使用方式：將 .md 檔案拖放到此腳本上

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

$Colors = @{
    Blue = "Blue"; Green = "Green"; Yellow = "Yellow"; Red = "Red"; Cyan = "Cyan"
}

Write-Host "📁 YoFat 拖放文章工具" -ForegroundColor $Colors.Blue
Write-Host "=" * 50

if (-not $Files -or $Files.Length -eq 0) {
    Write-Host "使用方式: 將 .md 檔案拖放到此腳本上" -ForegroundColor $Colors.Yellow
    Write-Host ""
    Write-Host "或者手動指定檔案:"
    Write-Host "  .\drop-article.ps1 `"path\to\article.md`""
    Write-Host ""
    Write-Host "支援的格式："
    Write-Host "  • .md 檔案"
    Write-Host "  • Front Matter 可選"
    Write-Host "  • 自動分類到合適的資料夾"
    pause
    exit 0
}

$categories = @("人工智能", "程式語言", "網頁開發", "生活分享", "教學", "功能項目", "工具分享", "心得筆記")

foreach ($file in $Files) {
    if (-not (Test-Path $file)) {
        Write-Host "❌ 檔案不存在: $file" -ForegroundColor $Colors.Red
        continue
    }

    if ([System.IO.Path]::GetExtension($file) -ne ".md") {
        Write-Host "⚠️  跳過非 Markdown 檔案: $file" -ForegroundColor $Colors.Yellow
        continue
    }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $content = Get-Content $file -Raw

    Write-Host ""
    Write-Host "📝 處理檔案: $fileName" -ForegroundColor $Colors.Cyan

    # 檢查是否已有 Front Matter
    $hasFrontMatter = $content -match '^---\s*\n.*?\n---\s*\n'
    
    if (-not $hasFrontMatter) {
        Write-Host "📄 檔案沒有 Front Matter，需要添加..." -ForegroundColor $Colors.Yellow
        
        # 選擇分類
        Write-Host "請選擇分類:" -ForegroundColor $Colors.Yellow
        for ($i = 0; $i -lt $categories.Length; $i++) {
            Write-Host "  [$($i+1)] $($categories[$i])"
        }
        
        do {
            $choice = Read-Host "請輸入數字 (1-8)"
            $choiceNum = [int]$choice - 1
        } while ($choiceNum -lt 0 -or $choiceNum -ge $categories.Length)
        
        $category = $categories[$choiceNum]
        $title = Read-Host "文章標題 (留空使用檔名)"
        if (-not $title) { $title = $fileName }
        
        $tags = Read-Host "標籤 (用逗號分隔，可留空)"
        $tagArray = if ($tags) { 
            ($tags -split ',' | ForEach-Object { "`"$($_.Trim())`"" }) -join ', '
        } else { "" }

        $date = Get-Date -Format "yyyy-MM-dd"
        
        # 添加 Front Matter
        $frontMatter = @"
---
layout: post
title: $title
categories: [$category]
tags: [$tagArray]
date: $date
excerpt: 
---

"@
        $content = $frontMatter + $content
    } else {
        Write-Host "✅ 檔案已有 Front Matter" -ForegroundColor $Colors.Green
        
        # 嘗試從 Front Matter 中提取分類
        if ($content -match 'categories:\s*\[([^\]]+)\]') {
            $categoryMatch = $matches[1] -split ',' | ForEach-Object { $_.Trim().Trim('"') } | Select-Object -First 1
            $category = $categories | Where-Object { $_ -eq $categoryMatch } | Select-Object -First 1
        }
        
        if (-not $category) {
            Write-Host "無法確定分類，請選擇:" -ForegroundColor $Colors.Yellow
            for ($i = 0; $i -lt $categories.Length; $i++) {
                Write-Host "  [$($i+1)] $($categories[$i])"
            }
            
            do {
                $choice = Read-Host "請輸入數字 (1-4)"
                $choiceNum = [int]$choice - 1
            } while ($choiceNum -lt 0 -or $choiceNum -ge $categories.Length)
            
            $category = $categories[$choiceNum]
        }
    }

    # 生成目標路徑
    $targetDir = "_articles\$category"
    $targetPath = "$targetDir\$fileName.md"
    
    # 檢查目標目錄
    if (-not (Test-Path $targetDir)) {
        Write-Host "❌ 分類目錄不存在: $category" -ForegroundColor $Colors.Red
        continue
    }

    # 檢查檔案是否已存在
    if (Test-Path $targetPath) {
        $overwrite = Read-Host "檔案已存在，是否覆蓋? (y/N)"
        if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
            Write-Host "⏭️  跳過檔案: $fileName" -ForegroundColor $Colors.Yellow
            continue
        }
    }

    # 寫入檔案
    try {
        $content | Out-File -FilePath $targetPath -Encoding UTF8
        Write-Host "✅ 成功移動到: $targetPath" -ForegroundColor $Colors.Green
        Write-Host "📂 分類: $category" -ForegroundColor $Colors.Cyan
    } catch {
        Write-Host "❌ 移動失敗: $($_.Exception.Message)" -ForegroundColor $Colors.Red
    }
}

Write-Host ""
Write-Host "🎉 處理完成！" -ForegroundColor $Colors.Green
Write-Host "🚀 下一步："
Write-Host "  1. 檢查檔案: dir _articles\*\*.md"
Write-Host "  2. 啟動預覽: bundle exec jekyll serve"
Write-Host "  3. 查看結果: http://localhost:4000/posts.html"
Write-Host ""
pause
