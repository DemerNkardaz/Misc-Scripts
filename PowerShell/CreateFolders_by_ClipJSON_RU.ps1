$jsonString = Get-Clipboard
$jsonData = $jsonString | ConvertFrom-Json

if (-not $jsonData.root -is [array]) {
    Write-Host "Ошибка: элемент root не существует или не является массивом."
    exit
}

function ShowFolders($parentPath, $folders) {
    foreach ($folder in $folders) {
        $folderPath = Join-Path $parentPath $folder.name
        if ($folder.PSObject.Properties["childs"]) {
            if (-not (Test-Path $folderPath)) {
                $relativePath = $folderPath.Substring($PWD.Path.Length + 1)
                Write-Host "$relativePath"
            }

            ShowFolders $folderPath $folder.childs
        }
    }
}

Write-Host "Будут созданы следующие папки: "
ShowFolders $PWD $jsonData.root

$confirmation = Read-Host "Хотите создать эти папки? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    function CreateFoldersRecursively($parentPath, $folders) {
        foreach ($folder in $folders) {
            $folderPath = Join-Path $parentPath $folder.name

            if ($folder.PSObject.Properties["childs"]) {
                if (-not (Test-Path $folderPath)) {
                    New-Item -ItemType Directory -Path $folderPath | Out-Null
                }
                CreateFoldersRecursively $folderPath $folder.childs
            }
        }
    }

    CreateFoldersRecursively $PWD $jsonData.root
    Write-Host "Папки успешно созданы."
}
else {
    Write-Host "Создание отменено."
}
