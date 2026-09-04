#define MyAppName "DLSS Unlocked"
#define MyAppVersion "1.0.0.0"
#define MyAppPublisher "artur_07305"
;#define MyAppURL "https://discord.com/invite/2JDHx6kcXB"
#define MyAppExeName "my-game.exe"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; This section is temporarily commented out, as it seems that soem AVs are sensitive to the presence of any URL in the executable and increase the risk of false positive
;AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DefaultDirName=c:\games\my-game\bin\x64
DisableProgramGroupPage=yes
DirExistsWarning=no
LicenseFile=DLSS for NVIDIA - License.rtf
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputBaseFilename=dlss-unlocked-setup-1.0.0.0
AppendDefaultDirName=no
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Compression type is very important here, bzip/9 is the safest one in regards to false positives, lzma2 on the other hand triggers some AVs, but reduce the file size by 50%
;Compression=bzip/9
Compression=lzma2
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
InternalCompressLevel=ultra
LZMADictionarySize=231072
LZMAUseSeparateProcess=yes
LZMANumFastBytes=200
SolidCompression=no
WizardStyle=modern
UsePreviousAppDir=no
InfoBeforeFile=DLSS Unlocked Intro.rtf
EnableDirDoesntExistWarning=yes
Uninstallable=yes
RestartApplications=no
RestartIfNeededByRun=no
TerminalServicesAware=no
CreateUninstallRegKey=no
LanguageDetectionMethod=none
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Some AVs do not like InnoSetup in x64 configuration...
;ArchitecturesAllowed=x64
;ArchitecturesInstallIn64BitMode=x64
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CloseApplications=no

[Types]
Name: "full"; Description: "Preferred installation (DLL package)"
Name: "debug"; Description: "Troubleshooting installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom
Name: "experimental"; Description: "Experimental support for AMD and Intel GPUs"

[Components]
Name: mainfiles; Description: Install main DLSS Unlocked files (game dependant); Types: full
Name: mainfiles/dllversion; Description: Install as a version.dll file (optimal compatibility); Types: full; Flags: exclusive
Name: mainfiles/dllwinmm; Description: Install as a winmm.dll file (if version.dll didn't work); Types: custom; Flags: exclusive
Name: mainfiles/asiversion; Description: Install as an ASI plugin (if the game is heavily modded); Types: custom debug; Flags: exclusive
Name: mainfiles/dlldxgi; Description: Install as a dxgi.dll file (if nothing above works); Types: custom; Flags: exclusive

Name: nonnvidia; Description: Enable support for AMD and Intel GPUs (DON'T INSTALL if you have a NVIDIA GPU); Types: experimental custom
Name: nonnvidia/localdir; Description: Install NVIDIA Runtime files into game directory; Types: experimental custom; Flags: exclusive
Name: upscalers; Description: Install OptiScaler_DLSSNR upscaler and Neural Rendering components; Flags: fixed; Types: full debug custom
Name: mandatory; Description: Install Nukem9 DLSSG-to-FSR3 module (version 0.100); Types: full debug custom; Flags: fixed

Name: optional; Description: Install optional files; Flags: fixed; Types: full debug custom
Name: mandatory/regentries; Description: (optional) Install .reg files enabling/disabling driver signature checks (only for troubleshooting purposes); Types: debug custom
Name: mandatory/fgdebug; Description: (optional) Install debug configuration file for Nukem9 DLSSG-to-FSR3 module (only for troubleshooting purposes); Types: debug custom



[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]

[Files]
; cleanup - create placeholder files for compatibility
Source: "Dll version\nvngx.ini"; DestDir: "{app}"; DestName: "dlss-unlocked-xess.dll"; Flags: ignoreversion deleteafterinstall; Components: mandatory
Source: "Dll version\nvngx.ini"; DestDir: "{app}"; DestName: "dlss-unlocked-fsr.dll"; Flags: ignoreversion deleteafterinstall; Components: mandatory
Source: "Dll version\dlss-unlocked.log"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: mandatory
Source: "Dll version\dlss-unlocked.log"; DestDir: "{app}"; DestName: "dlssg_to_fsr3.log"; Flags: ignoreversion skipifsourcedoesntexist; Components: mandatory
Source: "Dll version\dlss-unlocked.log"; DestDir: "{app}"; DestName: "fakenvapi.log"; Flags: ignoreversion skipifsourcedoesntexist; Components: mandatory

; runtime env
Source: "NVIDIA Environment\dxgi.dll"; DestDir: "{app}"; Components: nonnvidia/localdir mainfiles/dlldxgi
Source: "NVIDIA Environment\dlss-finder.bin"; DestName: "dlss-finder.exe"; DestDir: "{app}"; Components: nonnvidia/localdir
Source: "NVIDIA Environment\nvapi64-proxy.dll"; DestName: "nvapi64-proxy.dll"; DestDir: "{app}"; Components: nonnvidia/localdir
Source: "DLLSG mod\nvngx.dll"; DestDir: "{app}"; DestName: "_nvngx.dll"; Flags: ignoreversion; Components: nonnvidia/localdir

; DLSSG
Source: "DLLSG mod\dlssg_to_fsr3.ini"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory/fgdebug
Source: "DLLSG mod\DisableNvidiaSignatureChecks.reg"; DestDir: "{app}"; DestName: "DisableNvidiaSignatureChecks.reg"; Flags: ignoreversion skipifsourcedoesntexist; Components: mandatory/regentries nonnvidia/localdir
Source: "DLLSG mod\RestoreNvidiaSignatureChecks.reg"; DestDir: "{app}"; DestName: "RestoreNvidiaSignatureChecks.reg"; Flags: ignoreversion skipifsourcedoesntexist; Components: mandatory/regentries nonnvidia/localdir
Source: "DLLSG mod\dlssg_to_fsr3_amd_is_better.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\READ ME.txt"; DestDir: "{app}"; DestName: "READ ME (DLSSG to FSR3 mod).txt"; Flags: ignoreversion deleteafterinstall; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\READ ME.txt"; DestDir: "{app}/licenses"; DestName: "READ ME (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\LICENSE.txt"; DestDir: "{app}"; DestName: "LICENSE (DLSSG to FSR3 mod).txt"; Flags: ignoreversion deleteafterinstall; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\LICENSE.txt"; DestDir: "{app}/licenses"; DestName: "LICENSE (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\nvngx.dll"; DestDir: "{app}"; DestName: "nvngx-wrapper.dll"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi

; upscalers - OptiScaler_DLSSNR files downloaded during build (not stored in repo)
Source: "Dll version\dlss-unlocked-upscaler.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\OptiScaler.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\nvngx.dll_dlssnr.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\OptiScaler.ini"; DestDir: "{app}"; DestName: "nvngx.ini"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\libxess.dll"; DestDir: "{app}"; Flags: uninsneveruninstall skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\libxess_dx11.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\libxess_fg.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\libxell.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_dx12.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_framegeneration_dx12.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_loader_dx12.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_upscaler_dx12.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_vk.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\D3D12Core.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
; OptiScaler license files (not duplicated in repo)
Source: "Dll version\XeSS_LICENSE.txt"; DestDir: "{app}"; DestName: "XESS LICENSE.txt"; Flags: ignoreversion deleteafterinstall skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\XeSS_LICENSE.txt"; DestDir: "{app}/licenses"; DestName: "XESS LICENSE.txt"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\FidelityFX_LICENSE.md"; DestDir: "{app}/licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\FidelityFX_v2_LICENSE.md"; DestDir: "{app}/licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\DirectX_LICENSE.txt"; DestDir: "{app}/licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\RenoDX_ATTRIBUTION.txt"; DestDir: "{app}/licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers

; main module
Source: "Dll version\version.dll"; DestDir: "{app}/plugins"; DestName: "dlss-unlocked.asi"; Flags: confirmoverwrite; Components: mainfiles/asiversion
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "dlss-unlocked.dll"; Flags: confirmoverwrite; Components: mainfiles/dlldxgi
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "version.dll"; Flags: confirmoverwrite; Components: mainfiles/dllversion
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "winmm.dll"; Flags: confirmoverwrite; Components: mainfiles/dllwinmm

; common docs
Source: "Readme (DLSS unlocked).txt"; DestDir: "{app}"; Flags: ignoreversion deleteafterinstall; Components: mainfiles/dllwinmm mainfiles/dllversion mainfiles/asiversion mainfiles/dlldxgi
Source: "Readme (DLSS unlocked).txt"; DestDir: "{app}/licenses"; Flags: ignoreversion; Components: mainfiles/dllwinmm mainfiles/dllversion mainfiles/asiversion mainfiles/dlldxgi
Source: "License (DLSS unlocked).txt"; DestDir: "{app}/licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: mainfiles/dllwinmm mainfiles/dllversion mainfiles/asiversion mainfiles/dlldxgi

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]

[Run]
Filename: "{app}\licenses\Readme (DLSS unlocked).txt"; Description: "View the DLSS Unlocked README file"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\nvngx.ini"; Description: "Edit the configuration file (optional)"; Flags: postinstall shellexec skipifsilent unchecked
Filename: "{app}\dlss-finder.exe"; Parameters: "/s"; StatusMsg: "Disabling NVIDIA signature checks for DLSS 3.7"; WorkingDir: "{app}"; Description: "DLSS 3.7 activation step"; Flags: skipifsilent skipifdoesntexist
