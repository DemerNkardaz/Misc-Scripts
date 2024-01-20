$directory = $args[0]

if (-not $directory) {
    $directory = $PSScriptRoot
}

Set-Location $directory
(Get-ChildItem $directory | Where-Object { $_.PSIsContainer -and $_.Name -ne '_folders.txt' }).Name | Out-File -Force -FilePath "_folders.txt"
notepad "_folders.txt"
