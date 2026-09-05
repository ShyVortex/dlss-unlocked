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
Name: "full"; Description: "Preferred installation (dxgi.dll + OptiScaler + Frame Gen)"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: mainfiles; Description: Main entry point proxy; Types: full custom
Name: mainfiles/dlldxgi; Description: Install as dxgi.dll (preferred for DirectX 11/12 & RE Engine); Types: full custom; Flags: exclusive
Name: mainfiles/dllversion; Description: Install as version.dll (alternative hook / ReShade compatible); Types: custom; Flags: exclusive
Name: mainfiles/dllwinmm; Description: Install as winmm.dll (alternative hook); Types: custom; Flags: exclusive
Name: mainfiles/asiversion; Description: Install as ASI plugin (in plugins/ folder); Types: custom; Flags: exclusive

Name: core; Description: Install OptiScaler_DLSSNR core, upscaler and neural rendering components; Flags: fixed; Types: full custom
Name: optional; Description: Install optional troubleshooting files; Types: custom
Name: optional/regentries; Description: Signature check override registry scripts; Types: custom
Name: optional/fgdebug; Description: Debug INI configuration for DLSSG-to-FSR3; Types: custom

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]

[Files]
; 1. Root files ({app}): Proxy DLL, OptiScaler.ini, nvngx.dll_dlssnr.dll
Source: "Dll version\OptiScaler.dll"; DestDir: "{app}"; DestName: "version.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllversion
Source: "Dll version\dlss-unlocked-upscaler.dll"; DestDir: "{app}"; DestName: "version.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllversion
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "version.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllversion

Source: "Dll version\OptiScaler.dll"; DestDir: "{app}"; DestName: "winmm.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllwinmm
Source: "Dll version\dlss-unlocked-upscaler.dll"; DestDir: "{app}"; DestName: "winmm.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllwinmm
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "winmm.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dllwinmm

Source: "Dll version\OptiScaler.dll"; DestDir: "{app}"; DestName: "dxgi.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dlldxgi
Source: "Dll version\dlss-unlocked-upscaler.dll"; DestDir: "{app}"; DestName: "dxgi.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dlldxgi
Source: "Dll version\version.dll"; DestDir: "{app}"; DestName: "dxgi.dll"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/dlldxgi

Source: "Dll version\OptiScaler.dll"; DestDir: "{app}\plugins"; DestName: "dlss-unlocked.asi"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/asiversion
Source: "Dll version\dlss-unlocked-upscaler.dll"; DestDir: "{app}\plugins"; DestName: "dlss-unlocked.asi"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/asiversion
Source: "Dll version\version.dll"; DestDir: "{app}\plugins"; DestName: "dlss-unlocked.asi"; Flags: confirmoverwrite skipifsourcedoesntexist; Components: mainfiles/asiversion

Source: "Dll version\OptiScaler.ini"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\nvngx.dll_dlssnr.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: core

; 2. OptiScaler subdirectory files ({app}\OptiScaler): DLSS Enabler Headless (MFG), DLSSG mod, upscalers, companion DLLs
Source: "Dll version\dlss-enabler.asi"; DestDir: "{app}\OptiScaler"; DestName: "dlss-enabler-headless.dll"; Flags: confirmoverwrite; Components: core
Source: "DLLSG mod\dlssg_to_fsr3_amd_is_better.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\nvngx.ini"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core

; Upscaler and runtime companion DLLs
Source: "Dll version\amd_fidelityfx_dx12.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\amd_fidelityfx_framegeneration_dx12.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\amd_fidelityfx_loader_dx12.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\amd_fidelityfx_upscaler_dx12.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\amd_fidelityfx_vk.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\libxess.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\libxess_dx11.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\libxess_fg.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\libxell.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\D3D12Core.dll"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core

; Signature check overrides and optional debug configs
Source: "DLLSG mod\DisableNvidiaSignatureChecks.reg"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core optional/regentries
Source: "DLLSG mod\RestoreNvidiaSignatureChecks.reg"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: core optional/regentries
Source: "DLLSG mod\dlssg_to_fsr3.ini"; DestDir: "{app}\OptiScaler"; Flags: ignoreversion skipifsourcedoesntexist; Components: optional/fgdebug

; 3. Documentation & Licenses ({app}\licenses)
Source: "Readme (DLSS unlocked).txt"; DestDir: "{app}\licenses"; Flags: ignoreversion; Components: core
Source: "License (DLSS unlocked).txt"; DestDir: "{app}\licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "DLLSG mod\READ ME.txt"; DestDir: "{app}\licenses"; DestName: "READ ME (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: core
Source: "DLLSG mod\LICENSE.txt"; DestDir: "{app}\licenses"; DestName: "LICENSE (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: core
Source: "Dll version\XeSS_LICENSE.txt"; DestDir: "{app}\licenses"; DestName: "XESS LICENSE.txt"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\FidelityFX_LICENSE.md"; DestDir: "{app}\licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\FidelityFX_v2_LICENSE.md"; DestDir: "{app}\licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\DirectX_LICENSE.txt"; DestDir: "{app}\licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: core
Source: "Dll version\RenoDX_ATTRIBUTION.txt"; DestDir: "{app}\licenses"; Flags: ignoreversion skipifsourcedoesntexist; Components: core

[Icons]

[Run]
Filename: "{app}\licenses\Readme (DLSS unlocked).txt"; Description: "View the DLSS Unlocked README file"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\OptiScaler.ini"; Description: "Edit the configuration file (optional)"; Flags: postinstall shellexec skipifsilent unchecked
