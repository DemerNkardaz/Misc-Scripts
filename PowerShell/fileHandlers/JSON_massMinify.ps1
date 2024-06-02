$directory = $args[0]

if (-not $directory) {
  $directory = $PSScriptRoot
}
Set-Location $directory

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
  Write-Host -ForegroundColor Green " :: Copying of files completed successfully"

  $totalSizeInKB = $totalCopiedSizeInBytes / 1KB
  $totalSizeInMB = $totalSizeInKB / 1024
  $copiedSize = if ($totalSizeInMB -ge 1) { $totalSizeInMB.ToString("N2") + " GB" } else { $totalSizeInKB.ToString("N2") + " KB" }

  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Total size: $copiedSize"
  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Files count: $totalCopiedFiles"
}

function Get-Recursion {
  $confirmation = Read-Host "Do you want recursive file handling? (Y/N)"
  if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    return Get-ChildItem -Path $directory -Filter "*.json" -Recurse
  } 
  return Get-ChildItem -Path $directory -Filter "*.json"
}


$jsonScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "minify.ps1"
$jsonFiles = Get-Recursion

foreach ($file in $jsonFiles) {
  $currentJsonPath = $file.FullName
  $relativePath = $currentJsonPath.Substring($directory.Length + 1)
  $outputFileName = $file.FullName.Replace($directory, "") -replace "^\\"
  $outputFileName = $outputFileName -replace "\.json$", ".min.json"
  & $jsonScriptPath -jsonPath $currentJsonPath
  LogToFile $relativePath -outputFile $outputFileName
  $totalCopiedSizeInBytes += (Get-Item -Path $outputFileName).Length
  $totalCopiedFiles++
}

LogCopySucces
Start-Sleep -Seconds 5
