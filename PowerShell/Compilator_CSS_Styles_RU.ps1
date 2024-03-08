$cssFiles = Get-ChildItem -Path . -Filter *.css
$combinedContent = ""
foreach ($file in $cssFiles) {
  $content = Get-Content $file.FullName
  $combinedContent += $content
}
$minifiedContent = $combinedContent -replace '/\*.*?\*/', '' -replace '\s+', ''
Write-Host "Скрипт собирает все .CSS файлы текущей директории и формирует из них единый .min.css"
Write-Host "Вы можете указать имя создаваемого файла или оставить поле пустым для использования имени текущей директории, .min.css добавиться к файлу автоматически"
$fileName = Read-Host "Имя файла"
if ([string]::IsNullOrWhiteSpace($fileName)) {
  $currentDirectory = (Get-Item -Path ".\").Name
  $fileName = "$currentDirectory.min.css"
}
else {
  $fileName += ".min.css"
}
$minifiedContent | Out-File -FilePath $fileName -Encoding utf8
Write-Host "Минифицированный .css файл успешно создан: $fileName"
