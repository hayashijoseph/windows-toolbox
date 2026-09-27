# Install-FirefoxUK

A standalone PowerShell automation script to silently download and install official Mozilla Firefox Extended Support Release (ESR) 64-bit with British English (`en-GB`) localization and enterprise customization flags.

---

## Overview

Deploying Firefox in an enterprise or clean personal environment often requires:
- Disabling unnecessary background updater services (Mozilla Maintenance Service).
- Avoiding desktop icon clutter.
- Ensuring British English (`en-GB`) language packs and regional formatting are pre-selected.
- Generating verbose MSI logs for auditing and troubleshooting.

`Install-FirefoxUK.ps1` automates this entire lifecycle in a single script.

---

## Key Features

* **Direct Vendor CDN:** Downloads directly from Mozilla's official release endpoints (`download.mozilla.org`).
* **Resilient Download Pipeline:** Automatically attempts BITS transfer first, followed by `Invoke-WebRequest` and .NET `WebClient` fallbacks.
* **Enterprise Customization:**
  - `DESKTOP_SHORTCUT=false` — Prevents desktop clutter.
  - `INSTALL_MAINTENANCE_SERVICE=false` — Excludes the background maintenance updater service.
  - `/qn /norestart` — Fully silent unattended deployment with no surprise reboots.
* **Audit Logging:** Captures full verbose installation logs to `%TEMP%\firefox.log`.
* **Clean Staging:** Automatically removes the downloaded `.msi` file upon completion while preserving the diagnostic log.

---

## Requirements

* **Operating System:** Windows 10 or Windows 11 (64-bit)
* **PowerShell:** Version 5.1 or PowerShell 7+
* **Permissions:** Administrator privileges (required for `msiexec` system installation)

---

## Usage

### 1. Download the Script
Open an elevated (Administrator) PowerShell terminal and run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hayashijoseph/windows-toolbox/main/software/FirefoxUKEnterprise/Install-FirefoxUK.ps1" -OutFile "Install-FirefoxUK.ps1"
```

### 2. Execute
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Install-FirefoxUK.ps1
```

---

## Diagnostic Logs
If installation fails or needs verification, view the verbose MSI log generated at:
```powershell
Get-Content -Tail 50 (Join-Path $env:TEMP "firefox.log")
```

---

## References
* Mozilla Firefox Enterprise Documentation: [mozilla.org/firefox/enterprise](https://www.mozilla.org/firefox/enterprise/)
