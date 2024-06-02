param(
  [string]$jsonPath
)

function Compress-Json {
  param (
    [string]$json
  )
  $minifiedJson = $json -replace '(?<!\\)":\s*"(?!\s*[{[])', '":"' `
    -replace '(?<!\S)\s+', '' `
    -replace '\s+(?!\S)', '' `
    -replace '\r\n|\n|\r', ''

  return $minifiedJson
}

if (Test-Path -Path $jsonPath) {
  try {
    $jsonContent = Get-Content -Path $jsonPath -Raw
    $minifiedJson = Compress-Json  -json $jsonContent
    $minifiedJsonPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($jsonPath), "$([System.IO.Path]::GetFileNameWithoutExtension($jsonPath)).min.json")
    Set-Content -Path $minifiedJsonPath -Value $minifiedJson
  }
  catch {
    Write-Error "An error occurred: $_"
  }
}