# ztrx launcher: runs the game for normal play (no scripted presses, no capture).
param(
    [Parameter(Mandatory = $true)][string]$Game,
    [string]$Cache = "$env:LOCALAPPDATA\ztrx\cache",
    [string]$Data = "$env:LOCALAPPDATA\ztrx\data",
    [string]$Exe = ""
)
# Windows PowerShell 5.1 can leave $PSScriptRoot empty inside param(), so the
# script's folder is worked out here instead.
$here = $PSScriptRoot
if (-not $here) { $here = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $Exe) {
    $candidates = @(
        "$here\..\target\release\victory.exe",
        "$here\..\victory.exe",
        "$here\victory.exe"
    )
    $Exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $Exe) {
        Write-Error "victory.exe not found. Looked in:`n  $($candidates -join "`n  ")`nPass its path with -Exe."
        exit 1
    }
}
if (-not (Test-Path $Exe)) { Write-Error "victory.exe not found at $Exe"; exit 1 }
$Exe = (Resolve-Path $Exe).Path
foreach ($v in "VICTORY_KEYS", "VICTORY_CAPTURE", "VICTORY_CAPTURE_FRAMES", "VICTORY_DUMP_TARGETS") {
    Remove-Item "Env:$v" -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force $Cache, $Data | Out-Null
$env:VICTORY_CACHE_DIR = $Cache
$env:VICTORY_DATA_DIR = $Data
Write-Host "Running $Exe"
& $Exe run $Game --execute 2>&1 | Out-File "$env:TEMP\ztrx.log" -Encoding utf8
Write-Host "Exited with $LASTEXITCODE; log: $env:TEMP\ztrx.log"
