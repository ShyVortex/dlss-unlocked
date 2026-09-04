# DLSS-Unlocked OptiScaler_DLSSNR Build Script
# This script downloads or extracts OptiScaler_DLSSNR releases and copies files to the build structure

param(
    [string]$OptiScalerPath = "",
    [string]$OptiScalerVersion = "v0.2.0-dlssnr",
    [switch]$DownloadLatest = $false
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

Write-Host ""
Write-Host "OptiScaler_DLSSNR files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Build directory contents ($DllVersionDir):" -ForegroundColor Cyan
Get-ChildItem $DllVersionDir | Format-Table Name, Length, LastWriteTime -AutoSize

Write-Host ""
Write-Host "You can now compile the installer with Inno Setup using 'DLSS unlocked.iss'." -ForegroundColor Green
