# Picks which NVSmooth30 binary ships as OptiScaler\nvsmooth30.dll.
#
# Two copies can exist: the one inside the OptiScaler package and the maintained SM86\smooth-motion.asi. The newer
# NVSmooth30 version wins, read from the version string the binary embeds (NVS30_VERSION, e.g. "0.1.1"); the package
# copy wins a tie. A file whose version can't be read counts as unknown and only wins when the other is unknown or
# missing too. Runs under Windows PowerShell 5.1 (CI) and PowerShell 7.
#
# Usage: .\tools\Select-NvSmooth30.ps1 -PackageDll <path or empty> -AsiPath <path> -Destination <path>

param(
    [string]$PackageDll = '',
    [string]$AsiPath = '',
    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

function Get-NvSmooth30Version {
    param([string]$Path)

    if (-not $Path -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }

    # Latin-1 maps every byte to one character, so string offsets match byte offsets.
    $text = [Text.Encoding]::GetEncoding(28591).GetString([IO.File]::ReadAllBytes($Path))
    if (-not $text.Contains('[nvs30] startup %s')) { return $null }

    $found = [regex]::Matches($text, "\x00(\d+\.\d+\.\d+)\x00")
    if ($found.Count -ne 1) { return $null }
    return [version]$found[0].Groups[1].Value
}

function Format-Source {
    param([string]$Path, $Version)

    if (-not $Path -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 'missing' }
    if ($null -eq $Version) { return "$Path (version unknown)" }
    return "$Path ($Version)"
}

$packageExists = [bool]($PackageDll -and (Test-Path -LiteralPath $PackageDll -PathType Leaf))
$asiExists = [bool]($AsiPath -and (Test-Path -LiteralPath $AsiPath -PathType Leaf))
$packageVersion = Get-NvSmooth30Version $PackageDll
$asiVersion = Get-NvSmooth30Version $AsiPath

$winner = $null
$reason = ''
if ($null -ne $packageVersion -and $null -ne $asiVersion) {
    if ($asiVersion -gt $packageVersion) {
        $winner = $AsiPath; $reason = 'newer version'
    }
    else {
        $winner = $PackageDll
        $reason = if ($asiVersion -eq $packageVersion) { 'same version, package preferred' } else { 'newer version' }
    }
}
elseif ($null -ne $packageVersion) {
    $winner = $PackageDll; $reason = 'only the package version is known'
}
elseif ($null -ne $asiVersion) {
    $winner = $AsiPath; $reason = 'only the SM86 .asi version is known'
}
elseif ($packageExists) {
    $winner = $PackageDll; $reason = 'no version readable, package preferred'
}
elseif ($asiExists) {
    $winner = $AsiPath; $reason = 'no version readable, only the SM86 .asi exists'
}

Write-Host "NVSmooth30 package: $(Format-Source $PackageDll $packageVersion)"
Write-Host "NVSmooth30 SM86 .asi: $(Format-Source $AsiPath $asiVersion)"

if ($null -eq $winner) {
    if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Force }
    Write-Warning "NVSmooth30: no binary available; $Destination will not ship"
    return
}

$destinationDir = Split-Path -Parent $Destination
if ($destinationDir -and -not (Test-Path -LiteralPath $destinationDir)) {
    New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
}
Copy-Item -LiteralPath $winner -Destination $Destination -Force
Write-Host "NVSmooth30 selected: $winner -> $Destination ($reason)"
