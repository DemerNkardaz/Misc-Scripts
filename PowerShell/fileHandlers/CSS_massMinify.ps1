$directory = $args[0]

if (-not $directory) {
  $directory = $PSScriptRoot
}

Set-Location $directory
$minifyScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "minify.ps1"
$cssFiles = Get-ChildItem -Path $directory -Filter "*.css" -Recurse
1
foreach ($file in $cssFiles) {
  $currentCssPath = $file.FullName
  & $minifyScriptPath -cssPath $currentCssPath
}
