function Create-HTMLList ($directory, $indentLevel) {
    $directoryName = [System.IO.Path]::GetFileName($directory)
    $indent = " " * ($indentLevel * 4)
    
    $htmlContent = @"
$indent<li><span>$directoryName</span>
$indent    <ul>`n
"@

    Get-ChildItem -Path $directory -Directory | ForEach-Object {
        $subDirectory = $_.FullName
        $htmlContent += Create-HTMLList $subDirectory ($indentLevel + 1)
    }

    $files = Get-ChildItem -Path $directory -File | Where-Object { $_.Name -notin $excludeFiles }

    foreach ($file in $files) {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $htmlContent += @"
$indent        <li><span>$fileName</span></li>`n
"@
    }

    $htmlContent += @"
$indent    </ul>
$indent</li>`n
"@

    return $htmlContent
}

$directory = $args[0]
if (-not $directory) {
    $directory = $PSScriptRoot
}
Set-Location $directory
$directoryName = [System.IO.Path]::GetFileName($directory)

$excludeFiles = @('_files.txt', '_folders.txt', '_list.html', '_table.json')

$htmlContent = Create-HTMLList $directory 0

$htmlContent | Out-File -FilePath "$directoryName.html" -Encoding UTF8
notepad "$directoryName.html"
