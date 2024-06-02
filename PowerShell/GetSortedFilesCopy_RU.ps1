$lockFile = ".lock.filecopy"

function Select-DestinationFolderName {
  $destinationFolderName = Read-Host "Введите имя папки или пропустите для создания [/sorted files/]"
  if (-not $destinationFolderName) {
    $destinationFolderName = "sorted files"
  }
  return $destinationFolderName
}
Write-Host "Наличие в папках файла [$lockFile] предотвращает копирование файлов из них"
$destinationFolder = Select-DestinationFolderName
function LogToFile {
  param (
    [string]$relativePath,
    [string]$copiedFileName
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor White " :: " -NoNewline
  Write-Host -ForegroundColor Blue "[$relativePath]" -NoNewline
  Write-Host -ForegroundColor White " → % → " -NoNewline
  Write-Host -ForegroundColor Green "[$destinationFolder/$copiedFileName]"
}

function LogFileAlreadyExists {
  param (
    [string]$copiedFileName
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor White " :: Файл [$copiedFileName] уже существует в папке [/$destinationFolder/]"
}

function LogFolderSkip {
  param (
    [string]$relativePath
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Yellow " :: Пропуск директории [$relativePath] : обнаружен файл [«$lockFile»]"
}


$totalCopiedSizeInBytes = 0
$totalCopiedFiles = 0
function LogCopySucces {
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Blue "`n[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Green " :: Копирование файлов выполнено успешно"

  $totalSizeInMB = $totalCopiedSizeInBytes / 1MB
  $totalSizeInGB = $totalSizeInMB / 1024
  $copiedSize = if ($totalSizeInGB -ge 1) { $totalSizeInGB.ToString("N2") + " GB" } else { $totalSizeInMB.ToString("N2") + " MB" }

  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Общий объём: $copiedSize"
  Write-Host -ForegroundColor Blue "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Cyan " :: Количество файлов: $totalCopiedFiles"
}


function LogNoFilesToCopy {
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Blue "`n[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Yellow " :: Нет файлов для копирования"
}

function Get-RelativePath {
  param (
    [string]$AbsoluteFilePath,
    [string]$BaseDirectory
  )
  $BaseDirectory = (Get-Item -Path $BaseDirectory).FullName
  $AbsoluteFilePath = (Get-Item -Path $AbsoluteFilePath).FullName
  return $AbsoluteFilePath.Substring($BaseDirectory.Length + 1)
}

$directory = $args[0]

if (-not $directory) {
  $directory = $PSScriptRoot
}

Set-Location $directory

$sortedFolder = Join-Path -Path $directory -ChildPath $destinationFolder
if (-not (Test-Path -Path $sortedFolder)) {
  Write-Host "Создаем папку [/$sortedFolder/]"
  New-Item -ItemType Directory -Path $sortedFolder
}

$lockFilePath = Join-Path -Path $sortedFolder -ChildPath $lockFile
New-Item -ItemType File -Path $lockFilePath -Force

$subDirectories = Get-ChildItem -Path $directory -Directory | Where-Object { $_.FullName -ne $sortedFolder }

$filesCopied = $false

foreach ($subDir in $subDirectories) {
  $rootFolderName = $subDir.Name

  $lockFileInSubDir = Join-Path -Path $subDir.FullName -ChildPath $lockFile
  if (Test-Path -Path $lockFileInSubDir) {
    LogFolderSkip $subDir.FullName
    continue
  }

  $files = Get-ChildItem -Path $subDir.FullName -Recurse -File

  foreach ($file in $files) {
    $skipped = $false
    $newFileName = "$rootFolderName`__$($file.Name)"
    $destinationPath = Join-Path -Path $sortedFolder -ChildPath $newFileName
    $relativePath = Get-RelativePath -AbsoluteFilePath $file.FullName -BaseDirectory $directory

    if (Test-Path -Path $destinationPath) {
      if ((Get-FileHash -Path $file.FullName).Hash -eq $(Get-FileHash -Path $destinationPath).Hash) {
        LogFileAlreadyExists $newFileName
        $skipped = $true
        continue
      }
      if ((Get-Item $file.FullName).Length -eq (Get-Item $destinationPath).Length) {
        LogFileAlreadyExists $newFileName
        $skipped = $true
        continue
      }
      if (-not $skipped) {
        $counter = 1
        while (Test-Path -Path $destinationPath) {
          $newFileName = "$rootFolderName`__$counter`__$($file.Name)"
          $destinationPath = Join-Path -Path $sortedFolder -ChildPath $newFileName
          $counter++
        }
      }
      else {
        continue
      }
    }

    if (-not $skipped) {
      Copy-Item -Path $file.FullName -Destination $destinationPath
      LogToFile $relativePath -copiedFileName $newFileName
      $totalCopiedSizeInBytes += (Get-Item $destinationPath).Length
      $totalCopiedFiles++
      $filesCopied = $true
    }
  }
}

if (-not $filesCopied) {
  LogNoFilesToCopy
}
else {
  LogCopySucces
}

Start-Sleep -Seconds 5
