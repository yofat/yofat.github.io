# YoFat Blog - Quick Post Creator (Clean Version)
# 快速創建文章工具

param(
    [Parameter(Mandatory=$false)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("人工智能", "程式語言", "網頁開發", "生活分享", "教學", "工具分享", "心得筆記")]
    [string]$Category,
    
    [Parameter(Mandatory=$false)]
    [string]$Tags,
    
    [switch]$Help
)

if ($Help) {
    Write-Host "=== 快速創建文章工具 ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "用法:" -ForegroundColor Yellow
    Write-Host "  .\tools\quick-post.ps1 -Title '文章標題' -Category '分類' -Tags '標籤1,標籤2'"
    Write-Host ""
    Write-Host "範例:" -ForegroundColor Yellow
    Write-Host "  .\tools\quick-post.ps1 -Title 'Python 教學' -Category '教學' -Tags 'Python,教學'"
    Write-Host "  .\tools\quick-post.ps1 -Title '我的心得' -Category '心得筆記'"
    Write-Host ""
    return
}

# 切換到上級目錄（因為工具在 tools 資料夾中）
$originalPath = Get-Location
Set-Location (Split-Path $PSScriptRoot -Parent)

try {
    if (-not $Title) {
        Write-Host "=== 快速創建文章 ===" -ForegroundColor Magenta
        $Title = Read-Host "請輸入文章標題"
        if (-not $Title) {
            Write-Host "標題不能為空！" -ForegroundColor Red
            return
        }
    }

    if (-not $Category) {
        Write-Host ""
        Write-Host "可用分類:" -ForegroundColor Yellow
        Write-Host "1. 人工智能"
        Write-Host "2. 程式語言"
        Write-Host "3. 網頁開發"
        Write-Host "4. 生活分享"
        Write-Host "5. 教學"
        Write-Host "6. 工具分享"
        Write-Host "7. 心得筆記"
        
        $choice = Read-Host "請選擇分類 (1-8)"
        switch ($choice) {
            "1" { $Category = "人工智能" }
            "2" { $Category = "程式語言" }
            "3" { $Category = "網頁開發" }
            "4" { $Category = "生活分享" }
            "5" { $Category = "教學" }
            "6" { $Category = "工具分享" }
            "7" { $Category = "心得筆記" }
            default { 
                Write-Host "無效選擇，預設使用 '生活分享'" -ForegroundColor Yellow
                $Category = "生活分享"
            }
        }
    }

    if (-not $Tags) {
        $Tags = Read-Host "請輸入標籤 (用逗號分隔，可留空)"
    }

    $TagString = ""
    if ($Tags) {
        $TagArray = $Tags -split "," | ForEach-Object { "`"$($_.Trim())`"" }
        $TagString = $TagArray -join ", "
    }

    $FileName = $Title -replace "[^\w\s-]", "" -replace "\s+", "-"
    $Date = Get-Date -Format "yyyy-MM-dd"
    $FullFileName = "$Date-$FileName.md"

    $TargetDir = "_posts"
    $FilePath = "$TargetDir\$FullFileName"

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    $Content = @"
---
layout: post
title: $Title
categories: [$Category]
tags: [$TagString]
date: $Date
excerpt: 
---

# $Title

這裡開始寫文章內容...

## 章節標題

文章內容請在這裡編寫。

### 小節標題

更多內容...

## 總結

文章總結...
"@

    $Content | Out-File -FilePath $FilePath -Encoding UTF8

    Write-Host ""
    Write-Host "文章創建成功！" -ForegroundColor Green
    Write-Host "檔案位置: $FilePath" -ForegroundColor Cyan
    Write-Host "分類: $Category" -ForegroundColor Cyan
    if ($Tags) {
        Write-Host "標籤: $Tags" -ForegroundColor Cyan
    }
    
    $Edit = Read-Host "要立即編輯文章嗎? (y/N)"
    if ($Edit -eq "y" -or $Edit -eq "Y") {
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code $FilePath
        } else {
            notepad $FilePath
        }
    }

} catch {
    Write-Host "創建文章時發生錯誤: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location $originalPath
}
