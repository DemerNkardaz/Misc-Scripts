param(
  [string]$yamlPath
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

$yamlContent = Get-Content -Path $yamlPath -Raw | ConvertFrom-Yaml
$jsonContent = $yamlContent | ConvertTo-Json -Depth 10
$jsonPath = [System.IO.Path]::ChangeExtension($yamlPath, ".json")
Set-Content -Path $jsonPath -Value $jsonContent
Write-Host "Конвертация завершена. Файл сохранен как $jsonPath"
