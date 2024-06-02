$clipboardContent = Get-Clipboard -Raw

$folderNames = $clipboardContent -split '\r?\n'

function IsSimpleText($line) {
  return $line -match '^[\p{L}\d\s_-]+$'
}

$simpleTextLines = $folderNames | Where-Object { IsSimpleText($_) }

Write-Host "Будут созданы следующие папки:"
$simpleTextLines | ForEach-Object { Write-Host "$_" }

$confirmation = Read-Host "Хотите создать эти папки? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
  $currentDirectory = Get-Location
  $simpleTextLines | ForEach-Object {
    $folderPath = Join-Path -Path $currentDirectory -ChildPath $_
    New-Item -Path $folderPath -ItemType Directory -Force
    Write-Host "Папка создана: $folderPath"
  }
  Write-Host "Папки успешно созданы."
}
else {
  Write-Host "Создание отменено."
}
