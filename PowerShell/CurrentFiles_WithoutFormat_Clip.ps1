$directory = $args[0]

if (-not $directory) {
    $directory = $PSScriptRoot
}

function Copy-ContentAndDelete ($filePath) {
    $fileContent = Get-Content -Path $filePath -Raw
    $fileContent | Set-Clipboard
    Remove-Item -Path $filePath -Force
}

$excludeFiles = @('_files.txt', '_folders.txt', '_list.html', '_table.json')

Set-Location $directory
$fileList = (Get-ChildItem $directory | Where-Object {!$_.PSIsContainer -and $_.Name -notin $excludeFiles}).BaseName
$fileList | Out-File -Force -FilePath "_files.txt"

Copy-ContentAndDelete -filePath "_files.txt"