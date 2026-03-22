$ErrorActionPreference = "Stop"
$dir = "c:\Users\Francisco Mesa\Coordenadas Secretas"
$files = Get-ChildItem -Path $dir -Filter "*.html" | Where-Object { $_.Name -ne "lago-di-braies.html" }

$newFavicon = '<link rel="icon" type="image/png" href="https://msgsndr-private.storage.googleapis.com/companyPhotos/6074beb4-3113-4008-903a-d7dce034ab02.png">'
$count = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Skip if already perfectly matched
    if ($content -match "6074beb4-3113-4008-903a-d7dce034ab02.png") { continue }
    
    # Remove any existing favicon
    # We use regex to match any line starting with spaces and <link rel="icon"...
    $content = $content -replace '(?m)^\s*<link rel="icon".*?\r?\n', ''
    
    # Inject exactly after <meta charset="UTF-8">
    # Note: Escaping double quotes inside powershell replacement
    $oldTag = '<meta charset="UTF-8">'
    $newTag = "<meta charset=`"UTF-8`">`r`n  $newFavicon"
    
    if ($content -match '<meta charset="UTF-8">') {
        $content = $content -replace $oldTag, $newTag
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $count++
    } else {
        Write-Host "No se encontró etiqueta charset en $($file.Name)"
    }
}

Write-Host "Modificados $count archivos HTML con el nuevo favicon."
