<#
.NOTES
	===========================================================================
	 Created on:   	09-19-2026
	 Created by:   	SAYANKO
	 Organization: 	SAYANKO
	 Filename:     	Debloat_Windows11.ps1
	===========================================================================
.SYNOPSIS
    Windows 11 FULL Debloat and Performance Optimization Script.

.DESCRIPTION
    Aggressively removes non-essential Windows 11 Appx/UWP applications,
    provisioned applications, OneDrive, telemetry components, consumer
    experience features, background applications, and selected Windows
    services.

    The script also applies several system and user-level configuration
    changes intended to reduce background activity, telemetry, advertising,
    suggestions, and unnecessary resource consumption.

    Performance-related changes include:
      - Removing non-essential Appx/UWP applications
      - Removing provisioned applications for future users
      - Uninstalling OneDrive
      - Disabling Windows Search indexing
      - Disabling selected telemetry services
      - Disabling consumer/advertising experiences
      - Disabling background application execution
      - Disabling selected non-essential Windows services
      - Disabling hibernation
      - Disabling Windows tips, suggestions, and advertising
      - Configuring Windows visual effects for performance
      - Disabling transparency effects

    This is an AGGRESSIVE debloat configuration and is intended for systems
    where unnecessary Microsoft consumer applications and background
    services are not required.

    Some changes may affect Windows functionality. In particular:
      - Windows Search/indexing will be disabled.
      - Printing will be disabled.
      - Fax functionality will be disabled.
      - Maps functionality may be affected.
      - OneDrive will be removed.
      - Windows consumer applications may be removed.
      - Hibernation will be disabled.
      - Background application execution will be restricted.
      - Some Windows features or Microsoft Store applications may depend
        on components affected by this script.

    Review the service list and Appx whitelist before running this script
    on production systems.

    WARNING:
        This script makes system-wide changes and removes Windows
        applications/services. It is intentionally aggressive.

        Test on a non-production machine before deployment.


.EXAMPLE
    PS C:\> .\Debloat_Windows11.ps1

    Runs the complete Windows 11 debloat and optimization process.

.EXAMPLE
    PS C:\> PowerShell -ExecutionPolicy Bypass -File .\Debloat_Windows11.ps1

    Executes the script while temporarily bypassing the local execution
    policy for this PowerShell process.

#>

Write-Host "Starting FULL debloat..."

# --- Remove ALL Appx Packages (except core system)
Write-Host "Removing all Appx packages..."

$whitelist = @(
    "Microsoft.WindowsStore",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.NET.Native.Framework",
    "Microsoft.NET.Native.Runtime",
    "Microsoft.VCLibs",
    "Microsoft.UI.Xaml"
)

Get-AppxPackage -AllUsers | ForEach-Object {
    $name = $_.Name
    if ($whitelist -notcontains $name) {
        try {
            Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
        } catch {}
    }
}

# Remove provisioned apps (prevents reinstall for new users)
Get-AppxProvisionedPackage -Online | ForEach-Object {
    if ($whitelist -notcontains $_.DisplayName) {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
}

# --- Kill OneDrive completely
Write-Host "Removing OneDrive..."
taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue
Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue

# --- Disable Cortana & Search
Write-Host "Disabling Cortana/Search..."
Stop-Service WSearch -Force -ErrorAction SilentlyContinue
Set-Service WSearch -StartupType Disabled

# --- Disable Telemetry & Data Collection
Write-Host "Disabling telemetry..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Value 0

# --- Disable Consumer Experience (auto-install apps)
Write-Host "Disabling consumer features..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
-Name DisableWindowsConsumerFeatures -Value 1

# --- Disable Background Apps
Write-Host "Disabling background apps..."
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
-Name GlobalUserDisabled -Value 1 -PropertyType DWORD -Force

# --- Disable Unnecessary Services
Write-Host "Disabling services..."
$services = @(
    "DiagTrack",     # Telemetry
    "dmwappushservice",
    "SysMain",
    "WSearch",
    "MapsBroker",
    "Fax",
    "PrintSpooler"
)

foreach ($svc in $services) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# --- Disable Hibernation
powercfg -h off

# --- Disable Tips, Ads, Suggestions
Write-Host "Disabling ads and suggestions..."
$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $cdm -Name SystemPaneSuggestionsEnabled -Value 0
Set-ItemProperty -Path $cdm -Name SubscribedContent-338388Enabled -Value 0
Set-ItemProperty -Path $cdm -Name SubscribedContent-353694Enabled -Value 0

# --- Set Performance Mode
Write-Host "Setting best performance..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
-Name VisualFXSetting -Value 2

# --- Disable Transparency
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
-Name EnableTransparency -Value 0

Write-Host "FULL Debloat complete. Reboot recommended."
