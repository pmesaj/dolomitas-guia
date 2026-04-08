$ErrorActionPreference = "Stop"
$dir = "c:\Users\Francisco Mesa\Coordenadas Secretas"

$excluded = @("index.html", "enciclopedia.html", "estado.html")
$files = Get-ChildItem -Path $dir -Filter "*.html" | Where-Object { $excluded -notcontains $_.Name }

$count = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # 1. Skip if already has author bio
    if ($content -match "<!-- AUTHOR BIO -->") { continue }
    
    $modified = $false
    
    # 2. Fix the opening tags
    if ($content -match "<div class=`"container`">\s*<div class=`"article-body`">") {
        $content = $content -replace "<div class=`"container`">\s*<div class=`"article-body`">", "<main class=`"container`">`r`n  <article class=`"article-body`">"
        $modified = $true
    }
    
    # 3. Fix the closing tags, and INJECT the HTML Author Box right before </article>
    $oldFooterTags = "    </div>`r`n`r`n  </div>`r`n</div>"
    $newHTML = "    </div>`r`n`r`n    <!-- AUTHOR BIO -->`r`n    <div class=`"author-bio`">`r`n      <img src=`"https://assets.cdn.filesafe.space/o8XvqUKM4MpBIFAkxSoC/media/69bfc50d9bd139e670f723ca.png`" alt=`"Paco Mesa`" class=`"author-avatar`">`r`n      <div class=`"author-text`">`r`n        <h4>Paco Mesa</h4>`r`n        <p>Creador de <strong>La Guía Secreta de Dolomitas</strong>. Tras años recorriendo estos senderos, mi obsesión es ayudarte a planificar tu viaje evitando malas decisiones, optimizando tus tiempos y mostrándote las verdaderas Dolomitas.</p>`r`n      </div>`r`n    </div>`r`n`r`n  </article>`r`n</main>"
    
    # In regex we can just match closing tags. Some might have fewer spaces.
    # Let's use a regex approach for the tail because exact spacing might vary
    $tailRegex = "</div>\s*</div>\s*</div>\s*(?=<br>|</body>|\s*</body>)"
    # Actually arabba.html ends with: 
    #         </div>
    #       </div>
    #     </div>
    # 
    #   </div>
    # </div>
    # </body>
    
    # Safer: just replace `<div class="container">` opening and its matching closings. But wait!
    # If the opening replaces successfully, let's just do a regex replace for the last `</div>  </div>` before `</body>`.
    if ($modified) {
        $content = $content -replace "</div>\s*</div>\s*(?=</body>)", $newHTML + "`r`n`r`n"
        
        # 4. Inject CSS
        $oldCss = "/* FOOTER */"
        $newCss = "/* AUTHOR BIO */`r`n    .author-bio { background: #f9f9f9; border: 1px solid #eaeaea; border-radius: 12px; padding: 24px; margin: 40px 0 0 0; display: flex; align-items: center; gap: 20px; }`r`n    .author-avatar { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; flex-shrink: 0; border: 2px solid var(--gold); }`r`n    .author-text h4 { font-size: 16px; margin-bottom: 6px; color: var(--black); font-weight: 700; }`r`n    .author-text p { font-size: 14px; line-height: 1.6; margin: 0; color: #555; }`r`n    @media (max-width: 600px) { .author-bio { flex-direction: column; text-align: center; padding: 20px; } }`r`n`r`n    /* FOOTER */"
        $content = $content -replace [regex]::Escape($oldCss), $newCss
        
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $count++
    }
}

Write-Host "Modificados y homogeneizados $count archivos HTML con la nueva caja de autor."
