<#
.SYNOPSIS
    Packages the Windows release build into a zip that can be handed to
    employees as-is.

.DESCRIPTION
    Chronus is distributed on Windows as a plain zip - no installer, no store,
    no code signing. This script produces that zip reproducibly:

      1. builds the release (skip with -SkipBuild),
      2. stages the build output,
      3. adds the three Visual C++ runtime DLLs, so the app starts on a PC that
         has never had Visual Studio or the redistributable installed,
      4. adds packaging/windows/LEIA-ME.txt (the bilingual employee readme),
      5. zips it and reports the SHA-256.

    It does not run `flutter analyze` or `flutter test`. Run those yourself
    before packaging something you intend to hand out.

    Note the app stores its data in %APPDATA%\com.matheussancha\chronus, not in
    the program folder, so users can unzip a new version over an old one
    without losing studies. See lib/src/data/app_directory.dart.

    Keep this file ASCII-only: Windows PowerShell 5.1 reads .ps1 as ANSI, and
    UTF-8 punctuation (em dashes, section signs) turns into mojibake that can
    break parsing.

.PARAMETER SkipBuild
    Package whatever is already in build\windows\x64\runner\Release.

.PARAMETER Label
    Version label used in the zip name. Defaults to today's date, because these
    are internal previews handed out repeatedly: a date says which drop someone
    is running, and pubspec's version does not yet mean what DESIGN.md section
    8.3 says v1 means.

.PARAMETER AllowMissingRuntime
    Package even if the Visual C++ runtime DLLs cannot be found. The zip will
    then only run on PCs that already have the redistributable.

.EXAMPLE
    .\tool\package_windows.ps1
    .\tool\package_windows.ps1 -SkipBuild -Label "0.5.0"
#>
[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [string]$Label = (Get-Date -Format "yyyy-MM-dd"),
    [switch]$AllowMissingRuntime
)

$ErrorActionPreference = "Stop"

$repo    = Split-Path -Parent $PSScriptRoot
$release = Join-Path $repo "build\windows\x64\runner\Release"
$dist    = Join-Path $repo "dist"
$stage   = Join-Path $dist "Chronus"
$readme  = Join-Path $repo "packaging\windows\LEIA-ME.txt"
$zipPath = Join-Path $dist "chronus-previa-$Label-windows-x64.zip"

# --- build ------------------------------------------------------------------
if ($SkipBuild) {
    Write-Host "Skipping build." -ForegroundColor Yellow
} else {
    Write-Host "Building Windows release..." -ForegroundColor Cyan
    Push-Location $repo
    try {
        flutter build windows --release
        if ($LASTEXITCODE -ne 0) { throw "flutter build windows failed (exit $LASTEXITCODE)." }
    } finally {
        Pop-Location
    }
}

if (-not (Test-Path $release)) {
    throw "No release build at $release. Run without -SkipBuild."
}

# --- locate the Visual C++ runtime -----------------------------------------
# Flutter's Windows apps link against these dynamically and they are NOT part of
# the build output, so a clean PC fails to start without them. Copy them from
# Visual Studio's redist folder; app-local deployment is licensed by Microsoft.
$crtDlls = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll")
$crtPattern = "C:\Program Files*\Microsoft Visual Studio\*\*\VC\Redist\MSVC\*\x64\Microsoft.VC*.CRT"

# Newest toolset wins. Sort on the parsed MSVC version rather than the string,
# so 14.44 does not sort below 14.9.
$crtDir = Get-ChildItem -Path $crtPattern -Directory -ErrorAction SilentlyContinue |
    Sort-Object -Property @{ Expression = {
        $v = [regex]::Match($_.FullName, '\\MSVC\\([\d\.]+)\\').Groups[1].Value
        if ($v) { [version]$v } else { [version]"0.0" }
    }} |
    Select-Object -Last 1

if (-not $crtDir) {
    $msg = "Visual C++ runtime DLLs not found under Visual Studio's redist folder."
    if ($AllowMissingRuntime) {
        Write-Warning "$msg Packaging without them; the app will only start on PCs that already have the redistributable."
    } else {
        throw "$msg Install the Visual Studio C++ workload, or pass -AllowMissingRuntime."
    }
}

# --- stage ------------------------------------------------------------------
Write-Host "Staging..." -ForegroundColor Cyan
# Clear only the staging folder, not all of dist: previously packaged zips are
# the drops already handed out, and you want to keep them around to know what
# any given employee is running.
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

Copy-Item -Recurse -Force (Join-Path $release "*") $stage

if ($crtDir) {
    foreach ($dll in $crtDlls) {
        $src = Join-Path $crtDir.FullName $dll
        if (-not (Test-Path $src)) {
            throw "Expected runtime DLL not found: $src"
        }
        Copy-Item $src $stage
    }
    Write-Host "  runtime DLLs from $($crtDir.FullName)"
}

if (Test-Path $readme) {
    Copy-Item $readme $stage
} else {
    Write-Warning "Employee readme missing at $readme. Packaging without it."
}

# --- manuals ----------------------------------------------------------------
# Ship the HTML, not the markdown: a .md double-clicked on a stock Windows PC
# opens in Notepad, where the screenshots are just link text. The HTML has every
# image embedded as a data URI, so it is one file that opens in any browser with
# nothing to keep beside it.
#
# Regenerate with: dart run tool/build_manual_html.dart
$manualFiles = @("docs\MANUAL-pt.html", "docs\MANUAL-en.html")

foreach ($manual in $manualFiles) {
    $src = Join-Path $repo $manual
    if (Test-Path $src) {
        Copy-Item $src $stage
    } else {
        Write-Warning "Manual missing at $src. Run: dart run tool/build_manual_html.dart"
    }
}

# --- zip --------------------------------------------------------------------
Write-Host "Compressing..." -ForegroundColor Cyan
Compress-Archive -Path $stage -DestinationPath $zipPath -CompressionLevel Optimal -Force

$zip = Get-Item $zipPath
Write-Host ""
Write-Host "Packaged." -ForegroundColor Green
Write-Host "  zip    : $($zip.FullName)"
Write-Host "  size   : $([math]::Round($zip.Length / 1MB, 1)) MB"
Write-Host "  sha256 : $((Get-FileHash $zipPath -Algorithm SHA256).Hash)"
Write-Host ""
Write-Host "Employees unzip the folder anywhere and run chronus.exe."
