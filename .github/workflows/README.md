# GitHub Actions Workflows for DLSS-Unlocked

This directory contains automated workflows for building DLSS-Unlocked installers with the latest OptiScaler_DLSSNR releases.

## Workflows

### 1. Build Installer (`build-installer.yml`)

**Purpose**: Automatically builds DLSS-Unlocked installer with the latest OptiScaler_DLSSNR components.

**Triggers**:
- Schedule (every 3 hours) to check for new releases
- Manual trigger with version selection
- Push to main/master branch (for testing)

**What it does**:
1. Checks for new OptiScaler_DLSSNR releases from `Dagherbou/OptiScaler_DLSSNR`
2. Downloads the latest release archive
3. Extracts and maps binaries (`OptiScaler.dll`, `dlss-unlocked-upscaler.dll`, Neural Rendering forwarder `nvngx.dll_dlssnr.dll`, FidelityFX, and XeSS/XeLL libraries)
4. Updates version information in `DLSS unlocked.iss`
5. Builds the installer using Inno Setup
6. Creates a GitHub release with the installer

**Manual Usage**:
```bash
# Trigger build with specific OptiScaler_DLSSNR version
gh workflow run build-installer.yml \
  -f optiscaler_version=v0.2.0-dlssnr \
  -f force_build=true

# Trigger build with nightly or latest version
gh workflow run build-installer.yml \
  -f optiscaler_version=latest \
  -f force_build=false
```

## Setup Requirements

### Repository Secrets
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions (no setup needed)

### Permissions
The workflows require the following permissions:
- `contents: write` - To create releases and upload assets
- `actions: read` - To check workflow statuses

### Dependencies
The workflows automatically install:
- **Inno Setup**: Using [Minionguyjpro/Inno-Setup-Action@v1.2.7](https://github.com/Minionguyjpro/Inno-Setup-Action)
- **7-Zip**: Using [milliewalky/setup-7-zip@v2](https://github.com/milliewalky/setup-7-zip)
- **PowerShell**: Pre-installed on Windows runners

## File Structure

```
.github/workflows/
└── build-installer.yml     # Main build workflow

# Generated during build:
Output/                     # Installer output directory
└── dlss-unlocked-setup-*.exe

# Updated during build:
Dll version/
├── dlss-unlocked-upscaler.dll  # From OptiScaler.dll
├── OptiScaler.dll              # OptiScaler main binary
├── nvngx.dll_dlssnr.dll        # DLSS Neural Rendering forwarder
├── libxess.dll                 # Intel XeSS library
├── libxess_dx11.dll            # Intel XeSS DX11 library
├── libxess_fg.dll              # Intel XeSS Frame Generation library
├── libxell.dll                 # Intel XeLL library
└── amd_fidelityfx_*.dll        # AMD FidelityFX libraries
```

## Version Naming

**DLSS-Unlocked Version Format**: `1.0.YYYYMMDD.HHMMSS`
- Base version: `1.0`
- Timestamp: Build date and time

**Release Naming**: `DLSS Unlocked (latest) - OptiScaler_DLSSNR vX.X.X-dlssnr`

## Customization

### Changing OptiScaler Source
Edit the `OPTISCALER_REPO` environment variable in `build-installer.yml`:
```yaml
env:
  OPTISCALER_REPO: Dagherbou/OptiScaler_DLSSNR
```

### Changing Schedule
Modify the cron expressions in the workflow file:
```yaml
schedule:
  - cron: '0 */3 * * *'  # Every 3 hours
```

## Local Testing

Use the included PowerShell script for local testing:

```powershell
# Test with default OptiScaler_DLSSNR
.\build-optiscaler.ps1 -DownloadLatest

# Test with specific local archive
.\build-optiscaler.ps1 -OptiScalerPath "C:\path\to\OptiScaler-DLSSNR-v0.2.0.zip"
```
