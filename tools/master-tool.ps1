# 🎯 YoFat 部落格主工具 (Master Tool)
# 整合所有功能的統一管理介面

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("create", "manage", "search", "stats", "clean", "help")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("人工智能", "程式語言", "網頁開發", "生活分享", "教學", "功能項目", "工具分享", "心得筆記")]
    [string]$Category,
    
    [Parameter(Mandatory=$false)]
    [string]$Tags,
    
    [switch]$Help
)

$Colors = @{
    Blue = "Blue"; Green = "Green"; Yellow = "Yellow"; Red = "Red"; Cyan = "Cyan"; Magenta = "Magenta"
}

# 顯示主選單
function Show-MainMenu {
    Clear-Host
    Write-Host "🎯 YoFat 部落格主工具" -ForegroundColor $Colors.Blue
    Write-Host "=" * 60
    Write-Host ""
    Write-Host "📝 文章管理" -ForegroundColor $Colors.Green
    Write-Host "  1. 快速創建文章"
    Write-Host "  2. 批量文章管理"
    Write-Host "  3. 拖放文章處理"
    Write-Host ""
    Write-Host "🔍 查詢功能" -ForegroundColor $Colors.Yellow
    Write-Host "  4. 搜尋文章"
    Write-Host "  5. 文章統計"
    Write-Host "  6. 列出所有文章"
    Write-Host ""
    Write-Host "🧹 維護功能" -ForegroundColor $Colors.Cyan
    Write-Host "  7. 清理空檔案"
    Write-Host "  8. 檢查檔案狀態"
    Write-Host ""
    Write-Host "📚 說明與工具" -ForegroundColor $Colors.Magenta
    Write-Host "  9. 顯示幫助"
    Write-Host "  0. 退出"
    Write-Host ""
    Write-Host "=" * 60
}

# 快速創建文章
function Quick-CreateArticle {
    param($Title, $Category, $Tags)
    
    if (-not $Title) {
        $Title = Read-Host "請輸入文章標題"
    }
    
    if (-not $Category) {
        Write-Host "可用分類：" -ForegroundColor $Colors.Yellow
        Write-Host "1. 人工智能    2. 程式語言    3. 網頁開發    4. 生活分享"
        Write-Host "5. 教學        6. 功能項目    7. 工具分享    8. 心得筆記"
        
        $categoryChoice = Read-Host "請選擇分類 (1-8)"
        $categories = @("人工智能", "程式語言", "網頁開發", "生活分享", "教學", "功能項目", "工具分享", "心得筆記")
        $Category = $categories[[int]$categoryChoice - 1]
    }
    
    if (-not $Tags) {
        $Tags = Read-Host "請輸入標籤 (用逗號分隔，可留空)"
    }
    
    # 調用原有的快速創建工具
    if ($Tags) {
        & ".\tools\quick-post.ps1" -Title $Title -Category $Category -Tags $Tags
    } else {
        & ".\tools\quick-post.ps1" -Title $Title -Category $Category
    }
}

# 批量管理
function Launch-BatchManager {
    Write-Host "🔄 啟動批量文章管理器..." -ForegroundColor $Colors.Green
    & ".\tools\article-manager.ps1"
}

# 拖放處理
function Launch-DropTool {
    Write-Host "📁 啟動拖放文章處理工具..." -ForegroundColor $Colors.Green
    Write-Host "請將 .md 檔案拖放到 drop-article.ps1 上" -ForegroundColor $Colors.Yellow
    & ".\tools\drop-article.ps1"
}

# 搜尋文章
function Search-Articles {
    $keyword = Read-Host "請輸入搜尋關鍵字"
    Write-Host "🔍 搜尋包含 '$keyword' 的文章..." -ForegroundColor $Colors.Yellow
    
    Get-ChildItem -Path "_articles" -Recurse -Filter "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        if ($content -match $keyword) {
            Write-Host "📄 $($_.Name)" -ForegroundColor $Colors.Green
            Write-Host "   位置: $($_.DirectoryName.Split('\')[-1])" -ForegroundColor $Colors.Cyan
            Write-Host "   路徑: $($_.FullName)" -ForegroundColor $Colors.Gray
            Write-Host ""
        }
    }
}

# 文章統計
function Show-Statistics {
    Write-Host "📊 部落格統計資訊" -ForegroundColor $Colors.Blue
    Write-Host "=" * 40
    
    $categories = Get-ChildItem -Path "_articles" -Directory
    $totalArticles = 0
    
    foreach ($category in $categories) {
        $articles = Get-ChildItem -Path $category.FullName -Filter "*.md"
        $count = $articles.Count
        $totalArticles += $count
        
        Write-Host "📁 $($category.Name): $count 篇" -ForegroundColor $Colors.Green
    }
    
    Write-Host ""
    Write-Host "📝 總計: $totalArticles 篇文章" -ForegroundColor $Colors.Yellow
    Write-Host "📁 分類數量: $($categories.Count) 個" -ForegroundColor $Colors.Cyan
}

# 列出所有文章
function List-AllArticles {
    Write-Host "📋 所有文章列表" -ForegroundColor $Colors.Blue
    Write-Host "=" * 50
    
    Get-ChildItem -Path "_articles" -Directory | ForEach-Object {
        $categoryName = $_.Name
        Write-Host "📁 $categoryName" -ForegroundColor $Colors.Green
        
        Get-ChildItem -Path $_.FullName -Filter "*.md" | ForEach-Object {
            Write-Host "  📄 $($_.Name)" -ForegroundColor $Colors.Cyan
        }
        Write-Host ""
    }
}

# 清理空檔案
function Clean-EmptyFiles {
    Write-Host "🧹 清理空檔案..." -ForegroundColor $Colors.Yellow
    
    $emptyFiles = Get-ChildItem -Recurse -File | Where-Object { $_.Length -eq 0 }
    
    if ($emptyFiles.Count -eq 0) {
        Write-Host "✅ 沒有發現空檔案" -ForegroundColor $Colors.Green
        return
    }
    
    Write-Host "發現 $($emptyFiles.Count) 個空檔案：" -ForegroundColor $Colors.Red
    $emptyFiles | ForEach-Object {
        Write-Host "  📄 $($_.FullName)"
    }
    
    $confirm = Read-Host "是否刪除這些空檔案？(y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        $emptyFiles | Remove-Item -Force
        Write-Host "✅ 已刪除所有空檔案" -ForegroundColor $Colors.Green
    }
}

# 檢查檔案狀態
function Check-FileStatus {
    Write-Host "🔍 檢查檔案狀態..." -ForegroundColor $Colors.Yellow
    
    # 檢查編碼問題
    Write-Host "檢查文字編碼問題..." -ForegroundColor $Colors.Cyan
    $encodingIssues = @()
    Get-ChildItem -Recurse -Filter "*.html", "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content -match '�|??') {
            $encodingIssues += $_.FullName
        }
    }
    
    if ($encodingIssues.Count -gt 0) {
        Write-Host "⚠️ 發現編碼問題的檔案：" -ForegroundColor $Colors.Red
        $encodingIssues | ForEach-Object { Write-Host "  📄 $_" }
    } else {
        Write-Host "✅ 未發現編碼問題" -ForegroundColor $Colors.Green
    }
    
    # 檢查資料夾結構
    Write-Host "檢查資料夾結構..." -ForegroundColor $Colors.Cyan
    if (Test-Path "_articles") {
        Write-Host "✅ _articles 資料夾存在" -ForegroundColor $Colors.Green
    } else {
        Write-Host "❌ _articles 資料夾不存在" -ForegroundColor $Colors.Red
    }
}

# 顯示幫助
function Show-Help {
    Write-Host "📚 YoFat 部落格主工具使用指南" -ForegroundColor $Colors.Blue
    Write-Host "=" * 60
    Write-Host ""
    Write-Host "命令列使用方式：" -ForegroundColor $Colors.Yellow
    Write-Host "  .\tools\master-tool.ps1                          # 啟動互動選單"
    Write-Host "  .\tools\master-tool.ps1 -Action create          # 快速創建文章"
    Write-Host "  .\tools\master-tool.ps1 -Action stats           # 顯示統計"
    Write-Host "  .\tools\master-tool.ps1 -Action clean           # 清理空檔案"
    Write-Host ""
    Write-Host "快速創建範例：" -ForegroundColor $Colors.Yellow
    Write-Host "  .\tools\master-tool.ps1 -Action create -Title '我的文章' -Category '程式語言'"
    Write-Host "  .\tools\master-tool.ps1 -Action create -Title 'Python教學' -Category '教學' -Tags 'Python,教學'"
    Write-Host ""
    Write-Host "可用動作 (Action)：" -ForegroundColor $Colors.Green
    Write-Host "  create  - 創建新文章"
    Write-Host "  manage  - 批量管理"
    Write-Host "  search  - 搜尋文章"
    Write-Host "  stats   - 顯示統計"
    Write-Host "  clean   - 清理空檔案"
    Write-Host "  help    - 顯示幫助"
    Write-Host ""
    Write-Host "其他工具：" -ForegroundColor $Colors.Magenta
    Write-Host "  quick-post.ps1      - 快速創建文章"
    Write-Host "  article-manager.ps1 - 批量文章管理"
    Write-Host "  drop-article.ps1    - 拖放文章處理"
    Write-Host ""
}

# 主程式邏輯
if ($Help) {
    Show-Help
    return
}

# 如果有指定動作，直接執行
if ($Action) {
    switch ($Action) {
        "create" { Quick-CreateArticle -Title $Title -Category $Category -Tags $Tags }
        "manage" { Launch-BatchManager }
        "search" { Search-Articles }
        "stats"  { Show-Statistics }
        "clean"  { Clean-EmptyFiles }
        "help"   { Show-Help }
        default  { Write-Host "未知動作: $Action" -ForegroundColor $Colors.Red; Show-Help }
    }
    return
}

# 互動選單
do {
    Show-MainMenu
    $choice = Read-Host "請選擇操作 (0-9)"
    
    switch ($choice) {
        "1" { Quick-CreateArticle }
        "2" { Launch-BatchManager }
        "3" { Launch-DropTool }
        "4" { Search-Articles }
        "5" { Show-Statistics }
        "6" { List-AllArticles }
        "7" { Clean-EmptyFiles }
        "8" { Check-FileStatus }
        "9" { Show-Help }
        "0" { 
            Write-Host "👋 謝謝使用！" -ForegroundColor $Colors.Green
            break 
        }
        default { 
            Write-Host "無效選項，請重新選擇" -ForegroundColor $Colors.Red
            Start-Sleep 2
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "按 Enter 繼續..."
    }
} while ($choice -ne "0")
