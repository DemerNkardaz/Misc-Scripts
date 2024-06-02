$clipboardContent = Get-Clipboard -Raw

$folderNames = $clipboardContent -split '\r?\n'

function IsSimpleText($line) {
  return $line -match '^[\p{L}\d\s_-]+$'
}

$simpleTextLines = $folderNames | Where-Object { IsSimpleText($_) }

Write-Host "Will be created following folders: "
$simpleTextLines | ForEach-Object { Write-Host "$_" }

$confirmation = Read-Host "Do you want to create these folders? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
  $currentDirectory = Get-Location
  $simpleTextLines | ForEach-Object {
    $folderPath = Join-Path -Path $currentDirectory -ChildPath $_
    New-Item -Path $folderPath -ItemType Directory -Force
    Write-Host "Папка создана: $folderPath"
  }
  Write-Host "Folders successfully created."
}
else {
  Write-Host "Creating aborted."
}
