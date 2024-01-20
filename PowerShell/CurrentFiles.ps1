$directory = $args[0]

if (-not $directory) {
    $directory = $PSScriptRoot
}

$excludeFiles = @('_files.txt', '_folders.txt', '_list.html', '_table.json')

Set-Location $directory
(Get-ChildItem $directory | Where-Object {!$_.PSIsContainer -and $_.Name -notin $excludeFiles}).Name | Out-File -Force -FilePath "_files.txt"
notepad "_files.txt"
