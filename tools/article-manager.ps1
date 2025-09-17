# 📦 批量文章處理工具 (PowerShell)

$Colors = @{
    Blue = "Blue"; Green = "Green"; Yellow = "Yellow"; Red = "Red"; Cyan = "Cyan"
}

function Show-Menu {
    Clear-Host
    Write-Host "📦 YoFat 批量文章處理工具" -ForegroundColor $Colors.Blue
    Write-Host "=" * 50
    Write-Host ""
    Write-Host "請選擇操作:"
    Write-Host "  [1] 🚀 快速創建文章"
    Write-Host "  [2] 📁 批量處理 _posts 資料夾"
    Write-Host "  [3] 📋 列出所有文章"
    Write-Host "  [4] 🔍 搜尋文章"
    Write-Host "  [5] 🧹 清理空檔案"
    Write-Host "  [6] 📊 文章統計"
    Write-Host "  [7] ❓ 說明"
    Write-Host "  [0] 🚪 退出"
    Write-Host ""
}

function Quick-Create {
    Write-Host "🚀 快速創建文章" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    $title = Read-Host "📝 文章標題"
    if (-not $title) { return }
    
    $categories = @("人工智能", "程式語言", "網頁開發", "生活分享", "教學", "工具分享", "心得筆記")
    Write-Host "📂 選擇分類:"
    for ($i = 0; $i -lt $categories.Length; $i++) {
        Write-Host "  [$($i+1)] $($categories[$i])"
    }
    
    do {
        $choice = Read-Host "請輸入數字 (1-8)"
        $choiceNum = [int]$choice - 1
    } while ($choiceNum -lt 0 -or $choiceNum -ge $categories.Length)
    
    $category = $categories[$choiceNum]
    $tags = Read-Host "🏷️  標籤 (逗號分隔，可留空)"
    
    # 執行快速創建
    if ($tags) {
        & ".\quick-post.ps1" -Title $title -Category $category -Tags $tags
    } else {
        & ".\quick-post.ps1" -Title $title -Category $category
    }
}

function Process-PostsFolder {
    Write-Host "📁 批量處理 _posts 資料夾" -ForegroundColor $Colors.Blue
    
    if (-not (Test-Path "_posts")) {
        Write-Host "❌ _posts 資料夾不存在" -ForegroundColor $Colors.Red
        return
    }
    
    $posts = Get-ChildItem "_posts\*.md"
    if ($posts.Length -eq 0) {
        Write-Host "📄 _posts 資料夾中沒有文章" -ForegroundColor $Colors.Yellow
        return
    }
    
    Write-Host "找到 $($posts.Length) 篇文章:"
    foreach ($post in $posts) {
        Write-Host "  • $($post.Name)" -ForegroundColor $Colors.Cyan
    }
    
    $confirm = Read-Host "是否將這些文章移動到 _posts？(y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') { return }
    
    foreach ($post in $posts) {
        Write-Host "處理: $($post.Name)" -ForegroundColor $Colors.Yellow
        & ".\drop-article.ps1" $post.FullName
    }
}

function List-Articles {
    Write-Host "📋 所有文章列表" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    $categories = @("人工智能", "程式語言", "網頁開發", "生活分享")
    $totalCount = 0
    
    foreach ($category in $categories) {
        $path = "_articles\$category"
        if (Test-Path $path) {
            $articles = Get-ChildItem "$path\*.md"
            if ($articles.Length -gt 0) {
                Write-Host "📂 $category ($($articles.Length) 篇):" -ForegroundColor $Colors.Cyan
                foreach ($article in $articles) {
                    $lastWrite = $article.LastWriteTime.ToString("MM-dd")
                    Write-Host "  • $($article.BaseName) [$lastWrite]" -ForegroundColor $Colors.Green
                }
                $totalCount += $articles.Length
                Write-Host ""
            }
        }
    }
    
    Write-Host "📊 總計: $totalCount 篇文章" -ForegroundColor $Colors.Blue
}

function Search-Articles {
    Write-Host "🔍 搜尋文章" -ForegroundColor $Colors.Blue
    
    $keyword = Read-Host "請輸入關鍵字"
    if (-not $keyword) { return }
    
    Write-Host "搜尋結果:" -ForegroundColor $Colors.Yellow
    
    $found = $false
    Get-ChildItem "_posts\*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -match $keyword -or $_.BaseName -match $keyword) {
            $category = $_.Directory.Name
            Write-Host "  📄 [$category] $($_.BaseName)" -ForegroundColor $Colors.Green
            $found = $true
        }
    }
    
    if (-not $found) {
        Write-Host "  沒有找到包含 '$keyword' 的文章" -ForegroundColor $Colors.Red
    }
}

function Clean-EmptyFiles {
    Write-Host "🧹 清理空檔案" -ForegroundColor $Colors.Blue
    
    $emptyFiles = Get-ChildItem "_articles\*\*.md" -Recurse | Where-Object { 
        $_.Length -eq 0 -or (Get-Content $_.FullName -Raw).Trim() -eq ""
    }
    
    if ($emptyFiles.Length -eq 0) {
        Write-Host "✅ 沒有找到空檔案" -ForegroundColor $Colors.Green
        return
    }
    
    Write-Host "找到 $($emptyFiles.Length) 個空檔案:"
    foreach ($file in $emptyFiles) {
        Write-Host "  • $($file.FullName)" -ForegroundColor $Colors.Red
    }
    
    $confirm = Read-Host "是否刪除這些檔案？(y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        $emptyFiles | Remove-Item -Force
        Write-Host "✅ 已刪除 $($emptyFiles.Length) 個空檔案" -ForegroundColor $Colors.Green
    }
}

function Show-Statistics {
    Write-Host "📊 文章統計" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    $categories = @("人工智能", "程式語言", "網頁開發", "生活分享")
    $totalWords = 0
    $totalArticles = 0
    
    foreach ($category in $categories) {
        $path = "_articles\$category"
        if (Test-Path $path) {
            $articles = Get-ChildItem "$path\*.md"
            $categoryWords = 0
            
            foreach ($article in $articles) {
                $content = Get-Content $article.FullName -Raw
                $words = ($content -split '\s+').Length
                $categoryWords += $words
            }
            
            $totalWords += $categoryWords
            $totalArticles += $articles.Length
            
            if ($articles.Length -gt 0) {
                $avgWords = [math]::Round($categoryWords / $articles.Length)
                Write-Host "📂 $category : $($articles.Length) 篇, $categoryWords 字 (平均 $avgWords 字)" -ForegroundColor $Colors.Cyan
            }
        }
    }
    
    Write-Host ""
    Write-Host "📊 總計:" -ForegroundColor $Colors.Blue
    Write-Host "  • 文章數量: $totalArticles 篇"
    Write-Host "  • 總字數: $totalWords 字"
    if ($totalArticles -gt 0) {
        $avgWords = [math]::Round($totalWords / $totalArticles)
        Write-Host "  • 平均字數: $avgWords 字/篇"
    }
}

function Show-Help {
    Write-Host "❓ 使用說明" -ForegroundColor $Colors.Blue
    Write-Host ""
    Write-Host "快速使用方式:" -ForegroundColor $Colors.Yellow
    Write-Host "  1. 🚀 快速創建: .\quick-post.ps1 -Title `"標題`""
    Write-Host "  2. 📁 拖放文章: 拖拽 .md 檔案到 drop-article.ps1"
    Write-Host "  3. 📦 批量處理: 執行此工具選擇相應功能"
    Write-Host ""
    Write-Host "文章結構:" -ForegroundColor $Colors.Cyan
    Write-Host "  _articles/"
    Write-Host "  ├── 人工智能/"
    Write-Host "  ├── 程式語言/"
    Write-Host "  ├── 網頁開發/"
    Write-Host "  └── 生活分享/"
    Write-Host ""
    Write-Host "本地預覽:" -ForegroundColor $Colors.Green
    Write-Host "  bundle exec jekyll serve"
    Write-Host "  http://localhost:4000"
}

# 主循環
while ($true) {
    Show-Menu
    $choice = Read-Host "請選擇操作 (0-7)"
    
    switch ($choice) {
        "1" { Quick-Create }
        "2" { Process-PostsFolder }
        "3" { List-Articles }
        "4" { Search-Articles }
        "5" { Clean-EmptyFiles }
        "6" { Show-Statistics }
        "7" { Show-Help }
        "0" { 
            Write-Host "👋 再見！" -ForegroundColor $Colors.Green
            exit 0 
        }
        default {
            Write-Host "❌ 無效選項，請重新選擇" -ForegroundColor $Colors.Red
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "按 Enter 鍵繼續..."
    }
}
