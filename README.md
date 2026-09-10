# DLSS-Unlocked

[![Build Installer](https://github.com/ShyVortex/dlss-unlocked/actions/workflows/build-installer.yml/badge.svg)](https://github.com/ShyVortex/dlss-unlocked/actions/workflows/build-installer.yml)

Unlock **DLSS 3 Frame Generation (DLSS-G)**, **Multi-Frame Generation (MFG: 2X, 3X, 4X)**, and **Neural Rendering (DLSS-NR)** features across NVIDIA GeForce RTX 20xx / 30xx / 40xx GPUs in DirectX 12 games. Fully compatible with **Windows** and **Linux (Proton)** out of the box.

<p align="center">
  <img width="960" src="thumbnail.jpeg" alt="DLSS Unlocked Thumbnail">
</p>

---

> [!NOTE]
> ### Acknowledgments
> This project is only made possible thanks to the extraordinary dedication of talented open-source developers.
>
> Sincere gratitude and respect go to **[Artur Graniszewski](https://github.com/artur-graniszewski/DLSS-Enabler)** for creating the revolutionary **DLSS Enabler**, **[OptiScaler](https://github.com/optiscaler/OptiScaler)**, **[wilsjo2](https://github.com/wilsjo2/OptiScaler-DLSSNR-PreSR-Multipass)** for the pre-SR multipass enhancements, **[sdli1995](https://github.com/sdli1995/dlssg_for_sm86)** for the native Turing/Ampere MFG unlocker, and **[Dagherbou](https://github.com/Dagherbou/OptiScaler_DLSSNR)** for DLSS-NR forwarder research.
>
> If you enjoy this project, please consider visiting their repositories, starring their work, and supporting their donation channels directly!

---

## ⚠️ Requirements
- Game that natively supports DLSS Upscaling and DLSS Frame Generation
- For Multi-Frame Generation to be enabled in the game's graphics settings, it must natively support the feature

## ✨ Features

- **Multi-Frame Generation (MFG):** Out of the box, DLSS Unlocked primarily targets GeForce RTX 20 and 30 series GPUs (Turing & Ampere) via the native `dlssg_sm86` unlocker. RTX 40 series (Ada Lovelace) users can easily switch to the Ada MFG unlocker (`AdaMfgUnlock`) directly via the OptiScaler in-game overlay or `OptiScaler.ini`. DLSS Enabler headless is also bundled as an alternative companion option.
- **DLSS-G Frame Generation Bridge:** Seamlessly translates NVIDIA Streamline DLSS-G calls to native DLSS Frame Generation or AMD FidelityFX FSR 3.1 Frame Generation via OptiScaler.
- **Neural Rendering (DLSS-NR & Pre-SR Multipass):** Full support for wilsjo2's OptiScaler-DLSSNR-PreSR-Multipass backend, featuring pre-SR multipass neural rendering, improved DLSS 5 compatibility, and forwarder.
- **Linux / Proton Support:** Clean modular layout without recursive driver deadlocks.
- **Dual Release Format:** All-in-one automated Setup installer (`.exe`) and clean standalone manual archive (`.zip`).

---

## 📦 Download & Installation

Get the latest release from the **[Releases](../../releases)** page.

### Option A: Automated Installer (`.exe`) — Recommended for Windows
1. Download `dlss-unlocked-setup-*.exe`.
2. Run the installer and browse to your game's executable directory (e.g. `C:\Games\YourGame\bin\x64`).
3. Complete the installation wizard.

### Option B: Standalone Package (`.zip`) — Recommended for Linux / Manual Installs
1. Download `dlss-unlocked-standalone-*.zip`.
2. Extract the contents directly into your game's executable folder alongside the main game `.exe`:
   - **Root folder:** `dxgi.dll` *(rename to `version.dll` if using ReShade)*, `OptiScaler.ini`, `nvngx.dll_dlssnr.dll`, `nvngx_dlssnr.dll` (patched DLSS-NR)
   - **`OptiScaler/` folder:** Companion modules (`dlss-enabler-headless.dll`, `dlssg_to_fsr3_amd_is_better.dll`, `nvngx.ini`, FidelityFX, XeSS, registry bypasses)
   - **`OptiScaler/dlssg_sm86/` folder:** Native Turing/Ampere MFG unlocker (`dlssg_sm86.dll`, `dlssg_sm86.ini`, `THIRD_PARTY_NOTICES.txt`)
   - **`OptiScaler/streamline/` folder:** NVIDIA Streamline 2.14.1 runtime files
   - **`Licenses/` folder:** Official licenses for NVIDIA Streamline, AMD FidelityFX, Intel XeSS, third-party libraries, and legal disclaimers
3. **(Linux)** Launch a game with the following options: `WINEDLLOVERRIDES="dxgi=n,b" %command%`.

---

## 🎮 Supported GPUs

- **NVIDIA GeForce RTX 20xx / 30xx (Turing & Ampere):** Enabled out of the box with the bundled `dlssg_sm86` native MFG unlocker.
- **NVIDIA GeForce RTX 40xx (Ada Lovelace):** Fully supported; can switch to the Ada MFG unlocker (`AdaMfgUnlock=true`) or native DLSS FG via the in-game overlay or `OptiScaler.ini`.

---

## 🚀 Automated CI Builds

This repository automatically tracks and synchronizes with upstream [OptiScaler-DLSSNR-PreSR-Multipass](https://github.com/wilsjo2/OptiScaler-DLSSNR-PreSR-Multipass):
1. Checks for new releases every 3 hours.
2. Packages the latest upscaler binaries, neural rendering forwarders, and companion libraries.
3. Automatically builds and publishes both `.exe` installer and `.zip` standalone manual packages on new releases.

---

## 🛠️ Building Locally

To build the standalone package or installer locally:

```powershell
# 1. Download latest OptiScaler-DLSSNR-PreSR-Multipass and package standalone zip
.\build-optiscaler.ps1 -DownloadLatest -CreateStandaloneZip

# 2. Compile Inno Setup installer (requires Inno Setup 6.2+)
# Open "DLSS unlocked.iss" in Inno Setup Compiler and click Build
```

---

## Known Issues & Troubleshooting

### 1. Overlay Crash on Linux / Proton (DirectX 12)
Some DX12 games may crash (`VK_ERROR_DEVICE_LOST`) under Wine / Proton when opening the OptiScaler in-game overlay menu:
- **Fix:** Set `OverlayMenu=false` under `[Menu]` in `OptiScaler.ini`.
- **Note:** This allows the overlay to render via the game's internal render pipeline without crashing the Vulkan presentation queue, though the menu colors may be affected by the game's auto-exposure or tone-mapping. You can adjust colors or switch to a dark theme under **Menu Theme and Color** in the overlay.

### 2. Resident Evil Requiem & Capcom RE Engine Games
Capcom's RE Engine enforces strict memory and swapchain integrity checks:
- **Crash on Boot (`re9.exe!0x140000000...`):**
  - Use `dxgi.dll` as the proxy name and install **[REFramework](https://github.com/praydog/REFramework)** (`dinput8.dll`) into the game root directory alongside `dxgi.dll`. REFramework safely hooks into the engine early and bypasses Capcom's VTable integrity checks.
- **Frame Generation on RTX 20xx / 30xx GPUs:**
  - Set `FGInput=dlssg` under `[FrameGen]` in `OptiScaler.ini` for rock-solid 2X Frame Generation.
  - Multi-Frame Generation (MFG: 3X / 4X) can trigger race conditions with RE Engine's asynchronous worker threads; standard 2X (`FGInput=dlssg`) is recommended for RE Engine titles.

## 📜 Credits

- **[OptiScaler-DLSSNR-PreSR-Multipass](https://github.com/wilsjo2/OptiScaler-DLSSNR-PreSR-Multipass)** by wilsjo2
- **[dlssg_for_sm86](https://github.com/sdli1995/dlssg_for_sm86)** by sdli1995
- **[DLSS Enabler](https://github.com/artur-graniszewski/DLSS-Enabler)** by Artur Graniszewski
- **[OptiScaler_DLSSNR](https://github.com/Dagherbou/OptiScaler_DLSSNR)** by Dagherbou
- **[OptiScaler](https://github.com/optiscaler/OptiScaler)**
- **[DLSSG to FSR3](https://github.com/Nukem9/dlssg-to-fsr3)** by Nukem9
- **[DLSSSpoofer](https://github.com/nitrog0d/DLSSSpoofer)** by NitroG0d
- **[nvapi-dummy](https://github.com/FakeMichau/nvapi-dummy)** by FakeMichau
- **[d3d12-proxy](https://github.com/cdozdil/d3d12-proxy)** by Nitec

## ⚖️ Legal Disclaimer

- **Trademarks:** **NVIDIA**, **GeForce**, **RTX**, **DLSS**, **Streamline**, and related marks are trademarks or registered trademarks of **NVIDIA Corporation**. All other trademarks, brand names, and technologies (including **AMD FidelityFX**, **Intel XeSS**, etc.) are the property of their respective owners.
- **Non-Affiliation:** This project is an independent, open-source community modification and interoperability tool. The author and contributors are not affiliated with, authorized, sponsored, or endorsed by NVIDIA Corporation, AMD, Intel, or any game developers or publishers.
- **Third-Party Binaries:** Proprietary binaries (including NVIDIA Streamline runtime components) are not hosted or distributed directly within this Git repository. Automated CI release workflows bundle publicly accessible runtime files solely for interoperability and convenience to provide users with a seamless, out-of-the-box modding experience.
- **Intended Use:** This software is intended solely for single-player games to enhance hardware performance and feature accessibility. **Do not use in multiplayer games or titles protected by anti-cheat systems.**
- **Disclaimer of Warranty:** This project is provided "as is", without warranty of any kind, express or implied. Use at your own risk.

For the full legal statement, license disclosures, and terms, please review [DISCLAIMER](Licenses/DISCLAIMER.txt).
