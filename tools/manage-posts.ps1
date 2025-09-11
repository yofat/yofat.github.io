# 文章管理腳本 (PowerShell)

Write-Host "=== YoFat 部落格文章管理工具 ===" -ForegroundColor Blue
Write-Host ""

# 顯示選項
Write-Host "請選擇操作："
echo "1. 創建新文章 (_articles 資料夾)"
Write-Host "2. 創建新文章 (_posts 資料夾)" 
Write-Host "3. 列出所有文章"
Write-Host "4. 檢查文章格式"
Write-Host "5. 退出"
Write-Host ""

$choice = Read-Host "請輸入選項 (1-5)"

switch ($choice) {
    1 {
        Write-Host "創建新文章 (articles 資料夾)" -ForegroundColor Yellow
        Write-Host "可用分類："
        Write-Host "- 人工智能"
        Write-Host "- 程式語言"
        Write-Host "- 網頁開發" 
        Write-Host "- 生活分享"
        Write-Host ""
        
        $category = Read-Host "請選擇分類"
        $title = Read-Host "請輸入文章標題"
        $filename = Read-Host "請輸入檔案名稱 (英文)"
        
        # 創建日期
        $date = Get-Date -Format "yyyy-MM-dd"
        
        # 創建文件路徑
        $filepath = "articles\${category}\${filename}.md"
        
        # 檢查目錄是否存在
        if (!(Test-Path "articles\${category}")) {
            Write-Host "錯誤：分類目錄不存在" -ForegroundColor Red
            exit 1
        }
        
        # 創建文章內容
        $content = @"
---
layout: post
title: ${title}
categories: [${category}]
tags: []
date: ${date}
excerpt: 
---

# ${title}

在這裡開始撰寫您的文章內容...

## 章節標題

文章內容

"@
        
        # 寫入文件
        $content | Out-File -FilePath $filepath -Encoding UTF8
        Write-Host "文章已創建：${filepath}" -ForegroundColor Green
    }
    
    2 {
        Write-Host "創建新文章 (_posts 資料夾)" -ForegroundColor Yellow
        $title = Read-Host "請輸入文章標題"
        $filename = Read-Host "請輸入檔案名稱 (英文)"
        
        # 創建日期
        $date = Get-Date -Format "yyyy-MM-dd"
        
        # 創建文件路徑
        $filepath = "_posts\${date}-${filename}.md"
        
        # 創建文章內容
        $content = @"
---
layout: post
title: ${title}
categories: []
tags: []
date: ${date}
excerpt: 
---

# ${title}

在這裡開始撰寫您的文章內容...

## 章節標題

文章內容

"@
        
        # 寫入文件
        $content | Out-File -FilePath $filepath -Encoding UTF8
        Write-Host "文章已創建：${filepath}" -ForegroundColor Green
    }
    
    3 {
        Write-Host "所有文章列表：" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "_posts 資料夾：" -ForegroundColor Blue
        if (Test-Path "_posts") {
            Get-ChildItem "_posts\*.md" | Select-Object Name, LastWriteTime
        } else {
            Write-Host "無文章"
        }
        Write-Host ""
        Write-Host "articles 資料夾：" -ForegroundColor Blue
        if (Test-Path "articles") {
            Get-ChildItem "articles\*\*.md" -Recurse | Select-Object FullName, LastWriteTime
        } else {
            Write-Host "無文章"
        }
    }
    
    4 {
        Write-Host "檢查文章格式..." -ForegroundColor Yellow
        Write-Host ""
        
        # 檢查 _posts
        Write-Host "檢查 _posts 資料夾：" -ForegroundColor Blue
        if (Test-Path "_posts") {
            Get-ChildItem "_posts\*.md" | ForEach-Object {
                $firstLine = Get-Content $_.FullName -TotalCount 1
                if ($firstLine -eq "---") {
                    Write-Host "✓ $($_.Name)" -ForegroundColor Green
                } else {
                    Write-Host "✗ $($_.Name) (缺少 Front Matter)" -ForegroundColor Red
                }
            }
        }
        
        # 檢查 articles
        Write-Host "檢查 articles 資料夾：" -ForegroundColor Blue
        if (Test-Path "articles") {
            Get-ChildItem "articles\*\*.md" -Recurse | ForEach-Object {
                $firstLine = Get-Content $_.FullName -TotalCount 1
                if ($firstLine -eq "---") {
                    Write-Host "✓ $($_.FullName)" -ForegroundColor Green
                } else {
                    Write-Host "✗ $($_.FullName) (缺少 Front Matter)" -ForegroundColor Red
                }
            }
        }
    }
    
    5 {
        Write-Host "再見！" -ForegroundColor Green
        exit 0
    }
    
    default {
        Write-Host "無效選項" -ForegroundColor Red
        exit 1
    }
}
