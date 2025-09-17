# 🚀 Jekyll 部落格啟動腳本
# 快速啟動本地開發伺服器

param(
    [switch]$Production,  # 生產模式
    [switch]$Draft,       # 包含草稿
    [int]$Port = 4000,    # 端口號
    [switch]$Help
)

# 設定控制台編碼為 UTF-8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if ($Help) {
    Write-Host "Jekyll 部落格啟動腳本" -ForegroundColor Blue
    Write-Host "用法："
    Write-Host "  .\start-dev.ps1                # 標準開發模式"
    Write-Host "  .\start-dev.ps1 -Draft        # 包含草稿"
    Write-Host "  .\start-dev.ps1 -Production   # 生產模式" 
    Write-Host "  .\start-dev.ps1 -Port 3000    # 指定端口"
    exit
}

Write-Host "啟動 YoFat Jekyll 部落格..." -ForegroundColor Blue

# 檢查依賴
if (!(Get-Command bundle -ErrorAction SilentlyContinue)) {
    Write-Host "找不到 bundler，請先安裝 Ruby 和 Bundler" -ForegroundColor Red
    exit 1
}

# 安裝/更新依賴
Write-Host "檢查依賴..." -ForegroundColor Yellow
bundle install

if ($LASTEXITCODE -ne 0) {
    Write-Host "依賴安裝失敗" -ForegroundColor Red
    exit 1
}

# 清理舊的建置
if (Test-Path "_site") {
    Write-Host "清理舊的建置..." -ForegroundColor Yellow
    Remove-Item "_site" -Recurse -Force
}

# 準備啟動參數
$jekyllArgs = @("exec", "jekyll", "serve")
$jekyllArgs += "--host", "0.0.0.0"
$jekyllArgs += "--port", $Port.ToString()
$jekyllArgs += "--livereload"

if ($Production) {
    Write-Host "生產模式啟動..." -ForegroundColor Green
    $jekyllArgs += "--config", "_config.yml"
} else {
    Write-Host "開發模式啟動..." -ForegroundColor Green
    $jekyllArgs += "--config", "_config.yml,docs/_config_dev.yml"
}

if ($Draft) {
    Write-Host "包含草稿..." -ForegroundColor Cyan
    $jekyllArgs += "--drafts"
}

# 顯示啟動資訊
Write-Host ("=" * 50) -ForegroundColor Gray
Write-Host "本地網址: http://localhost:$Port" -ForegroundColor Green
Write-Host "實時重載: 已啟用" -ForegroundColor Green
Write-Host ("工作目錄: " + (Get-Location)) -ForegroundColor Gray
Write-Host ("啟動時間: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host ("=" * 50) -ForegroundColor Gray
Write-Host ""
Write-Host "提示: 按 Ctrl+C 停止伺服器" -ForegroundColor Yellow
Write-Host ""

# 啟動 Jekyll
try {
    & bundle @jekyllArgs
} catch {
    Write-Host ("Jekyll 啟動失敗: " + $_) -ForegroundColor Red
    exit 1
}