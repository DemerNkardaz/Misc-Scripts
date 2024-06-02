param(
  [string]$cssPath
)
if (-not (Test-Path $cssPath)) {
  Write-Host "Файл не найден: $cssPath"
  exit
}
$minifiedCssPath = $cssPath -replace '\.css$', '.min.css'
$cssContent = Get-Content $cssPath -Raw
$cssContent = $cssContent -replace '/\*[^*]*\*+(?:[^/*][^*]*\*+)*/', ''
$cssContent = $cssContent -replace '\s+', ' ' -replace '^\s+|\s+$'
$cssContent = $cssContent -replace '\s*([{}:;,])\s*', '$1'
$cssContent | Out-File $minifiedCssPath -Encoding UTF8
