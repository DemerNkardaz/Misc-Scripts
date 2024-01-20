$excludeFiles = @('_files.txt', '_folders.txt', '_list.html', '_table.json')

function Get-DirectoryInfo($path) {
    $directory = Get-ChildItem $path

    $result = @()

    foreach ($item in $directory) {
        if ($excludeFiles -contains $item.Name) {
            continue
        }

        $obj = New-Object -TypeName PSObject
        $fileName = $item.Name
        if ($fileName -notmatch '^\.[^.]+$') {
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        }
        $obj | Add-Member -MemberType NoteProperty -Name "name" -Value $fileName

        if ($item.PSIsContainer) {
            $obj | Add-Member -MemberType NoteProperty -Name "link" -Value ""
            $obj | Add-Member -MemberType NoteProperty -Name "childs" -Value @(Get-DirectoryInfo $item.FullName)
        }
        else {
            $obj | Add-Member -MemberType NoteProperty -Name "link" -Value ""
        }

        $result += $obj
    }

    return $result
}

$currentPath = $args[0]
if (-not $currentPath) {
    $currentPath = $PSScriptRoot
}
function Copy-ContentAndDelete ($filePath) {
    $fileContent = Get-Content -Path $filePath -Raw
    $fileContent | Set-Clipboard
    Remove-Item -Path $filePath -Force
}
Set-Location $currentPath

$directoryName = [System.IO.Path]::GetFileName($currentPath)
$rootObj = New-Object -TypeName PSObject
$rootObj | Add-Member -MemberType NoteProperty -Name "name" -Value $directoryName
$rootObj | Add-Member -MemberType NoteProperty -Name "link" -Value ""
$rootObj | Add-Member -MemberType NoteProperty -Name "childs" -Value (Get-DirectoryInfo $currentPath)

$tableObj = New-Object -TypeName PSObject
$tableObj | Add-Member -MemberType NoteProperty -Name "root" -Value @($rootObj)


$result = $tableObj | ConvertTo-Json -Depth 75

$result | Out-File "$currentPath\_table.json" -Encoding UTF8

Copy-ContentAndDelete -filePath "_table.json"