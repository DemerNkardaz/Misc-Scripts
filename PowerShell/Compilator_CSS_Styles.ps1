$cssFiles = Get-ChildItem -Path . -Filter *.css
$combinedContent = ""
foreach ($file in $cssFiles) {
  $content = Get-Content $file.FullName
  $combinedContent += $content
}
$minifiedContent = $combinedContent -replace '/\*.*?\*/', '' -replace '\s+', ''
Write-Host "Collects all .CSS files in the current directory and creates a single .min.css"
Write-Host "You can specify the name of the created file or leave the field empty and the name of the current directory will be used as a file name, .min.css will be added to the file automatically"
$fileName = Read-Host "File name"
if ([string]::IsNullOrWhiteSpace($fileName)) {
  $currentDirectory = (Get-Item -Path ".\").Name
  $fileName = "$currentDirectory.min.css"
}
else {
  $fileName += ".min.css"
}
$minifiedContent | Out-File -FilePath $fileName -Encoding utf8
Write-Host "Minified .css file created: $fileName"
