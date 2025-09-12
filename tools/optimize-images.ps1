# 圖片優化工具
# 需要安裝 ImageMagick: winget install ImageMagick.ImageMagick

param(
    [string]$ImagePath = "assets\image",
    [int]$Quality = 85,
    [int]$MaxWidth = 1200,
    [string]$OutputSuffix = "_optimized"
)

Write-Host "🖼️  圖片優化工具" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

$ImageDir = Join-Path $PSScriptRoot "..\$ImagePath"

if (-not (Test-Path $ImageDir)) {
    Write-Host "❌ 找不到圖片資料夾: $ImageDir" -ForegroundColor Red
    exit 1
}

# 檢查是否安裝 ImageMagick
try {
    magick -version | Out-Null
    Write-Host "✅ ImageMagick 已安裝" -ForegroundColor Green
} catch {
    Write-Host "❌ 請先安裝 ImageMagick:" -ForegroundColor Red
    Write-Host "   winget install ImageMagick.ImageMagick" -ForegroundColor Yellow
    exit 1
}

# 獲取所有圖片檔案
$ImageFiles = Get-ChildItem -Path $ImageDir -Include "*.jpg", "*.jpeg", "*.png", "*.gif" -Recurse

Write-Host "📁 找到 $($ImageFiles.Count) 個圖片檔案" -ForegroundColor Green

foreach ($File in $ImageFiles) {
    $OriginalSize = [math]::Round($File.Length / 1KB, 2)
    Write-Host "`n🔄 處理: $($File.Name) (原始大小: ${OriginalSize}KB)" -ForegroundColor Yellow
    
    # 建立輸出檔名
    $NameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
    $Extension = $File.Extension
    $OutputName = "${NameWithoutExt}${OutputSuffix}${Extension}"
    $OutputPath = Join-Path $File.Directory $OutputName
    
    try {
        # 使用 ImageMagick 優化
        if ($Extension -eq ".png") {
            # PNG 檔案處理
            & magick "$($File.FullName)" -strip -resize "${MaxWidth}x>" -quality $Quality "$OutputPath"
        } else {
            # JPG 檔案處理
            & magick "$($File.FullName)" -strip -resize "${MaxWidth}x>" -quality $Quality "$OutputPath"
        }
        
        if (Test-Path $OutputPath) {
            $OptimizedSize = [math]::Round((Get-Item $OutputPath).Length / 1KB, 2)
            $Reduction = [math]::Round((($OriginalSize - $OptimizedSize) / $OriginalSize) * 100, 1)
            
            Write-Host "   ✅ 優化完成: ${OptimizedSize}KB (減少 ${Reduction}%)" -ForegroundColor Green
            
            # 如果優化效果顯著，詢問是否替換原檔案
            if ($Reduction -gt 20) {
                $Replace = Read-Host "   🤔 減少超過20%，是否替換原檔案？(y/N)"
                if ($Replace -eq "y" -or $Replace -eq "Y") {
                    Move-Item $OutputPath $File.FullName -Force
                    Write-Host "   🔄 已替換原檔案" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "   ❌ 優化失敗" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ 處理錯誤: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎉 圖片優化完成！" -ForegroundColor Green
Write-Host "💡 建議："
Write-Host "   - Banner 圖片建議小於 500KB"
Write-Host "   - Logo 圖片建議小於 100KB"
Write-Host "   - 內容圖片建議小於 300KB"
