# Windows 11 Full Debloat - Remote Bootstrapper
#
# Usage:
# irm https://raw.githubusercontent.com/SAYANKO/gsc/main/Debloat_Windows11.ps1 | iex

$ErrorActionPreference = "Stop"

# Enable TLS 1.2 for compatibility
[Net.ServicePointManager]::SecurityProtocol = `
    [Net.ServicePointManager]::SecurityProtocol -bor `
    [Net.SecurityProtocolType]::Tls12

# GitHub Raw URL
$DownloadURL = 'https://raw.githubusercontent.com/SAYANKO/gsc/main/Debloat_Windows11.ps1'

# Generate a random temporary filename
$rand = Get-Random -Maximum 99999999

# Determine whether PowerShell is running elevated
$isAdmin = [bool](
    [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544'
)

# Use Windows\Temp when elevated, otherwise user's TEMP
$FilePath = if ($isAdmin) {
    "$env:SystemRoot\Temp\Debloat_Windows11_$rand.ps1"
}
else {
    "$env:TEMP\Debloat_Windows11_$rand.ps1"
}

try {

    Write-Host "Downloading Windows 11 Full Debloat..." -ForegroundColor Cyan

    $response = Invoke-WebRequest `
        -Uri $DownloadURL `
        -UseBasicParsing

    # Save downloaded script temporarily
    Set-Content `
        -Path $FilePath `
        -Value $response.Content `
        -Encoding UTF8

    Write-Host "Starting Windows 11 Full Debloat..." -ForegroundColor Green

    # Pass any arguments supplied to the bootstrapper
    $ScriptArgs = @(
        "-NoProfile"
        "-ExecutionPolicy", "Bypass"
        "-File", $FilePath
    ) + $args

    # Execute the downloaded script and wait for completion
    $process = Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList $ScriptArgs `
        -Wait `
        -PassThru

    # Preserve the script's exit code
    $ExitCode = $process.ExitCode

}
catch {

    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    $ExitCode = 1

}
finally {

    # Remove temporary payload
    if (Test-Path $FilePath) {
        Remove-Item $FilePath -Force -ErrorAction SilentlyContinue
    }

}

exit $ExitCode
