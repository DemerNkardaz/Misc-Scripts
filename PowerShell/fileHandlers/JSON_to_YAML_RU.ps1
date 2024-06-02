param(
  [string]$jsonPath
)

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
  $install = Read-Host "Модуль powershell-yaml не найден. Установить его? (Y/N)"
  if ($install -eq "Y") {
    Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
  }
  else {
    Write-Host "Установка powershell-yaml отменена пользователем. Выход"
    exit
  }
}

$jsonContent = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json
$yamlContent = ConvertTo-Yaml -Data $jsonContent
$yamlPath = [System.IO.Path]::ChangeExtension($jsonPath, ".yaml")
Set-Content -Path $yamlPath -Value $yamlContent
Write-Host "Конвертация завершена. Файл сохранен как $yamlPath"
