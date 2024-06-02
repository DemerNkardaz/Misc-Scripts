$directory = $args[0]

if (-not $directory) {
  $directory = $PSScriptRoot
}

function LogToFile {
  param (
    [string]$inputFile,
    [string]$outputFile
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor White " :: " -NoNewline
  Write-Host -ForegroundColor Blue "[$inputFile]" -NoNewline
  Write-Host -ForegroundColor White " → % → " -NoNewline
  Write-Host -ForegroundColor Green "[$outputFile]"
}


$totalCopiedSizeInBytes = 0
$totalCopiedFiles = 0
function LogCopySucces {
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Blue "`n[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Green " :: Копирование файлов выполнено успешно"

  $totalSizeInKB = $totalCopiedSizeInBytes / 1KB
  $totalSizeInMB = $totalSizeInKB / 1024
  $copiedSize = if ($totalSizeInMB -ge 1) { $totalSizeInMB.ToString("N2") + " GB" } else { $totalSizeInKB.ToString("N2") + " KB" }

  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Общий объём: $copiedSize"
  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Количество файлов: $totalCopiedFiles"
}

function Get-Recursion {
  $confirmation = Read-Host "Произвести рекурсивную обработку файлов? (Y/N)"
  if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    return Get-ChildItem -Path $directory -Filter "*.css" -Recurse
  } 
  return Get-ChildItem -Path $directory -Filter "*.css"
}

Set-Location $directory
$minifyScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "minify.ps1"
$cssFiles = Get-Recursion

foreach ($file in $cssFiles) {
  $currentCssPath = $file.FullName
  $relativePath = $currentCssPath.Substring($directory.Length + 1)
  $outputFileName = $file.FullName.Replace($directory, "") -replace "^\\"
  $outputFileName = $outputFileName -replace "\.css$", ".min.css"
  & $minifyScriptPath -cssPath $currentCssPath
  LogToFile $relativePath -outputFile $outputFileName
  $totalCopiedSizeInBytes += (Get-Item -Path $outputFileName).Length
  $totalCopiedFiles++
}

LogCopySucces
Start-Sleep -Seconds 5
