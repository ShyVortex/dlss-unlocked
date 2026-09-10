# DLSS-Unlocked OptiScaler-DLSSNR-PreSR-Multipass Build Script
# This script downloads or extracts OptiScaler-DLSSNR-PreSR-Multipass releases and copies files to the build structure

param(
    [string]$OptiScalerPath = "",
    [string]$OptiScalerVersion = "v0.7.6",
    [string]$TagName = "",
    [string]$StreamlinePath = "",
    [string]$StreamlineUrl = "https://github.com/NVIDIA-RTX/Streamline/releases/download/v2.14.1/streamline-sdk-v2.14.1.zip",
    [string]$PatchedDlssnrUrl = "https://files.catbox.moe/tc3tpi.dll",
    [string]$OriginalDlssnrUrl = "https://files.catbox.moe/05wm7b.dll",
    [string]$StreamlineDlssNrUrl = "https://files.catbox.moe/sckb7i.dll",
    [string]$DlssgSm86VersionDllUrl = "https://raw.githubusercontent.com/sdli1995/dlssg_for_sm86/main/version.dll",
    [string]$DlssgSm86IniUrl = "https://raw.githubusercontent.com/sdli1995/dlssg_for_sm86/main/dlssg_sm86.ini",
    [string]$DlssgSm86NoticesUrl = "https://raw.githubusercontent.com/sdli1995/dlssg_for_sm86/main/THIRD_PARTY_NOTICES.txt",
    [switch]$DownloadLatest = $false,
    [switch]$CreateStandaloneZip = $false
)

$ErrorActionPreference = "Stop"

Write-Host "DLSS-Unlocked OptiScaler-DLSSNR-PreSR-Multipass Build Script" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$Repo = "wilsjo2/OptiScaler-DLSSNR-PreSR-Multipass"
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

Write-Host "Copying OptiScaler-DLSSNR-PreSR-Multipass files to build structure..." -ForegroundColor Yellow

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

# Copy D3D12Core (ensure it is placed directly in root, not duplicated in D3D12_OptiScaler)
Copy-ExtractedFile -Pattern "D3D12Core.dll" -DestinationName "D3D12Core.dll"
if (Test-Path "$DllVersionDir\D3D12_OptiScaler") {
    Remove-Item -Path "$DllVersionDir\D3D12_OptiScaler" -Recurse -Force
}

# Copy Licenses
Copy-ExtractedFile -Pattern "XeSS_LICENSE.txt" -DestinationName "XeSS_LICENSE.txt"
Copy-ExtractedFile -Pattern "FidelityFX_LICENSE.md" -DestinationName "FidelityFX_LICENSE.md"
Copy-ExtractedFile -Pattern "FidelityFX_v2_LICENSE.md" -DestinationName "FidelityFX_v2_LICENSE.md"
Copy-ExtractedFile -Pattern "DirectX_LICENSE.txt" -DestinationName "DirectX_LICENSE.txt"
Copy-ExtractedFile -Pattern "RenoDX_ATTRIBUTION.txt" -DestinationName "RenoDX_ATTRIBUTION.txt"

# Copy nvfp4 folder if present
$foundNvfp4 = Get-ChildItem -Path $ExtractDir -Filter "nvfp4" -Recurse -Directory | Select-Object -First 1
if ($foundNvfp4) {
    $destNvfp4 = Join-Path $DllVersionDir "nvfp4"
    if (Test-Path $destNvfp4) { Remove-Item -Path $destNvfp4 -Recurse -Force }
    Copy-Item -Path $foundNvfp4.FullName -Destination $DllVersionDir -Recurse -Force
    Write-Host "  nvfp4 -> $destNvfp4" -ForegroundColor Gray
}

# Handle NVIDIA Streamline download & extraction
$StreamlineDir = Join-Path $DllVersionDir "streamline"
if (!(Test-Path $StreamlineDir)) {
    New-Item -ItemType Directory -Path $StreamlineDir | Out-Null
}

$tempStreamlineExtractDir = Join-Path $TempDir "streamline_extracted"
if (Test-Path $tempStreamlineExtractDir) { Remove-Item -Path $tempStreamlineExtractDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempStreamlineExtractDir | Out-Null

if ($StreamlinePath -and (Test-Path $StreamlinePath)) {
    Write-Host "Extracting local NVIDIA Streamline package ($StreamlinePath)..." -ForegroundColor Yellow
    Expand-Archive -Path $StreamlinePath -DestinationPath $tempStreamlineExtractDir -Force
} elseif ($StreamlineUrl) {
    $tempStreamlineZip = Join-Path $TempDir "streamline.zip"
    Write-Host "Downloading NVIDIA Streamline package from $StreamlineUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $StreamlineUrl -OutFile $tempStreamlineZip -UseBasicParsing -TimeoutSec 300
        Expand-Archive -Path $tempStreamlineZip -DestinationPath $tempStreamlineExtractDir -Force
        Remove-Item -Path $tempStreamlineZip -Force
        Write-Host "NVIDIA Streamline archive downloaded and extracted." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download Streamline files: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (Test-Path $tempStreamlineExtractDir) {
    # Locate bin/x64 directory in extracted archive
    $binX64Dir = Join-Path $tempStreamlineExtractDir "bin\x64"
    if (-not (Test-Path $binX64Dir)) {
        $foundX64 = Get-ChildItem -Path $tempStreamlineExtractDir -Recurse -Directory -Filter "x64" | Where-Object { $_.FullName -like "*bin*x64*" } | Select-Object -First 1
        if ($foundX64) { $binX64Dir = $foundX64.FullName } else { $binX64Dir = $tempStreamlineExtractDir }
    }

    $excludedStreamlineFiles = @(
        "sl.nvperf.dll",
        "NvLowLatencyVk.dll",
        "nvngx_deepdvc.dll",
        "sl.deepdvc.dll",
        "sl.directsr.dll",
        "sl.nis.dll",
        "nis.license.txt"
    )

    # Copy files directly from bin/x64 into $StreamlineDir (excluding development folder and unwanted DLLs)
    Get-ChildItem -Path $binX64Dir -File | Where-Object {
        $excludedStreamlineFiles -notcontains $_.Name
    } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $StreamlineDir -Force
        Write-Host "  Streamline file: $($_.Name)" -ForegroundColor Gray
    }

    Remove-Item -Path $tempStreamlineExtractDir -Recurse -Force
}

# Download missing original nvngx_dlssnr.dll for OptiScaler/streamline
if ($OriginalDlssnrUrl) {
    $targetOrigDlssnr = Join-Path $StreamlineDir "nvngx_dlssnr.dll"
    if (-not (Test-Path $targetOrigDlssnr)) {
        Write-Host "Downloading original nvngx_dlssnr.dll for Streamline from $OriginalDlssnrUrl..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $OriginalDlssnrUrl -OutFile $targetOrigDlssnr -UseBasicParsing -TimeoutSec 300
            Write-Host "Original nvngx_dlssnr.dll downloaded to $targetOrigDlssnr" -ForegroundColor Green
        } catch {
            Write-Host "Warning: Could not download original nvngx_dlssnr.dll: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Original nvngx_dlssnr.dll already present in Streamline folder." -ForegroundColor Gray
    }
}

# Download missing sl.dlss_nr.dll for OptiScaler/streamline
if ($StreamlineDlssNrUrl) {
    $targetSlDlssNr = Join-Path $StreamlineDir "sl.dlss_nr.dll"
    if (-not (Test-Path $targetSlDlssNr)) {
        Write-Host "Downloading sl.dlss_nr.dll for Streamline from $StreamlineDlssNrUrl..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $StreamlineDlssNrUrl -OutFile $targetSlDlssNr -UseBasicParsing -TimeoutSec 300
            Write-Host "sl.dlss_nr.dll downloaded to $targetSlDlssNr" -ForegroundColor Green
        } catch {
            Write-Host "Warning: Could not download sl.dlss_nr.dll: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "sl.dlss_nr.dll already present in Streamline folder." -ForegroundColor Gray
    }
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

# Download and bundle dlssg_for_sm86 (Turing/Ampere MFG unlocker)
$DlssgSm86Dir = Join-Path $DllVersionDir "dlssg_sm86"
if (!(Test-Path $DlssgSm86Dir)) {
    New-Item -ItemType Directory -Path $DlssgSm86Dir | Out-Null
}

$targetDlssgDll = Join-Path $DlssgSm86Dir "dlssg_sm86.dll"
if (-not (Test-Path $targetDlssgDll) -and $DlssgSm86VersionDllUrl) {
    Write-Host "Downloading dlssg_sm86.dll from $DlssgSm86VersionDllUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $DlssgSm86VersionDllUrl -OutFile $targetDlssgDll -UseBasicParsing -TimeoutSec 300
        Write-Host "dlssg_sm86.dll downloaded to $targetDlssgDll" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download dlssg_sm86.dll: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "dlssg_sm86.dll already present in dlssg_sm86 folder." -ForegroundColor Gray
}

$targetDlssgIni = Join-Path $DlssgSm86Dir "dlssg_sm86.ini"
if (-not (Test-Path $targetDlssgIni) -and $DlssgSm86IniUrl) {
    Write-Host "Downloading dlssg_sm86.ini from $DlssgSm86IniUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $DlssgSm86IniUrl -OutFile $targetDlssgIni -UseBasicParsing -TimeoutSec 300
        Write-Host "dlssg_sm86.ini downloaded to $targetDlssgIni" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download dlssg_sm86.ini: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "dlssg_sm86.ini already present in dlssg_sm86 folder." -ForegroundColor Gray
}

$targetDlssgNotices = Join-Path $DlssgSm86Dir "THIRD_PARTY_NOTICES.txt"
if (-not (Test-Path $targetDlssgNotices) -and $DlssgSm86NoticesUrl) {
    Write-Host "Downloading THIRD_PARTY_NOTICES.txt from $DlssgSm86NoticesUrl..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $DlssgSm86NoticesUrl -OutFile $targetDlssgNotices -UseBasicParsing -TimeoutSec 300
        Write-Host "dlssg_sm86 THIRD_PARTY_NOTICES.txt downloaded to $targetDlssgNotices" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download dlssg_sm86 THIRD_PARTY_NOTICES.txt: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "dlssg_sm86 THIRD_PARTY_NOTICES.txt already present in dlssg_sm86 folder." -ForegroundColor Gray
}

Write-Host ""
Write-Host "OptiScaler-DLSSNR-PreSR-Multipass and Streamline files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Build directory contents ($DllVersionDir):" -ForegroundColor Cyan
Get-ChildItem $DllVersionDir | Format-Table Name, Length, LastWriteTime -AutoSize

# Configure OptiScaler.ini (FrameGen)
if (Test-Path "$DllVersionDir\OptiScaler.ini") {
    $optiIniContent = Get-Content "$DllVersionDir\OptiScaler.ini" -Raw
    # Helper to safely update a key within a specific INI section
    function Set-IniKey {
        param(
            [string]$Content,
            [string]$Section,
            [string]$Key,
            [string]$Value
        )
        $lines = $Content -split "\r?\n"
        $newLines = [System.Collections.Generic.List[string]]::new()
        $currentSection = ""
        $keyFound = $false
        $sectionFound = $false

        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -match '^\[([^\]]+)\]$') {
                if ($currentSection -eq $Section -and -not $keyFound) {
                    $newLines.Add("$Key=$Value")
                    $keyFound = $true
                }
                $currentSection = $matches[1].Trim()
                if ($currentSection -eq $Section) {
                    $sectionFound = $true
                }
                $newLines.Add($line)
                continue
            }

            if ($currentSection -eq $Section -and $trimmed -match "^$([regex]::Escape($Key))\s*=") {
                $newLines.Add("$Key=$Value")
                $keyFound = $true
                continue
            }

            $newLines.Add($line)
        }

        if ($currentSection -eq $Section -and -not $keyFound) {
            $newLines.Add("$Key=$Value")
            $keyFound = $true
        }

        if (-not $sectionFound) {
            if ($newLines.Count -gt 0 -and $newLines[$newLines.Count - 1] -ne "") {
                $newLines.Add("")
            }
            $newLines.Add("[$Section]")
            $newLines.Add("$Key=$Value")
        }

        return ($newLines -join "`r`n")
    }

    # Configure [FrameGen]
    $optiIniContent = Set-IniKey -Content $optiIniContent -Section "FrameGen" -Key "External" -Value "true"
    $optiIniContent = Set-IniKey -Content $optiIniContent -Section "FrameGen" -Key "AmpereMfgUnlock" -Value "true"

    Set-Content -Path "$DllVersionDir\OptiScaler.ini" -Value $optiIniContent -Encoding UTF8
    Write-Host "Configured OptiScaler.ini (FrameGen.External=true, FrameGen.AmpereMfgUnlock=true)" -ForegroundColor Gray
}

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
        Copy-Item -Path "$DllVersionDir\OptiScaler.ini" -Destination "$manualZipDir\OptiScaler.ini" -Force
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

    # Ensure D3D12Core.dll is not duplicated in D3D12_OptiScaler subfolder
    if (Test-Path "$optiScalerSubDir\D3D12_OptiScaler") {
        Remove-Item -Path "$optiScalerSubDir\D3D12_OptiScaler" -Recurse -Force
    }

    # Copy nvfp4 folder if present
    if (Test-Path "$DllVersionDir\nvfp4") {
        $destNvfp4 = Join-Path $optiScalerSubDir "nvfp4"
        if (Test-Path $destNvfp4) { Remove-Item -Path $destNvfp4 -Recurse -Force }
        Copy-Item -Path "$DllVersionDir\nvfp4" -Destination $optiScalerSubDir -Recurse -Force
        Write-Host "  nvfp4 -> $destNvfp4" -ForegroundColor Gray
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

    # Copy dlssg_sm86 folder if present
    if (Test-Path "$DllVersionDir\dlssg_sm86") {
        $destDlssgSm86 = Join-Path $optiScalerSubDir "dlssg_sm86"
        if (Test-Path $destDlssgSm86) { Remove-Item -Path $destDlssgSm86 -Recurse -Force }
        Copy-Item -Path "$DllVersionDir\dlssg_sm86" -Destination $optiScalerSubDir -Recurse -Force
        Write-Host "  dlssg_sm86 -> $destDlssgSm86" -ForegroundColor Gray
    }

    # 3. Licenses folder
    $licensesSubDir = Join-Path $manualZipDir "Licenses"
    New-Item -ItemType Directory -Path $licensesSubDir | Out-Null
    if (Test-Path "Licenses") {
        Copy-Item -Path "Licenses\*" -Destination $licensesSubDir -Recurse -Force
    }
    $optiLicenses = @(
        "DirectX_LICENSE.txt",
        "RenoDX_ATTRIBUTION.txt",
        "FidelityFX_v2_LICENSE.md",
        "FidelityFX_LICENSE.md",
        "XeSS_LICENSE.txt"
    )
    foreach ($lic in $optiLicenses) {
        if (Test-Path "$DllVersionDir\$lic") {
            Copy-Item -Path "$DllVersionDir\$lic" -Destination $licensesSubDir -Force
        }
    }
    if (Test-Path "$DllVersionDir\dlssg_sm86\THIRD_PARTY_NOTICES.txt") {
        Copy-Item -Path "$DllVersionDir\dlssg_sm86\THIRD_PARTY_NOTICES.txt" -Destination "$licensesSubDir\dlssg_sm86_THIRD_PARTY_NOTICES.txt" -Force
    }
    Write-Host "  Licenses -> $licensesSubDir" -ForegroundColor Gray

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
