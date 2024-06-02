$lockFile = ".lock.filecopy"

function Select-DestinationFolderName {
  $destinationFolderName = Read-Host "Enter the foldername or skip for [/sorted files/]"
  if (-not $destinationFolderName) {
    $destinationFolderName = "sorted files"
  }
  return $destinationFolderName
}
Write-Host "The file [$lockFile] prevents the copying of files from subdirectories"
$destinationFolder = Select-DestinationFolderName
function LogToFile {
  param (
    [string]$message
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  $messageParts = $message -split ' → '
  $relativePath = $messageParts[0]
  $copiedFileName = $messageParts[-1]
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor White " :: " -NoNewline
  Write-Host -ForegroundColor Blue "[$relativePath]" -NoNewline
  Write-Host -ForegroundColor White " → % → " -NoNewline
  Write-Host -ForegroundColor Green "[$destinationFolder/$copiedFileName]"
}

function LogFileAlreadyExists {
  param (
    [string]$message
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  $messageParts = $message -split ' → '
  $copiedFileName = $messageParts[-1]
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor White " :: File [$copiedFileName] already exists in [/$destinationFolder/]"
}

function LogFolderSkip {
  param (
    [string]$message
  )
  $timestamp = Get-Date -Format "HH:mm:ss"
  $relativePath = $message
  Write-Host -ForegroundColor Yellow "[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Yellow " :: Skipping directory [$relativePath] : founded file [«$lockFile»]"
}

function LogCopySucces {
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Blue "`n[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Green " :: Copying of files completed successfully"
}

function LogNoFilesToCopy {
  $timestamp = Get-Date -Format "HH:mm:ss"
  Write-Host -ForegroundColor Blue "`n[$timestamp]" -NoNewline
  Write-Host -ForegroundColor Yellow " :: No files to copy founded"
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
  Write-Host "Creating folder [/$sortedFolder/]"
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
    LogFolderSkip "$($subDir.FullName)"
    continue
  }

  $files = Get-ChildItem -Path $subDir.FullName -Recurse -File

  foreach ($file in $files) {
    $newFileName = "$rootFolderName`__$($file.Name)"
    $destinationPath = Join-Path -Path $sortedFolder -ChildPath $newFileName
    $relativePath = Get-RelativePath -AbsoluteFilePath $file.FullName -BaseDirectory $directory

    if (Test-Path -Path $destinationPath) {
      $sourceFileHash = (Get-FileHash -Path $file.FullName).Hash
      $destinationFileHash = (Get-FileHash -Path $destinationPath).Hash

      if ($sourceFileHash -eq $destinationFileHash) {
        LogFileAlreadyExists "$($relativePath) → % → $destinationFolder/$($newFileName)"
        continue
      }
      else {
        $counter = 1
        while (Test-Path -Path $destinationPath) {
          $newFileName = "$rootFolderName`__$counter`__$($file.Name)"
          $destinationPath = Join-Path -Path $sortedFolder -ChildPath $newFileName
          $counter++
        }
      }
    }
    Copy-Item -Path $file.FullName -Destination $destinationPath
    LogToFile "$($relativePath) → % → $destinationFolder/$($newFileName)"
    $filesCopied = $true
  }
}

if (-not $filesCopied) {
  LogNoFilesToCopy
}
else {
  LogCopySucces
}

Start-Sleep -Seconds 5
