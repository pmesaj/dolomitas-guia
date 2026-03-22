$ErrorActionPreference = "Stop"

$dir = "c:\Users\Francisco Mesa\Coordenadas Secretas"
$files = Get-ChildItem -Path $dir -Filter "*.html" | Where-Object { $_.Name -ne "index.html" }

$count = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Si ya tiene el enlace incrustado (como lago-di-braies.html), sáltalo
    if ($content -match "\.back-link") { 
        Write-Host "Saltando $($file.Name) (Ya tiene el enlace)"
        continue 
    }
    
    # 1. Inyectar CSS
    # Usamos sintaxis regex safe para reemplazar exactamente "/* HERO */"
    # Escapamos los asteriscos
    $oldCss = "/\* HERO \*/"
    $newCss = "/* HERO */`r`n    .back-link { display: inline-block; color: rgba(255,255,255,0.7); font-size: 13px; text-decoration: none; margin-bottom: 20px; font-weight: 600; transition: color 0.2s; }`r`n    .back-link:hover { color: #fff; text-decoration: underline; }"
    $content = $content -replace $oldCss, $newCss
    
    # 2. Inyectar HTML
    $oldHtml = '<div class="hero-content">'
    $newHtml = '<div class="hero-content">`r`n    <a href="https://dolomitas.guiassecretas.com/" class="back-link">&larr; Volver al índice</a><br>'
    $content = $content -replace $oldHtml, $newHtml
    
    # Sobreescribir el archivo
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    $count++
    Write-Host "Actualizado $($file.Name)"
}

Write-Host "Total de archivos HTML actualizados con éxito: $count"
