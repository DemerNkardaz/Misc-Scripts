param(
  [string]$jsonPath
)

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
  $install = Read-Host "Not found powershell-yaml module in system. Install it? (Y/N)"
  if ($install -eq "Y") {
    Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
  }
  else {
    Write-Host "Module powershell-yaml installing skipped by user. Exit"
    exit
  }
}

$jsonContent = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json
$yamlContent = ConvertTo-Yaml -Data $jsonContent
$yamlPath = [System.IO.Path]::ChangeExtension($jsonPath, ".yaml")
Set-Content -Path $yamlPath -Value $yamlContent
Write-Host "Convertation successful. File saved as $yamlPath"
