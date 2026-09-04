DLSS Frame Generation unlocked package v1.0.0.0
===============================================================================================================================

INTRODUCTION:
--------------------------------------------------------------
This all-in-one package allows the users of NVIDIA RTX GPUs to enable DLSS upscaler and DLSSG Frame Generation in most games implementing NVIDIA DLSS 2 / DLSS 3 features.


WHAT'S INCLUDED:
--------------------------------------------------------------
1) DLSS unlocked DLL version 1.0.0.0

2) Nukem9 DLSSG to FSR3 mod version 0.100

3) OptiScaler_DLSSNR mod

4) (optional) NVIDIA Runtime Environment, version 1.0.0.0 (containing DXGI proxy and NVAPI64 proxy)



CREDITS:
--------------------------------------------------------------
DLSS Unlocked is based on DLSS Enabler by Artur Graniszewski: https://github.com/artur-graniszewski/DLSS-Enabler

DLSS unlocked DLL is based on DLSSSpoofer from NitroG0d: https://github.com/nitrog0d/DLSSSpoofer

DLSS unlocked DLL depends on DLSSG to FSR3 mod from Nukem9: https://github.com/Nukem9/dlssg-to-fsr3 and https://www.nexusmods.com/site/mods/738?tab=files

DLSS unlocked Installator depends on NVAPI dummy project by FakeMichau: https://github.com/FakeMichau/nvapi-dummy

DLSS unlocked Installator depends on DX12 proxy by Nitec: https://github.com/cdozdil/d3d12-proxy/releases/tag/v0.1

DLSS unlocked DLSS upscaler emulation depends on OptiScaler_DLSSNR: https://github.com/Dagherbou/OptiScaler_DLSSNR



SUPPORTED GPUs:
--------------------------------------------------------------
NVIDIA GeForce RTX 20xx/30xx/40xx



GAMES TESTED:
--------------------------------------------------------------
You can find the complete list of tested games here: https://docs.google.com/spreadsheets/d/1qsvM0uRW-RgAYsOVprDWK2sjCqHnd_1teYAx00_TwUY/edit?usp=sharing



TROUBLESHOOTING
--------------------------------------------------------------
You can use the following commandline arguments to troubleshoot your game:

 --dlss-debug           - shows the debug console in the background
 --dlss-debug=extra     - shows extensive debug information in a debug console
 --dlss-logging=on/off  - enables logging to the file (default: off)
 --dlss-version         - reports the DLL version used to enable DLSS Frame Generation
 --dlss-upscaler=auto/fsr/xess/dlss - allows to select default DLSS upscaler implementation/emulation (default: auto)
 --dlss-upscaler-quality=sys/ultra - ultra setting forces XeSS/FSR upscalers to render in native resolution only (default: sys - use generic quality profiles) 
 --dlss-hags=on/off/sys - enables/disables or uses system setting for Hardware Accelerated GPU Scheduling even on unsupported hardware/drivers (default: on)
 --dlss-help            - shows the help message with all the arguments supported by the DLL
 --dlss-arch=ZZZ        - allows to spoof different NVIDIA GPU architecture, possible choices: ada (default, if argument not present), turing, ampere, ie --dlss-arch=ampere
 --dlss-disable         - disables the DLL functionality
 --dlss-skip-validation - skips system checks (that are validating HAGS, NVIDIA signature checking or presence of FSR3 files)
 --dlss-diagnostics     - Shows the mod diagnostics
 --dlss-nvapi=mock/proxy/sys - Controls which Nvidia API interface to use (default: proxy).
 --dlss-reflex-fps=ZZZ  - Enables frame rate limiter (default: no limit), where ZZZ is a number of target frames per second (including generated ones)
 --dlss-gpu-name="ZZZ"  - Overrides the name of the GPU reported to the application (default: none = use original GPU name)
 --dlss-gpu-vram=32g    - Overrides the amount of GPU RAM reported to the application, can be set to any value between 1 and 128 gigabytes



EXAMPLES:
--------------------------------------------------------------
1) Check if DLSS unlocked is installed successfully (shows a pop-up with its version and closes the game on start):
    
   "C:\Games\The Witcher 3 Wild Hunt GOTY\bin\x64_dx12\dlss-unlocked.exe" witcher3.exe --dlss-debug=extra

2) Run Witcher 3 with debug console enabled:

   "C:\Games\The Witcher 3 Wild Hunt GOTY\bin\x64_dx12\dlss-unlocked.exe" witcher3.exe --dlss-debug=extra

3) Run Cyberpunk 2077 with Cyber Engine Tweaks present in its x64 directory:

   "C:\Games\Cyberpunk 2077\bin\x64\dlss-unlocked.exe" cyberpunk2077.exe

4) Run Witcher 3 with DLSS unlocked spoofing ampere GPU:

   "C:\Games\Cyberpunk 2077\bin\x64\dlss-unlocked.exe" cyberpunk2077.exe --dlss-arch=ampere



KNOWN ISSUES/LIMITATIONS:
--------------------------------------------------------------
1) Problem: Vignette shaking when quickly moving the camera up/down or left/right in Cyberpunk
   Solution: Install two mods disabling vignette when crouching and during the normal movement. If necessary enable vignette feature provided by NVIDIA overlay (filter options under Alt+F3 shortcut)

2) Problem: Ghosting of moving objects
   Solution: Ghosting needs to be expected from FSR3 Frame Generation feature. You can reduce its visibility by increasing the host FPS, in order to do so, enable image upscaling, or if its enabled - reduce its quality and/or reduce the graphics settings in general. Please note that upscalers introduce their own ghosting (XeSS technique in particular), so choose wisely and experiment.

3) Problem: Frame generation blocks the in-game V-Sync option and sets it to off
   Solution: Open NVIDIA control panel, and force V-Sync option there, pick either "adaptive" or "fast" option to reduce the V-Sync latency

4) Problem: Camera lag noticeable when moving or looking around
   Solution: Latency can be reduced by increasing the number of host frames generated by your GPU, see solution to a "Ghosting of moving objects".

5) Problem: I enabled DLSS in the game options and I see the black screen instead of the actual game.
   Solution: DLSS Unlocked and the DLSSG to FSR3 mod do not implement the DLSS upscaler, they just enable the Frame Generation capability. Please choose a different upscaling method instead (FSR2 or XeSS).

6) Problem: After playing the game for few minutes Frame Generation feature disables itself for no reason/Frame Generation option is on, but the game is unstable
   Solution: Update your game to the latest version and try again, if issue persist, try to troubleshoot it with --dlss-debug command or report the issue on Discord channel

7) Problem: I want to use Steam/Good Old Games/Epic Megastore client to run the game
   Solution: Try to install the preferred solution (based on DLL file) first and check if it works. Universal solution should be used only if the preferred one is not working as it's less compatible with external game launchers, though more compatible with the games started directly.

8) Problem: The version of nukem9 mod bundled with this installer is outdated, how to install the latest one?
   Solution: Download the ZIP package with the latest version of nukem9 mod and copy paste the DLL files into the game directory where the game executable is. DLSS unlocked will detect these files and use them instead of the bundled version.

9) Problem: I want to install the DLL version of the mod, but there's already a file called "version.dll" in my game directory that is not part of this package. What to do?
   Solution: You can either rename it to version-original.dll before installing the mod, or if this fails (the game doesn't start after installation, or reports any other error), you can try to use the universal solution, or uninstall the mod that delivered the original version.dll file.

10) Problem: My game behaves weird/doesn't start/Frame Generation setting cannot be enabled
    Solution: Make sure you didn't install any other mods that try to enable Frame Generation feature (like LukeFZ mod or dummy nvapi64.dll file). If so, revert these changes before installing DLSS unlocked. Additionally, make sure your game is up to date (you are running the latest version of the game), as the old versions tend to not to be able to detect Frame Generation capability or be unstable with Frame Generation on.

11) Problem: Original nukem9 mod requires me to disable NVIDIA Driver Signature Checks, is it also true in case of this installation?
    Solution: No, in case of this installation Frame Generation mechanism will work even with Signature Checks on. Please DO NOT disable them unless its really required as part of troubleshooting process.

12) Problem: I want to troubleshoot some issue with this mod, how to do this?
    Solution: After starting the game hit a combination of Ctrl+` (Control + Tilde) twice to spawn a debug console. You can close it and spawn it again afterwards by hitting the same keys again.

13) Problem: DLSS Unlocked reports that Hardware Accelerated GPU Scheduling (HAGS) is not supported by Windows Driver
    Solution: Update your GPU drivers to the latest version. If your GPU driver doesn't support HAGS at all, start the game with --dlss-hags=on and --dlss-skip-validation commandline arguments to simulate HAGS functionality in DLSS Unlocked.
