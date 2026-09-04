# DLSS-Unlocked

[![Build Installer](https://github.com/ShyVortex/dlss-unlocked/actions/workflows/build-installer.yml/badge.svg)](https://github.com/ShyVortex/dlss-unlocked/actions/workflows/build-installer.yml)

Simulate DLSS Upscaler and DLSS-G Frame Generation features on NVIDIA GeForce RTX 20xx/30xx/40xx GPUs in DirectX 12 games that support DLSS2 and DLSS3 natively.

## 🚀 Automated Builds with Latest OptiScaler_DLSSNR

This repository features **automated builds** that keep DLSS-Unlocked up-to-date with the latest [OptiScaler_DLSSNR](https://github.com/Dagherbou/OptiScaler_DLSSNR) releases!

### 📦 Download Latest Release

**Recommended**: Download the latest pre-built installer from the [Releases](../../releases) page. These installers are automatically built with:
- ✅ Latest OptiScaler_DLSSNR (Neural Rendering model support, latest fixes and features)
- ✅ Latest XeSS library from Intel
- ✅ All required components pre-configured

### 🎮 Supported GPUs

- NVIDIA GeForce RTX 20xx / 30xx / 40xx

### 🔄 How Auto-Updates Work

The automated system:
1. **Monitors** OptiScaler_DLSSNR repository for new releases every 3 hours
2. **Downloads** the latest release archive from OptiScaler_DLSSNR releases
3. **Deploys** components including `dlss-unlocked-upscaler.dll`, `OptiScaler.dll`, Neural Rendering forwarder `nvngx.dll_dlssnr.dll`, FidelityFX, and XeSS libraries
4. **Builds** a new installer using Inno Setup
5. **Publishes** the installer as a GitHub release

### 🛠️ Local Updates (Advanced Users)

For developers or advanced users who want to build with OptiScaler_DLSSNR manually:

```powershell
# Build with specific OptiScaler_DLSSNR archive
.\build-optiscaler.ps1 -OptiScalerPath "C:\path\to\OptiScaler-DLSSNR-v0.2.0.zip"
```

## How to

### How to build a setup application

In order to build the setup application for DLSS Unlocked, you need to install InnoSetup software first ( https://jrsoftware.org/isdl.php ). The most optimal version is 6.2.0 (nothing below, nothing above - mainly due to the craziness of some AVs that raise false positives randomly).

After installing the InnoSetup software, double click "DLSS unlocked.iss" file and edit its contents (such as build version, etc) in InnoSetup Editor.

Before building new package, run `build-optiscaler.ps1` or ensure required DLL files are placed into "Dll version" subdirectory.

After successful build, the resulting setup app will be created inside of "Output" directory.

## 📜 Credits

- **[DLSS Enabler](https://github.com/artur-graniszewski/DLSS-Enabler)** by Artur Graniszewski
- **[OptiScaler_DLSSNR](https://github.com/Dagherbou/OptiScaler_DLSSNR)** by Dagherbou
- **[DLSSSpoofer](https://github.com/nitrog0d/DLSSSpoofer)** by NitroG0d
- **[DLSSG to FSR3](https://github.com/Nukem9/dlssg-to-fsr3)** by Nukem9
- **[nvapi-dummy](https://github.com/FakeMichau/nvapi-dummy)** by FakeMichau
- **[d3d12-proxy](https://github.com/cdozdil/d3d12-proxy)** by Nitec
