<#
.SYNOPSIS
    Silently downloads and installs Mozilla Firefox ESR (Enterprise) 64-bit with British English (en-GB) localization.

.DESCRIPTION
    Automates the download, silent deployment, and enterprise configuration of the official
    Mozilla Firefox Extended Support Release (ESR) 64-bit package:
    1. Prepares temporary installation staging workspace in %TEMP%.
    2. Downloads the latest official 64-bit en-GB MSI installer directly from Mozilla CDN.
    3. Employs resilient multi-tier download logic (BITS -> Invoke-WebRequest -> .NET WebClient).
    4. Silently installs Firefox via msiexec with enterprise flags:
       - Suppresses desktop shortcut creation (DESKTOP_SHORTCUT=false)
       - Excludes the Mozilla Maintenance background service (INSTALL_MAINTENANCE_SERVICE=false)
       - Generates a detailed installation log in %TEMP%\firefox.log
    5. Cleans up the temporary .msi payload after completion.

.EXAMPLE
    .\Install-FirefoxUK.ps1
    Executes the silent Firefox ESR (en-GB) installation. Must be run from an elevated
    (Administrator) PowerShell session.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String. Status and progress messages written to the console host.

.NOTES
    File Name : Install-FirefoxUK.ps1
    Author    : Joseph Lam
    Date      : 2026-09-27
    Version   : 1.0.0
    Requires  : Windows 10/11 (x64), PowerShell 5.1+, Local Administrator privileges
    GitHub    : https://github.com/hayashijoseph/windows-toolbox/tree/main/software/FirefoxUKEnterprise

.LINK
    https://www.mozilla.org/firefox/enterprise/
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$workdir = $env:TEMP
$logFile = Join-Path -Path $workdir -ChildPath "firefox.log"
$source = "https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=en-GB"
$destination = Join-Path -Path $workdir -ChildPath "firefox.msi"

Write-Host "Starting Firefox ESR (en-GB) Enterprise setup..." -ForegroundColor Cyan

try {
    # 1. Ensure staging directory exists
    if (-not (Test-Path -Path $workdir)) {
        New-Item -Path $workdir -ItemType Directory -Force | Out-Null
    }

    # 2. Configure security protocols (TLS 1.2 / TLS 1.3)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

    # 3. Resilient Download
    Write-Host "Downloading latest Firefox ESR (en-GB) 64-bit installer..." -ForegroundColor Yellow

    $downloadSuccess = $false

    if (Get-Command 'Start-BitsTransfer' -ErrorAction SilentlyContinue) {
        try {
            Start-BitsTransfer -Source $source -Destination $destination -ErrorAction Stop
            $downloadSuccess = $true
        } catch {
            Write-Warning "BITS transfer failed. Falling back to Invoke-WebRequest: $_"
        }
    }

    if (-not $downloadSuccess) {
        try {
            Invoke-WebRequest -Uri $source -OutFile $destination -UseBasicParsing -ErrorAction Stop
            $downloadSuccess = $true
        } catch {
            Write-Warning "Invoke-WebRequest failed. Falling back to WebClient: $_"
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($source, $destination)
            $downloadSuccess = $true
        }
    }

    if (-not (Test-Path -Path $destination)) {
        throw "Failed to download Firefox installer to $destination."
    }

    # 4. Silent Enterprise Installation
    Write-Host "Installing Firefox ESR silently (logging to $logFile)..." -ForegroundColor Yellow
    $installArgs = "/i `"$destination`" DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false /l*v `"$logFile`" /qn /norestart"

    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru

    # 0 = success, 3010 = success reboot required
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
        Write-Host "Firefox ESR (en-GB) installed successfully." -ForegroundColor Green
    } else {
        throw "MSI installer exited with error code: $($proc.ExitCode). Check $logFile for details."
    }
}
catch {
    Write-Error "Installation failed: $_"
}
finally {
    # 5. Cleanup installer payload
    if (Test-Path -Path $destination) {
        Remove-Item -Path $destination -Force -ErrorAction SilentlyContinue
    }
}
