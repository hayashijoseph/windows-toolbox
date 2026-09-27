# Windows Toolbox

A curated collection of modular PowerShell automation scripts, system administration utilities, and bloat-free software installers for Windows 10 and 11.

---

## Overview

**Windows Toolbox** provides lightweight, standalone administrative tools designed to solve specific Windows configuration, software deployment, and device setup challenges without installing third-party bloatware, background updater services, or unnecessary software suites.

---

## Available Tools

| Category | Tool | Description | Documentation |
| :--- | :--- | :--- | :--- |
| **Drivers** | **[Apple Tethering](drivers/AppleTethering)** | Extracts and stages official Apple iPhone USB tethering and mobile device drivers without installing iTunes. | [View Guide](drivers/AppleTethering/README.md) |
| **Software** | **[Firefox Enterprise (en-GB)](software/FirefoxUKEnterprise)** | Silently downloads and installs 64-bit Mozilla Firefox ESR with UK English localization, disabled desktop icons, and disabled maintenance service. | [View Guide](software/FirefoxUKEnterprise/README.md) |

---

## Quick Start & Requirements

### System Requirements
* **Operating System:** Windows 10 or Windows 11 (64-bit)
* **PowerShell:** Version 5.1 (Built-in) or PowerShell 7+
* **Permissions:** Administrator privileges (required for driver staging and silent software installations)

### Execution Policy
If PowerShell restricts running downloaded scripts, enable script execution for your current session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## Repository Structure

```text
windows-toolbox/
├── .github/workflows/          # Continuous Integration security & secret scanning
├── drivers/
│   └── AppleTethering/         # Standalone Apple USB tethering driver installer
│       ├── Install-AppleTetheringDriver.ps1
│       └── README.md
├── software/
│   └── FirefoxUKEnterprise/    # Silent Firefox ESR UK installer
│       ├── Install-FirefoxUK.ps1
│       └── README.md
├── .gitignore                  # Security & artifact exclusions
└── README.md                   # Toolbox catalog & overview
```

---

## Security & Best Practices

* **Official Vendor CDNs Only:** All installers and drivers are downloaded directly from official vendor endpoints (e.g., Apple, Mozilla, Microsoft Update Catalog).
* **Automated CI Scanning:** Every push and pull request is scanned with [Gitleaks](https://github.com/gitleaks/gitleaks) to prevent accidental credential or secret leakage.
* **Pre-Commit Defense:** Local commits are verified to protect committer privacy and block accidental uploads of `.env` files or credentials.

---

## License & Credits
Contributions and feedback are welcome. See individual tool directories for upstream references and technical credits.