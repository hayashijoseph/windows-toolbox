<#
.SYNOPSIS
    Installs Apple iPhone USB tethering and mobile device drivers without installing iTunes.

.DESCRIPTION
    Automates the installation of official Apple mobile device drivers on 64-bit Windows:
    1. Downloads the latest standalone iTunes installer directly from Apple CDN.
    2. Unpacks AppleMobileDeviceSupport64.msi.
    3. Silently installs Apple Mobile Device Support (service and runtime files).
    4. Stages and registers both the USB driver (usbaapl64.inf) and the NDIS Ethernet 
       tethering driver (netaapl64.inf) into the Windows Driver Store using pnputil.exe.
    5. Cleans up all temporary downloaded setup artifacts.

.EXAMPLE
    .\Install-AppleTetheringDriver.ps1
    Executes the automated driver extraction and installation process. Must be executed
    from an elevated (Administrator) PowerShell terminal.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String. Status and progress messages written to the console host.

.NOTES
    File Name : Install-AppleTetheringDriver.ps1
    Author    : Joseph Lam
    Date      : 2026-09-27
    Version   : 1.0.0
    Requires  : Windows 10/11 (x64), PowerShell 5.1+, Local Administrator privileges
    GitHub    : https://github.com/hayashijoseph/windows-toolbox/tree/main/drivers/AppleTethering
    Credits   : Inspired by the Apple-Mobile-Drivers-Installer project by NelloKudo
                (https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer)

.LINK
    https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer/blob/main/AppleDrivInstaller.ps1

.LINK
    https://www.apple.com/itunes/download/win64
#>

#Requires -RunAsAdministrator

Write-Host "Starting Apple Tethering Driver Setup..." -ForegroundColor Cyan

$tempDir = Join-Path -Path $env:TEMP -ChildPath "AppleDriversSetup"
$itunesExe = Join-Path -Path $tempDir -ChildPath "iTunes64Setup.exe"
$extractDir = Join-Path -Path $tempDir -ChildPath "Extracted"
$itunesUrl = "https://www.apple.com/itunes/download/win64"

try {
    # 1. Prepare clean temporary working directory
    if (Test-Path -Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    # 2. Download latest iTunes installer
    Write-Host "Downloading latest Apple iTunes package..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    (New-Object System.Net.WebClient).DownloadFile($itunesUrl,$itunesExe)

    # 3. Extract AppleMobileDeviceSupport64.msi from the executable
    Write-Host "Extracting Apple Mobile Device Support..." -ForegroundColor Yellow
    $proc = Start-Process -FilePath $itunesExe -ArgumentList "/extract `"$extractDir`"" -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Failed to extract iTunes setup (Exit code: $($proc.ExitCode))"
    }

    $msiPath = Join-Path -Path $extractDir -ChildPath "AppleMobileDeviceSupport64.msi"
    if (-not (Test-Path -Path $msiPath)) {
        # Fallback search if extracted to current directory
        $msiMatch = Get-ChildItem -Path $tempDir -Filter "AppleMobileDeviceSupport64.msi" -Recurse | Select-Object -First 1
        if ($msiMatch) { $msiPath = $msiMatch.FullName } else { throw "AppleMobileDeviceSupport64.msi was not found." }
    }

    # 4. Install Apple Mobile Device Support silently (service + driver files)
    Write-Host "Installing Apple Mobile Device Support..." -ForegroundColor Yellow
    $msiProc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn /norestart" -Wait -PassThru
    if ($msiProc.ExitCode -ne 0 -and $msiProc.ExitCode -ne 3010) {
        throw "MSI installation returned error code: $($msiProc.ExitCode)"
    }

    # 5. Register and install both USB and Ethernet (Tethering) drivers into Windows Driver Store
    Write-Host "Adding drivers to Windows Driver Store via pnputil..." -ForegroundColor Yellow
    $commonPath = Join-Path -Path $env:ProgramFiles -ChildPath "Common Files\Apple\Mobile Device Support"
    if (-not (Test-Path -Path $commonPath)) {
        $commonPath = "C:\Program Files\Common Files\Apple\Mobile Device Support"
    }
    $driverInfs = Get-ChildItem -Path $commonPath -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue

    if (-not $driverInfs -or $driverInfs.Count -eq 0) {
        Write-Warning "No .inf files located in '$commonPath'. Checking staging directory..."
        $driverInfs = Get-ChildItem -Path $tempDir -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue
    }

    if (-not $driverInfs -or $driverInfs.Count -eq 0) {
        throw "Failed to locate any Apple .inf driver files."
    }

    foreach ($inf in $driverInfs) {
        Write-Host "Installing: $($inf.Name)" -ForegroundColor DarkGray
        pnputil.exe /add-driver $inf.FullName /install | Out-Null
    }

    Write-Host "Apple USB tethering drivers successfully installed." -ForegroundColor Green
}
catch {
    Write-Error "Driver installation failed: $_"
}
finally {
    # 6. Cleanup installer cache
    if (Test-Path -Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}