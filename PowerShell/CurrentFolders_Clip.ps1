$directory = $args[0]

if (-not $directory) {
    $directory = $PSScriptRoot
}

function Copy-ContentAndDelete ($filePath) {
    $fileContent = Get-Content -Path $filePath -Raw
    $fileContent | Set-Clipboard
    Remove-Item -Path $filePath -Force
}

Set-Location $directory
(Get-ChildItem $directory | Where-Object {$_.PSIsContainer -and $_.Name -ne '_folders.txt'}).Name | Out-File -Force -FilePath "_folders.txt"
Copy-ContentAndDelete -filePath "_folders.txt"