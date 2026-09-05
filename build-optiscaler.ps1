# DLSS-Unlocked OptiScaler_DLSSNR Build Script
# This script downloads or extracts OptiScaler_DLSSNR releases and copies files to the build structure

param(
    [string]$OptiScalerPath = "",
    [string]$OptiScalerVersion = "v0.2.0-dlssnr",
    [switch]$DownloadLatest = $false,
    [switch]$CreateStandaloneZip = $false,
    [switch]$BuildDLSSEnabler = $false
)

$ErrorActionPreference = "Stop"

Write-Host "DLSS-Unlocked OptiScaler_DLSSNR Build Script" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

if ($BuildDLSSEnabler) {
    Write-Host "Building DLSS Enabler from source (artur-graniszewski/dlss-enabler-main)..." -ForegroundColor Yellow
    $deBuildDir = "temp_dlss_enabler"
    if (Test-Path $deBuildDir) { Remove-Item -Path $deBuildDir -Recurse -Force }
    
    Write-Host "Cloning dlss-enabler-main..." -ForegroundColor Gray
    git clone --recurse-submodules https://github.com/artur-graniszewski/dlss-enabler-main.git $deBuildDir
    
    $spdlogPath = Join-Path $deBuildDir "External\spdlog"
    if (-not (Test-Path (Join-Path $spdlogPath "include"))) {
        Write-Host "Fetching spdlog dependency..." -ForegroundColor Gray
        if (Test-Path $spdlogPath) { Remove-Item -Path $spdlogPath -Recurse -Force }
        git clone --depth 1 https://github.com/gabime/spdlog.git $spdlogPath
    }
    
    # Detect installed Windows SDK
    $sdkVer = (Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\Include" -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -and $_.Name -match "^10\." } | Sort-Object Name -Descending | Select-Object -First 1).Name
    if (-not $sdkVer) { $sdkVer = "10.0" }
    
    # Patch DLSSEnabler.vcxproj for Vulkan SDK path, /utf-8 compiler option, SPDLOG_WCHAR_FILENAMES & missing OptiScaler.lib
    $projFile = Join-Path $deBuildDir "DLSSEnabler.vcxproj"
    if (Test-Path $projFile) {
        $projContent = Get-Content $projFile -Raw
        $projContent = $projContent -replace 'C:\\Games\\VulkanSDK\\1\.3\.268\.0\\Include', '$(VULKAN_SDK)\Include;$(IncludePath)'
        $projContent = $projContent -replace '<PreprocessorDefinitions>', '<PreprocessorDefinitions>SPDLOG_WCHAR_FILENAMES;'
        $projContent = $projContent -replace '<LanguageStandard>stdcpp20</LanguageStandard>', "<LanguageStandard>stdcpp20</LanguageStandard>`r`n      <AdditionalOptions>/utf-8 /D SPDLOG_WCHAR_FILENAMES %(AdditionalOptions)</AdditionalOptions>"
        $projContent = $projContent -replace 'Libs[\\/]OptiScaler\.lib;?', ''
        $projContent = $projContent -replace 'OptiScaler\.lib;?', ''
        Set-Content -Path $projFile -Value $projContent -Encoding UTF8
    }

    # Patch duplicate function bodies in StreamlineProxy.cpp
    $slFile = Join-Path $deBuildDir "Utils\StreamlineProxy.cpp"
    if (Test-Path $slFile) {
        $slContent = Get-Content $slFile -Raw
        $duplicatePattern = '(?s)(int detoured_slDLSSGGetState\(void \*viewport, DLSSGState& state, const DLSSGOptions\* options\)\s*\{.*?\})\s*void\* GetCurrentViewPort\(\)\s*\{.*?LOG_DEBUG\(L"\[STREAMLINE\] RestoreGameDLSSGOptions: returned " \+ std::to_wstring\(result\)\);\s*\}'
        if ($slContent -match $duplicatePattern) {
            $slContent = $slContent -replace $duplicatePattern, '$1'
            Set-Content -Path $slFile -Value $slContent -Encoding UTF8
        }
    }

    # Patch HLSL vector comparison for modern DXC (DirectX Shader Compiler)
    Get-ChildItem -Path $deBuildDir -Filter "*.hlsl" -Recurse | ForEach-Object {
        $hlslContent = Get-Content $_.FullName -Raw
        $patchedHlsl = $hlslContent -replace 'all\(\s*([a-zA-Z0-9_]+)\s*>=\s*0\.0\s*&&\s*\1\s*<=\s*1\.0\s*\)', 'all($1 >= 0.0) && all($1 <= 1.0)'
        if ($hlslContent -ne $patchedHlsl) {
            Set-Content -Path $_.FullName -Value $patchedHlsl -Encoding UTF8
            Write-Host "Patched HLSL shader for DXC: $($_.Name)" -ForegroundColor Gray
        }
    }
    
    Push-Location $deBuildDir
    try {
        msbuild DLSSEnabler.sln /p:Configuration=Release /p:Platform=x64 /p:WindowsTargetPlatformVersion=$sdkVer /p:PostBuildEventUseInBuild=false /m
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "MSBuild failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Warning "Failed to build DLSS Enabler locally: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
    
    $builtDll = Get-ChildItem -Path $deBuildDir -Filter "DLSSEnabler.dll" -Recurse -File | Where-Object { $_.FullName -match "x64[\\/]Release" } | Select-Object -First 1
    if (-not $builtDll) {
        $builtDll = Get-ChildItem -Path $deBuildDir -Filter "DLSSEnabler.dll" -Recurse -File | Select-Object -First 1
    }
    
    if ($builtDll) {
        if (-not (Test-Path "Dll version")) { New-Item -ItemType Directory -Path "Dll version" | Out-Null }
        $targetAsi = "Dll version\dlss-enabler.asi"
        if (Test-Path $targetAsi) {
            $oldHash = (Get-FileHash -Path $targetAsi -Algorithm SHA256).Hash
            $newHash = (Get-FileHash -Path $builtDll.FullName -Algorithm SHA256).Hash
            if ($oldHash -ne $newHash) {
                Write-Host "DLSS Enabler updated! ($newHash)" -ForegroundColor Green
                Copy-Item -Path $builtDll.FullName -Destination $targetAsi -Force
            } else {
                Write-Host "DLSS Enabler is already up to date." -ForegroundColor Gray
            }
        } else {
            Copy-Item -Path $builtDll.FullName -Destination $targetAsi -Force
            Write-Host "Copied compiled DLSS Enabler to $targetAsi" -ForegroundColor Green
        }
    }
}

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
        if ($optiIniContent -match '(?m)^FGInput\s*=') {
            $optiIniContent = $optiIniContent -replace '(?m)^FGInput\s*=.*', 'FGInput=nvngxfg'
        } else {
            $optiIniContent = $optiIniContent -replace '\[FrameGen\]', "[FrameGen]`r`nFGInput=nvngxfg"
        }
        if ($optiIniContent -match '(?m)^FGOutput\s*=') {
            $optiIniContent = $optiIniContent -replace '(?m)^FGOutput\s*=.*', 'FGOutput=fsrfg'
        } else {
            $optiIniContent = $optiIniContent -replace '\[FrameGen\]', "[FrameGen]`r`nFGOutput=fsrfg"
        }
        if ($optiIniContent -match '(?m)^FGNvngxReplacement\s*=') {
            $optiIniContent = $optiIniContent -replace '(?m)^FGNvngxReplacement\s*=.*', 'FGNvngxReplacement=Arturs'
        } else {
            $optiIniContent = $optiIniContent -replace '\[FrameGen\]', "[FrameGen]`r`nFGNvngxReplacement=Arturs"
        }
        Set-Content -Path "$manualZipDir\OptiScaler.ini" -Value $optiIniContent -Encoding UTF8
        Set-Content -Path "$DllVersionDir\OptiScaler.ini" -Value $optiIniContent -Encoding UTF8
        Write-Host "  Configured OptiScaler.ini (FGInput=nvngxfg, FGOutput=fsrfg, FGNvngxReplacement=Arturs)" -ForegroundColor Gray
    }
    if (Test-Path "$DllVersionDir\nvngx.dll_dlssnr.dll") {
        Copy-Item -Path "$DllVersionDir\nvngx.dll_dlssnr.dll" -Destination $manualZipDir -Force
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

    if (!(Test-Path "Output")) { New-Item -ItemType Directory -Path "Output" | Out-Null }
    $zipOutputPath = "Output\dlss-unlocked-standalone.zip"
    Compress-Archive -Path "$manualZipDir\*" -DestinationPath $zipOutputPath -Force
    Write-Host "Standalone zip created at: $zipOutputPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "You can now compile the installer with Inno Setup using 'DLSS unlocked.iss'." -ForegroundColor Green
