param(
  [string]$yamlPath
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

$yamlContent = Get-Content -Path $yamlPath -Raw | ConvertFrom-Yaml
$jsonContent = $yamlContent | ConvertTo-Json -Depth 10
$jsonPath = [System.IO.Path]::ChangeExtension($yamlPath, ".json")
Set-Content -Path $jsonPath -Value $jsonContent
Write-Host "Convertation successful. File saved as $jsonPath"
