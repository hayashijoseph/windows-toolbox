# Install-AppleTetheringDriver

A standalone PowerShell automation script to install official Apple iPhone USB tethering and mobile device drivers on 64-bit Windows without installing the full iTunes suite or accompanying background software.

---

## Overview

Enabling USB tethering on Windows typically requires installing the full iTunes package from Apple. This script extracts only the required driver files and supporting background service, pre-staging them into the native Windows Driver Store.

### Key Features
* **Zero Bloat:** Installs only the Apple Mobile Device Service and network/USB drivers; excludes iTunes, Apple Music, Bonjour, and Apple Software Update.
* **Always Current:** Downloads the official installer directly from Apple's Content Delivery Network (CDN) to ensure drivers are up to date.
* **Plug-and-Play Ready:** Staged directly into the Windows Driver Store (`pnputil.exe`), allowing immediate interface binding without manual Device Manager configuration.
* **Clean Execution:** Automatically extracts components into temporary staging storage and purges all setup artifacts after completion.

---

## Requirements

* **Operating System:** Windows 10 or Windows 11 (64-bit)
* **PowerShell:** PowerShell 5.1 or PowerShell 7+
* **Permissions:** Administrator privileges (required for service installation and driver staging)

---

## How It Works

1. Downloads the official 64-bit standalone installer (`iTunes64Setup.exe`) directly from Apple.
2. Extracts the core component package: `AppleMobileDeviceSupport64.msi`.
3. Installs `AppleMobileDeviceSupport64.msi` silently (`/qn /norestart`).
4. Traverses the installed driver paths (`Drivers` and `NetDrivers`) and injects both `usbaapl64.inf` (USB device) and `netaapl64.inf` (NDIS Ethernet tethering) into the Windows Driver Store via `pnputil.exe`.
5. Cleans up all temporary downloaded files and directories from `%TEMP%`.

---

## Usage

### 1. Download the Script
Open an elevated (Administrator) PowerShell prompt and download `Install-AppleTetheringDriver.ps1`:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hayashijoseph/windows-toolbox/main/drivers/AppleTethering/Install-AppleTetheringDriver.ps1" -OutFile "Install-AppleTetheringDriver.ps1"
```

### 2. Run the Script
Execute the script from the elevated PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Install-AppleTetheringDriver.ps1
```

Once complete, plug in your iPhone via USB, enable **Personal Hotspot**, and Windows will automatically recognize the device as a high-speed Ethernet network adapter.

---

## Credits & References
* Inspired by [Apple-Mobile-Drivers-Installer](https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer) by NelloKudo.
* Official Apple iTunes distribution: [apple.com/itunes/download/win64](https://www.apple.com/itunes/download/win64)
