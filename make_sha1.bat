@echo off
REM ===================================================================
REM  Drag & drop your resource pack zip onto this file.
REM  It prints 4 lines for server.properties and copies them to the clipboard.
REM ===================================================================
set "PACK=%~1"
if "%PACK%"=="" (
    echo Drag and drop the resource pack zip onto this bat file.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = Get-Content -LiteralPath '%~f0' -Raw; Invoke-Expression $s.Substring($s.IndexOf('#PS'+'-START') + 9)"
echo.
pause
exit /b 0

#PS-START
$ErrorActionPreference = 'Stop'
$file = $env:PACK
if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    Write-Host "File not found: $file" -ForegroundColor Red
} else {
    $base   = 'https://raw.githubusercontent.com/ekarose0/Minecraft-Modpack-Translate/master/'
    $prompt = '{"text":"\uC774 \uC11C\uBC84\uB294 \uAC00\uC774\uB4DC \uD55C\uAE00\uBC88\uC5ED \uB9AC\uC18C\uC2A4\uD329\uC774 \uC788\uC5B4\uC694! \uBC1B\uC744\uB798\uC694?","color":"aqua"}'

    $sha  = (Get-FileHash -LiteralPath $file -Algorithm SHA1).Hash.ToLower()
    $id   = [guid]::NewGuid().ToString()
    $name = [uri]::EscapeDataString([IO.Path]::GetFileName($file))

    $lines = @(
        "resource-pack=$base$name",
        "resource-pack-id=$id",
        "resource-pack-prompt=$prompt",
        "resource-pack-sha1=$sha"
    )
    $text = $lines -join "`r`n"

    Write-Host ""
    Write-Host "File : $([IO.Path]::GetFileName($file))"
    Write-Host "SHA1 : $sha" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "---- paste into server.properties ----" -ForegroundColor Cyan
    $lines | ForEach-Object { Write-Host $_ }
    Write-Host "--------------------------------------" -ForegroundColor Cyan

    try {
        Set-Clipboard -Value $text
        Write-Host "Copied to clipboard." -ForegroundColor Green
    } catch {
        Write-Host "Clipboard copy failed. Copy the lines above by hand." -ForegroundColor Red
    }

    $outFile = Join-Path (Split-Path -Parent $file) 'server_properties_resourcepack.txt'
    try {
        [IO.File]::WriteAllText($outFile, $text + "`r`n", (New-Object Text.UTF8Encoding $false))
        Write-Host "Saved: $outFile"
    } catch {}
}
