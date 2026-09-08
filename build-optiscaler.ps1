# DLSS-Unlocked OptiScaler_DLSSNR Build Script
# This script downloads or extracts OptiScaler_DLSSNR releases and copies files to the build structure

param(
    [string]$OptiScalerPath = "",
    [string]$OptiScalerVersion = "v0.2.0-dlssnr",
    [string]$TagName = "",
    [string]$StreamlinePath = "",
    [string]$StreamlineUrl = "https://files.catbox.moe/cw5hfd.zip",
    [string]$PatchedDlssnrUrl = "https://files.catbox.moe/tc3tpi.dll",
    [switch]$DownloadLatest = $false,
    [switch]$CreateStandaloneZip = $false
)

$ErrorActionPreference = "Stop"

Write-Host "DLSS-Unlocked OptiScaler_DLSSNR Build Script" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

$Repo = "Dagherbou/OptiScaler_DLSSNR"
$TempDir = "temp_optiscaler"

# Determine OptiScaler archive path or download
if ($OptiScalerPath -eq "" -or $DownloadLatest) {
    Write-Host "Fetching release information from $Repo..." -ForegroundColor Yellow
    $headers = @{
        'Accept' = 'application/vnd.github.v3+json'
        'User-Agent' = 'DLSS-Unlocked'
    }
    
    try {
        if ($OptiScalerVersion -and $OptiScalerVersion -ne "latest" -and -not $DownloadLatest) {
            $url = "https://api.github.com/repos/$Repo/releases/tags/$OptiScalerVersion"
            $release = Invoke-RestMethod -Uri $url -Headers $headers
        } else {
            $url = "https://api.github.com/repos/$Repo/releases/latest"
            $release = Invoke-RestMethod -Uri $url -Headers $headers
        }
        
        $asset = $release.assets | Where-Object { 
            $_.name -match "OptiScaler.*\.zip$" -or $_.name -match "OptiScaler.*\.7z$" 
        } | Select-Object -First 1

        if (-not $asset) {
            Write-Host "Error: Could not find OptiScaler asset in release" -ForegroundColor Red
            exit 1
        }

        if (!(Test-Path $TempDir)) {
            New-Item -ItemType Directory -Path $TempDir | Out-Null
        }

        $OptiScalerPath = Join-Path $TempDir $asset.name
        Write-Host "Downloading $($asset.name) from $($asset.browser_download_url)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $OptiScalerPath -UseBasicParsing
        Write-Host "Download complete: $OptiScalerPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download from GitHub API: $($_.Exception.Message)" -ForegroundColor Yellow
        if ($OptiScalerPath -eq "" -or !(Test-Path $OptiScalerPath)) {
            Write-Host "Error: Please specify a valid -OptiScalerPath" -ForegroundColor Red
            exit 1
        }
    }
}

# Verify OptiScaler archive exists
if (!(Test-Path $OptiScalerPath)) {
    Write-Host "Error: OptiScaler archive not found at: $OptiScalerPath" -ForegroundColor Red
    exit 1
}

Write-Host "Using OptiScaler archive: $OptiScalerPath" -ForegroundColor Cyan

# Extraction directory
$ExtractDir = Join-Path $TempDir "extracted"
if (Test-Path $ExtractDir) {
    Remove-Item -Path $ExtractDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ExtractDir | Out-Null

Write-Host "Extracting OptiScaler archive..." -ForegroundColor Yellow
if ($OptiScalerPath -match "\.7z$") {
    & 7z x $OptiScalerPath -o"$ExtractDir" -y | Out-Null
} else {
    Expand-Archive -Path $OptiScalerPath -DestinationPath $ExtractDir -Force
}

# Ensure Dll version directory exists
$DllVersionDir = "Dll version"
if (!(Test-Path $DllVersionDir)) {
    New-Item -ItemType Directory -Path $DllVersionDir | Out-Null
}

Write-Host "Copying OptiScaler_DLSSNR files to build structure..." -ForegroundColor Yellow

# Helper to find and copy file recursively
function Copy-ExtractedFile {
    param(
        [string]$Pattern,
        [string]$DestinationName
    )
    $found = Get-ChildItem -Path $ExtractDir -Filter $Pattern -Recurse -File | Select-Object -First 1
    if ($found) {
        $destPath = Join-Path $DllVersionDir $DestinationName
        Copy-Item -Path $found.FullName -Destination $destPath -Force
        Write-Host "  $($found.Name) -> $destPath" -ForegroundColor Gray
    } else {
        Write-Host "  Warning: Not found: $Pattern" -ForegroundColor Yellow
    }
}

# Copy OptiScaler main binaries
Copy-ExtractedFile -Pattern "OptiScaler.dll" -DestinationName "dlss-unlocked-upscaler.dll"
Copy-ExtractedFile -Pattern "OptiScaler.dll" -DestinationName "OptiScaler.dll"
Copy-ExtractedFile -Pattern "nvngx.dll_dlssnr.dll" -DestinationName "nvngx.dll_dlssnr.dll"
Copy-ExtractedFile -Pattern "OptiScaler.ini" -DestinationName "OptiScaler.ini"

# Copy XeSS and XeLL
Copy-ExtractedFile -Pattern "libxess.dll" -DestinationName "libxess.dll"
Copy-ExtractedFile -Pattern "libxess_dx11.dll" -DestinationName "libxess_dx11.dll"
Copy-ExtractedFile -Pattern "libxess_fg.dll" -DestinationName "libxess_fg.dll"
Copy-ExtractedFile -Pattern "libxell.dll" -DestinationName "libxell.dll"

# Copy FidelityFX
Copy-ExtractedFile -Pattern "amd_fidelityfx_dx12.dll" -DestinationName "amd_fidelityfx_dx12.dll"
Copy-ExtractedFile -Pattern "amd_fidelityfx_framegeneration_dx12.dll" -DestinationName "amd_fidelityfx_framegeneration_dx12.dll"
Copy-ExtractedFile -Pattern "amd_fidelityfx_loader_dx12.dll" -DestinationName "amd_fidelityfx_loader_dx12.dll"
Copy-ExtractedFile -Pattern "amd_fidelityfx_upscaler_dx12.dll" -DestinationName "amd_fidelityfx_upscaler_dx12.dll"
Copy-ExtractedFile -Pattern "amd_fidelityfx_vk.dll" -DestinationName "amd_fidelityfx_vk.dll"

# Copy D3D12Core
Copy-ExtractedFile -Pattern "D3D12Core.dll" -DestinationName "D3D12Core.dll"

# Copy Licenses
Copy-ExtractedFile -Pattern "XeSS_LICENSE.txt" -DestinationName "XeSS_LICENSE.txt"
Copy-ExtractedFile -Pattern "FidelityFX_LICENSE.md" -DestinationName "FidelityFX_LICENSE.md"
Copy-ExtractedFile -Pattern "FidelityFX_v2_LICENSE.md" -DestinationName "FidelityFX_v2_LICENSE.md"
Copy-ExtractedFile -Pattern "DirectX_LICENSE.txt" -DestinationName "DirectX_LICENSE.txt"
Copy-ExtractedFile -Pattern "RenoDX_ATTRIBUTION.txt" -DestinationName "RenoDX_ATTRIBUTION.txt"

# Handle NVIDIA Streamline download & extraction
$StreamlineDir = Join-Path $DllVersionDir "streamline"
if (!(Test-Path $StreamlineDir)) {
    New-Item -ItemType Directory -Path $StreamlineDir | Out-Null
}

if ($StreamlinePath -and (Test-Path $StreamlinePath)) {
    Write-Host "Extracting local NVIDIA Streamline package ($StreamlinePath)..." -ForegroundColor Yellow
    Expand-Archive -Path $StreamlinePath -DestinationPath $StreamlineDir -Force
    Write-Host "Streamline files extracted to $StreamlineDir" -ForegroundColor Green
} elseif ($StreamlineUrl) {
    $tempStreamlineZip = Join-Path $TempDir "streamline.zip"
    Write-Host "Downloading NVIDIA Streamline package from $StreamlineUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $StreamlineUrl -OutFile $tempStreamlineZip -UseBasicParsing -TimeoutSec 300
        Expand-Archive -Path $tempStreamlineZip -DestinationPath $StreamlineDir -Force
        Remove-Item -Path $tempStreamlineZip -Force
        Write-Host "NVIDIA Streamline files downloaded and extracted to $StreamlineDir" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download Streamline files: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Exclude sl.nvperf.dll if present in source Streamline archive
Get-ChildItem -Path $StreamlineDir -Filter "sl.nvperf.dll" -Recurse -File | ForEach-Object {
    Write-Host "Excluding $($_.FullName) from Streamline files..." -ForegroundColor Yellow
    Remove-Item $_.FullName -Force
}

# Download patched nvngx_dlssnr.dll to root build directory
if ($PatchedDlssnrUrl) {
    Write-Host "Downloading patched nvngx_dlssnr.dll from $PatchedDlssnrUrl..." -ForegroundColor Yellow
    $targetDlssnrPath = Join-Path $DllVersionDir "nvngx_dlssnr.dll"
    try {
        Invoke-WebRequest -Uri $PatchedDlssnrUrl -OutFile $targetDlssnrPath -UseBasicParsing -TimeoutSec 300
        Write-Host "Patched nvngx_dlssnr.dll downloaded to $targetDlssnrPath" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download patched nvngx_dlssnr.dll: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "OptiScaler_DLSSNR and Streamline files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Build directory contents ($DllVersionDir):" -ForegroundColor Cyan
Get-ChildItem $DllVersionDir | Format-Table Name, Length, LastWriteTime -AutoSize

if ($CreateStandaloneZip) {
    Write-Host "Creating standalone manual package (dxgi.dll zip)..." -ForegroundColor Yellow
    $manualZipDir = Join-Path $TempDir "manual_package"
    if (Test-Path $manualZipDir) { Remove-Item -Path $manualZipDir -Recurse -Force }
    New-Item -ItemType Directory -Path $manualZipDir | Out-Null

    $optiScalerSubDir = Join-Path $manualZipDir "OptiScaler"
    New-Item -ItemType Directory -Path $optiScalerSubDir | Out-Null

    # 1. Root files: dxgi.dll, OptiScaler.ini, nvngx.dll_dlssnr.dll
    $sourceDll = if (Test-Path "$DllVersionDir\OptiScaler.dll") {
        "$DllVersionDir\OptiScaler.dll"
    } elseif (Test-Path "$DllVersionDir\dlss-unlocked-upscaler.dll") {
        "$DllVersionDir\dlss-unlocked-upscaler.dll"
    } elseif (Test-Path "$DllVersionDir\version.dll") {
        "$DllVersionDir\version.dll"
    } else {
        "$DllVersionDir\dlss-enabler.asi"
    }
    Copy-Item -Path $sourceDll -Destination "$manualZipDir\dxgi.dll" -Force

    if (Test-Path "$DllVersionDir\OptiScaler.ini") {
        $optiIniContent = Get-Content "$DllVersionDir\OptiScaler.ini" -Raw
        # 1. Update comments for nvngxfg to reflect dlssg & fsrfg compatibility
        $oldComment = '; nvngxfg  - Limited to FSR 3 FG (MFG with DLSS Enabler''s dll). Requires DLSSG in the game. Supports Hudless out of the box. Uses Streamline swapchain for pacing.'
        $newComment = '; nvngxfg  - Uses MFG with DLSS Enabler''s dll. Can be paired with ''dlssg'' (with Streamline) or ''fsrfg'' FG Output. Requires DLSSG in the game. Supports Hudless out of the box. Uses Streamline swapchain for pacing.'
        if ($optiIniContent.Contains($oldComment)) {
            $optiIniContent = $optiIniContent.Replace($oldComment, $newComment)
        }
        # 2. Helper to safely update a key within a specific INI section
        function Set-IniKey {
            param($content, $section, $key, $value)
            $escapedSec = [regex]::Escape($section)
            $escapedKey = [regex]::Escape($key)
            if ($content -match "(?m)^\[$escapedSec\]") {
                $pattern = "(?ms)(^\[$escapedSec\].*?)(^$escapedKey\s*=.*?$)(.*?)(?=^\[|\z)"
                if ($content -match $pattern) {
                    return [regex]::Replace($content, $pattern, "${1}$key=$value${3}")
                } else {
                    return [regex]::Replace($content, "(?m)^\[$escapedSec\]\r?\n", "`$0$key=$value`r`n")
                }
            } else {
                return "$content`r`n[$section]`r`n$key=$value`r`n"
            }
        }

        # Configure [DlssNr] and [FrameGen]
        $optiIniContent = Set-IniKey -content $optiIniContent -section "DlssNr" -key "Enabled" -value "auto"
        $optiIniContent = Set-IniKey -content $optiIniContent -section "FrameGen" -key "Enabled" -value "true"
        $optiIniContent = Set-IniKey -content $optiIniContent -section "FrameGen" -key "FGInput" -value "nvngxfg"
        $optiIniContent = Set-IniKey -content $optiIniContent -section "FrameGen" -key "FGOutput" -value "dlssg"
        $optiIniContent = Set-IniKey -content $optiIniContent -section "FrameGen" -key "FGNvngxReplacement" -value "Arturs"

        Set-Content -Path "$manualZipDir\OptiScaler.ini" -Value $optiIniContent -Encoding UTF8
        Set-Content -Path "$DllVersionDir\OptiScaler.ini" -Value $optiIniContent -Encoding UTF8
        Write-Host "  Configured OptiScaler.ini (DlssNr.Enabled=auto, FrameGen.Enabled=true, FGInput=nvngxfg, FGOutput=dlssg, FGNvngxReplacement=Arturs)" -ForegroundColor Gray
    }
    if (Test-Path "$DllVersionDir\nvngx.dll_dlssnr.dll") {
        Copy-Item -Path "$DllVersionDir\nvngx.dll_dlssnr.dll" -Destination $manualZipDir -Force
    }
    if (Test-Path "$DllVersionDir\nvngx_dlssnr.dll") {
        Copy-Item -Path "$DllVersionDir\nvngx_dlssnr.dll" -Destination $manualZipDir -Force
    }

    # 2. OptiScaler subfolder files: DLSS Enabler headless, DLSSG mod, upscalers & companion DLLs
    if (Test-Path "$DllVersionDir\dlss-enabler.asi") {
        Copy-Item -Path "$DllVersionDir\dlss-enabler.asi" -Destination "$optiScalerSubDir\dlss-enabler-headless.dll" -Force
    }
    if (Test-Path "$DllVersionDir\nvngx.ini") {
        Copy-Item -Path "$DllVersionDir\nvngx.ini" -Destination $optiScalerSubDir -Force
    }

    # Copy DLSSG mod components (excluding _nvngx.dll to prevent Proton/Linux loader deadlocks)
    if (Test-Path "DLLSG mod\dlssg_to_fsr3_amd_is_better.dll") {
        Copy-Item -Path "DLLSG mod\dlssg_to_fsr3_amd_is_better.dll" -Destination $optiScalerSubDir -Force
    }
    if (Test-Path "DLLSG mod\DisableNvidiaSignatureChecks.reg") {
        Copy-Item -Path "DLLSG mod\DisableNvidiaSignatureChecks.reg" -Destination $optiScalerSubDir -Force
    }
    if (Test-Path "DLLSG mod\RestoreNvidiaSignatureChecks.reg") {
        Copy-Item -Path "DLLSG mod\RestoreNvidiaSignatureChecks.reg" -Destination $optiScalerSubDir -Force
    }

    # Copy upscaler and FidelityFX / XeSS companion DLLs
    $companionDlls = @(
        "amd_fidelityfx_dx12.dll",
        "amd_fidelityfx_framegeneration_dx12.dll",
        "amd_fidelityfx_loader_dx12.dll",
        "amd_fidelityfx_upscaler_dx12.dll",
        "amd_fidelityfx_vk.dll",
        "libxess.dll",
        "libxess_dx11.dll",
        "libxess_fg.dll",
        "libxell.dll",
        "D3D12Core.dll"
    )
    foreach ($cDll in $companionDlls) {
        if (Test-Path "$DllVersionDir\$cDll") {
            Copy-Item -Path "$DllVersionDir\$cDll" -Destination $optiScalerSubDir -Force
        }
    }

    # Copy NVIDIA Streamline files
    $streamlineSubDir = Join-Path $optiScalerSubDir "streamline"
    New-Item -ItemType Directory -Path $streamlineSubDir | Out-Null
    if (Test-Path "$DllVersionDir\streamline") {
        Get-ChildItem -Path "$DllVersionDir\streamline" | Where-Object { $_.Name -ne "sl.nvperf.dll" } | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $streamlineSubDir -Recurse -Force
        }
        Write-Host "  NVIDIA Streamline -> $streamlineSubDir" -ForegroundColor Gray
    }

    if (!(Test-Path "Output")) { New-Item -ItemType Directory -Path "Output" | Out-Null }
    $effectiveTag = if ($TagName -and $TagName.Trim() -ne "") { $TagName.Trim() } elseif ($OptiScalerVersion) { $OptiScalerVersion } else { "latest" }
    $zipOutputPath = "Output\dlss-unlocked-standalone-$effectiveTag.zip"
    $workspacePath = (Get-Location).Path
    $fullZipOutputPath = Join-Path $workspacePath $zipOutputPath
    if (Test-Path $fullZipOutputPath) { Remove-Item $fullZipOutputPath -Force }
    
    $7zCmd = Get-Command 7z -ErrorAction SilentlyContinue
    if ($7zCmd) {
        Push-Location $manualZipDir
        try {
            & 7z a -tzip "$fullZipOutputPath" *
        } finally {
            Pop-Location
        }
    } else {
        Compress-Archive -Path "$manualZipDir\*" -DestinationPath $fullZipOutputPath -Force
    }
    Write-Host "Standalone zip created at: $zipOutputPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "You can now compile the installer with Inno Setup using 'DLSS unlocked.iss'." -ForegroundColor Green
