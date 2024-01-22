$jsonString = Get-Clipboard
$jsonData = $jsonString | ConvertFrom-Json

if (-not $jsonData.root -is [array]) {
    Write-Host "Error: root element does not exist or this is not an array."
    exit
}

function ShowFolders($parentPath, $folders) {
    foreach ($folder in $folders) {
        $folderPath = Join-Path $parentPath $folder.name

        # Добавляем проверку наличия ключа childs
        if ($folder.PSObject.Properties["childs"]) {
            # Проверяем, существует ли папка, прежде чем выводить
            if (-not (Test-Path $folderPath)) {
                $relativePath = $folderPath.Substring($PWD.Path.Length + 1)
                Write-Host "$relativePath"
            }

            ShowFolders $folderPath $folder.childs
        }
    }
}

Write-Host "Will be created following folders: "
ShowFolders $PWD $jsonData.root

$confirmation = Read-Host "Do you want to create these folders? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    function CreateFoldersRecursively($parentPath, $folders) {
        foreach ($folder in $folders) {
            $folderPath = Join-Path $parentPath $folder.name

            # Добавляем проверку наличия ключа childs
            if ($folder.PSObject.Properties["childs"]) {
                # Проверяем, существует ли папка, прежде чем создавать новую
                if (-not (Test-Path $folderPath)) {
                    New-Item -ItemType Directory -Path $folderPath | Out-Null
                }

                # Рекурсивный вызов для дочерних элементов
                CreateFoldersRecursively $folderPath $folder.childs
            }
        }
    }

    CreateFoldersRecursively $PWD $jsonData.root
    Write-Host "Folders successfully created."
} else {
    Write-Host "Creating aborted."
}
