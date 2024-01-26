﻿param(
    [string]$outputPath = ".\"
)

function Write-VersionInfoToFile {
    param(
        [string]$verName,
        [string]$verURL,
        [string]$filename
    )

    try {
        $filePath = Join-Path $outputPath $filename
        # Проверяем, существует ли директория, и создаем ее при необходимости
        if (-not (Test-Path $outputPath)) {
            New-Item -ItemType Directory -Path $outputPath | Out-Null
        }
        Add-Content -Path $filePath -Value "verName=$verName" -Force
        Add-Content -Path $filePath -Value "verURL=$verURL" -Force
        Write-Host "Data is written: $filePath"
    } catch {
        Write-Host "Error: $_"
    }
}

function Get-Latest-PowerShell-Installer-URL {
    $releasesUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases'

    try {
        $response = Invoke-RestMethod -Uri $releasesUrl -Method Get
        if ($response) {
            $sortedReleases = $response | Sort-Object { [DateTime]$_.published_at } -Descending
            $latestRelease = $sortedReleases[0]

            $installerUrl = $null
            foreach ($asset in $latestRelease.assets) {
                if ($asset.name -like '*x64.msi') {
                    $installerUrl = $asset.browser_download_url
                    break
                }
            }

            if ($installerUrl) {
                return $latestRelease.tag_name, $installerUrl
            } else {
                Write-Host 'MSI was not found Win x64.'
                return $null, $null
            }
        }
    } catch {
        Write-Host "Error: $_"
        return $null, $null
    }
}

$latestVersion, $latestInstallerUrl = Get-Latest-PowerShell-Installer-URL
if ($latestVersion -and $latestInstallerUrl) {
    Write-VersionInfoToFile -verName $latestVersion -verURL $latestInstallerUrl -filename 'PShell.txt'
}
