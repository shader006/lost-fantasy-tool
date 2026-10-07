# Lost Fantasy installer / repair tool.
# Downloads the latest release from GitHub, verifies SHA256 of every file, installs Chromium runtime if missing.
# Usage (PowerShell):
#   irm https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.ps1 | iex
# Custom folder:
#   $env:LF_DIR = "C:\LostFantasy"; irm https://raw.githubusercontent.com/shader006/lost-fantasy-tool/main/install.ps1 | iex
# Re-running is safe: files already matching the manifest are skipped, user data is never touched.
# (ASCII only on purpose: Windows PowerShell 5.1 mis-decodes UTF-8 scripts fetched with irm.)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = 'shader006/lost-fantasy-tool'
$Base = "https://github.com/$Repo/releases"
$BrowserTag = 'runtime-browser'
$Dir = if ($env:LF_DIR) { $env:LF_DIR } else { Join-Path $env:USERPROFILE 'LostFantasy' }

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg) { Write-Host "    OK  $msg" -ForegroundColor Green }

$wc = New-Object Net.WebClient
$wc.Headers.Add('User-Agent', 'lost-fantasy-installer')
$wc.Encoding = [Text.Encoding]::UTF8

function Get-Sha256($path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() }

function Save-Verified($url, $dest, $sha) {
    $part = "$dest.part"
    $parent = Split-Path -Parent $dest
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $wc.DownloadFile($url, $part)
            $got = Get-Sha256 $part
            if ($got -ne $sha.ToLower()) { throw "SHA256 mismatch (expected $sha, got $got)" }
            Move-Item -LiteralPath $part -Destination $dest -Force
            return
        } catch {
            Remove-Item -LiteralPath $part -Force -ErrorAction SilentlyContinue
            if ($attempt -eq 3) { throw "Download failed: $url :: $($_.Exception.Message)" }
            Write-Host "    retry $attempt/3 ($($_.Exception.Message))" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

try {
    Write-Step "Install folder: $Dir"
    New-Item -ItemType Directory -Force -Path $Dir | Out-Null

    $running = Get-Process -Name 'lost_fantasy_cli', 'engine' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -and $_.Path.StartsWith($Dir, [StringComparison]::OrdinalIgnoreCase) }
    if ($running) { throw "Close Lost Fantasy (lost_fantasy_cli.exe / engine.exe) in $Dir before installing." }

    Write-Step 'Reading latest release manifest'
    $manifest = $wc.DownloadString("$Base/latest/download/manifest.json") | ConvertFrom-Json
    if (-not $manifest.version -or -not $manifest.files) { throw 'Invalid manifest.json' }
    Write-Ok "version $($manifest.version) ($($manifest.files.Count) files)"

    foreach ($f in $manifest.files) {
        if ($f.path -match '(^|[\\/])\.\.([\\/]|$)' -or $f.path -match '^[\\/]' -or $f.path -match ':') {
            throw "Unsafe path in manifest: $($f.path)"
        }
        $dest = Join-Path $Dir ($f.path -replace '/', '\')
        if ((Test-Path -LiteralPath $dest) -and ((Get-Sha256 $dest) -eq $f.sha256.ToLower())) {
            Write-Ok "$($f.path) (up to date)"
            continue
        }
        $mb = [math]::Round($f.size / 1MB, 1)
        Write-Host "    ... $($f.path) ($mb MB)"
        Save-Verified "$Base/download/v$($manifest.version)/$($f.asset)" $dest $f.sha256
        Write-Ok $f.path
    }

    $browserDir = Join-Path $Dir 'runtime\browser'
    $hasChromium = (Test-Path $browserDir) -and (Get-ChildItem -LiteralPath $browserDir -Directory -Filter 'chromium-*' -ErrorAction SilentlyContinue)
    if ($hasChromium) {
        Write-Ok 'Chromium runtime already installed'
    } else {
        Write-Step 'Downloading Chromium runtime (one time, ~370 MB)'
        $shaLine = $wc.DownloadString("$Base/download/$BrowserTag/runtime-browser.zip.sha256").Trim()
        $zipSha = ($shaLine -split '\s+')[0]
        $zip = Join-Path $Dir 'runtime-browser.zip'
        Save-Verified "$Base/download/$BrowserTag/runtime-browser.zip" $zip $zipSha
        Write-Step 'Extracting Chromium runtime'
        New-Item -ItemType Directory -Force -Path $browserDir | Out-Null
        Expand-Archive -LiteralPath $zip -DestinationPath $browserDir -Force
        Remove-Item -LiteralPath $zip -Force
        Write-Ok 'Chromium runtime installed'
    }

    $settings = Join-Path $Dir 'settings.json'
    if (-not (Test-Path -LiteralPath $settings)) {
        Set-Content -LiteralPath $settings -Encoding ASCII -Value "{`n  `"headlessMode`": false,`n  `"windowWidth`": 160,`n  `"windowHeight`": 35`n}"
        Write-Ok 'settings.json created'
    }
    $accounts = Join-Path $Dir 'accounts.json'
    if (-not (Test-Path -LiteralPath $accounts)) {
        Set-Content -LiteralPath $accounts -Encoding ASCII -Value '[]'
        Write-Ok 'accounts.json created'
    }

    Write-Host ''
    Write-Host "Installed Lost Fantasy v$($manifest.version) to $Dir" -ForegroundColor Green
    Write-Host "Run: $Dir\lost_fantasy_cli.exe" -ForegroundColor Green
    $answer = Read-Host 'Launch now? (Y/n)'
    if ($answer -notmatch '^[nN]') {
        Start-Process -FilePath (Join-Path $Dir 'lost_fantasy_cli.exe') -WorkingDirectory $Dir
    }
} catch {
    Write-Host ''
    Write-Host "INSTALL FAILED: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $wc.Dispose()
}
