# Windows 11 Full Debloat

An aggressive Windows 11 debloat and performance-optimization PowerShell script designed to remove unnecessary Microsoft consumer applications, reduce background activity, disable selected telemetry and advertising features, and optimize Windows for a leaner installation.

> ⚠️ **Warning:** This script makes significant system-wide changes. It is intended for users who understand the implications of disabling Windows services and removing Windows applications. Test it before deploying it to production systems.

---

## 🚀 Quick Start

The script can be executed directly from GitHub without manually downloading the `.ps1` file.

Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/SAYANKO/gsc/main/Debloat_Windows11.ps1 | iex
```

The bootstrapper:

1. Connects to the GitHub Raw repository.
2. Downloads the script to a randomized temporary file.
3. Executes the script using PowerShell.
4. Waits for the script to finish.
5. Removes the temporary file.

The script does **not** permanently install itself.

---

## 📋 Requirements

* Windows 11
* PowerShell 5.1 or later
* Administrator privileges
* Internet connectivity
* Access to `raw.githubusercontent.com`

Run PowerShell as Administrator before executing the script.

You can verify the PowerShell version with:

```powershell
$PSVersionTable.PSVersion
```

---

## 🧹 What Does It Do?

### Appx / UWP Applications

Removes non-essential Appx applications installed for existing users.

It also removes provisioned applications so that they are not automatically installed for newly created users.

The following core components are currently whitelisted:

```text
Microsoft.WindowsStore
Microsoft.DesktopAppInstaller
Microsoft.NET.Native.Framework
Microsoft.NET.Native.Runtime
Microsoft.VCLibs
Microsoft.UI.Xaml
```

> The whitelist is intentionally small because this is an **aggressive** debloat configuration.

---

### OneDrive

Attempts to completely remove Microsoft OneDrive.

The script:

* Terminates `OneDrive.exe`
* Executes the Windows OneDrive uninstall process

---

### Windows Search

Disables the Windows Search service:

```text
WSearch
```

This prevents Windows Search indexing from running.

> **Impact:** Windows Search functionality and indexed search performance may be affected.

---

### Telemetry

Disables selected Windows telemetry functionality.

The following policy is configured:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection
AllowTelemetry = 0
```

The `DiagTrack` service is also disabled.

---

### Windows Consumer Experience

Disables Windows consumer features that may automatically promote or install applications.

The following policy is configured:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent
DisableWindowsConsumerFeatures = 1
```

---

### Background Applications

Disables background application execution for the current user.

Configuration:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications
GlobalUserDisabled = 1
```

---

## ⚙️ Services Disabled

The following Windows services are disabled:

| Service            | Purpose                                  |
| ------------------ | ---------------------------------------- |
| `DiagTrack`        | Connected User Experiences and Telemetry |
| `dmwappushservice` | WAP Push Message Routing                 |
| `SysMain`          | Windows memory/application optimization  |
| `WSearch`          | Windows Search                           |
| `MapsBroker`       | Downloaded Maps Manager                  |
| `Fax`              | Windows Fax                              |
| `PrintSpooler`     | Windows Printing                         |

### ⚠️ Important

Disabling `PrintSpooler` will prevent normal Windows printing.

If the computer needs to print, remove `PrintSpooler` from the service list before running the script.

Likewise, review the other services according to the intended use of the computer.

---

## 🔋 Hibernation

Windows hibernation is disabled using:

```powershell
powercfg -h off
```

This also removes the Windows hibernation file (`hiberfil.sys`), potentially freeing disk space.

---

## 📢 Ads, Tips & Suggestions

The script disables selected Windows suggestions and consumer content through:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager
```

The following settings are modified:

```text
SystemPaneSuggestionsEnabled = 0
SubscribedContent-338388Enabled = 0
SubscribedContent-353694Enabled = 0
```

---

## 🚀 Performance Configuration

Windows visual effects are configured for performance:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects
VisualFXSetting = 2
```

Transparency effects are also disabled:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
EnableTransparency = 0
```

---

## 🔄 Restart

A restart is recommended after the script completes.

```powershell
Restart-Computer
```

---

## 🛑 Important Considerations

This is an **aggressive** debloat script.

It is not intended to be blindly deployed across every Windows 11 computer.

Before deployment, consider whether the machine requires:

* Windows Search
* Microsoft Store
* OneDrive
* Printing
* Windows Maps
* Background applications
* Microsoft consumer applications
* Other Appx/UWP applications

Removing Appx packages and Windows services can affect functionality and future Windows behavior.

---

## 🧪 Recommended Testing

Before deploying broadly:

1. Test on a virtual machine.
2. Create a restore point or system backup.
3. Run the script.
4. Reboot.
5. Test:

   * Windows Update
   * Microsoft Store
   * Windows Security
   * Network connectivity
   * User login
   * File Explorer
   * Search
   * Printing, if required
   * Any required business applications

Only deploy to additional systems after validating the resulting configuration.

---

## 📁 Temporary File Handling

When executed through the remote bootstrapper, the script is temporarily written to:

### Elevated PowerShell

```text
C:\Windows\Temp\Debloat_Windows11_<random>.ps1
```

### Non-elevated PowerShell

```text
%TEMP%\Debloat_Windows11_<random>.ps1
```

The temporary file is removed after execution.

---

## 🔐 Security Considerations

The following command executes code directly from GitHub:

```powershell
irm https://raw.githubusercontent.com/SAYANKO/gsc/main/Debloat_Windows11.ps1 | iex
```

Only use this command when you trust the repository and understand the code being executed.

For environments requiring stronger change control, download and review the `.ps1` file before execution.

You can inspect the repository source here:

**GitHub Repository**

https://github.com/SAYANKO/gsc

---

## 🧰 Manual Execution

Alternatively, download the script and execute it locally:

```powershell
.\Debloat_Windows11.ps1
```

If PowerShell blocks the script because of the local execution policy:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Debloat_Windows11.ps1
```

---

## 🔧 Customization

The script can be customized before deployment.

### Appx Whitelist

Modify:

```powershell
$whitelist = @(
    "Microsoft.WindowsStore",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.NET.Native.Framework",
    "Microsoft.NET.Native.Runtime",
    "Microsoft.VCLibs",
    "Microsoft.UI.Xaml"
)
```

Add applications that should remain installed.

### Service List

Modify:

```powershell
$services = @(
    "DiagTrack",
    "dmwappushservice",
    "SysMain",
    "WSearch",
    "MapsBroker",
    "Fax",
    "PrintSpooler"
)
```

Remove any service that is required by the target system.

---

## 📌 Philosophy

The goal of this project is to provide a simple, transparent and reproducible way to reduce unnecessary Windows 11 components and background activity.

The script intentionally favors an **aggressive / minimal Windows configuration** rather than attempting to preserve every consumer-oriented Windows feature.

Review the code before deployment and customize it for your environment.

---

## 📄 License

Use, modify, and deploy this script at your own discretion.

No warranty is provided. Always test changes before deploying them to production systems.
